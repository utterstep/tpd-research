# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Merge per-study pilot JSONs (data/extracted/pilot/*.json) into effect_sizes.csv.

Key decisions, made explicit (every row keeps `include` + `exclude_reason`):
  * cluster = the REPORT (one JSON = one report), so co-reported arms sharing a
    control group are one dependent cluster -- matching the paper's 143->128
    collapse and what the correlated-effects model expects.
  * include = 1 only for standardized/independent, full-sample, subject-achievement
    outcomes that are not redundant with a composite. Excluded (kept, flagged):
      - subgroup        : FSM / subgroup re-uses part of the same sample
      - cognitive_test  : ability tests (CAT4) are not subject achievement
      - redundant_subscale : a composite/total exists for the same arm x subject
      - researcher_made : paper used only independent measures
  * v = g_var if present else g_se^2.

These rules are a defensible default; the composite-vs-subscale and
cross-subject-composite (e.g. GCSE Attainment 8 overlapping English+Maths)
choices are exactly what we will reconcile against the authors' dataset.

Run:  uv run scripts/merge_pilot.py
"""

import csv
import glob
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PILOT = ROOT / "data" / "extracted" / "pilot"
OUT = ROOT / "data" / "extracted" / "effect_sizes.csv"

COLS = [
    "es_id", "cluster", "row_id", "report_group", "study", "outcome_subject",
    "grade_band", "g", "v", "se", "n_t", "n_c", "n_clusters", "icc_assumed",
    "cluster_adjusted", "pretest_adjusted", "test_type", "test_name",
    "include", "exclude_reason", "extraction_method", "source_stat",
    "page_ref", "extractor", "confidence", "notes",
]


def is_subgroup(e) -> bool:
    # Prefer the structured fields; fall back to arm_label (NOT free-text notes,
    # which caused a false positive on Speckesser's PRIMARY outcome).
    if e.get("outcome_role") is not None:
        return e.get("outcome_role") == "subgroup" or e.get("is_full_sample") is False
    s = str(e.get("arm_label", "")).lower()
    return "subgroup" in s or "fsm-eligible" in s or "fsm subgroup" in s


def is_cognitive(e) -> bool:
    t = str(e.get("test_name", "")).lower()
    return "cat4" in t or "cognitive abilit" in t


def has_composite(name) -> bool:
    n = str(name).lower()
    return "composite" in n or "total" in n


def main() -> int:
    files = sorted(glob.glob(str(PILOT / "*.json")))
    if not files:
        raise SystemExit("no pilot JSONs found")

    out_rows = []
    for f in files:
        slug = Path(f).stem
        d = json.load(open(f))
        ess = d.get("effect_sizes", [])

        # detect, per (row_id, subject), whether a composite/total exists
        comp_groups = set()
        for e in ess:
            if has_composite(e.get("test_name")):
                comp_groups.add((e.get("row_id"), e.get("outcome_subject")))

        for i, e in enumerate(ess, start=1):
            g = e.get("g")
            se = e.get("g_se")
            v = e.get("g_var")
            if v is None and se is not None:
                v = round(float(se) ** 2, 8)
            if se is None and v is not None:
                se = round(float(v) ** 0.5, 6)

            reason = ""
            tt = str(e.get("test_type", ""))
            grp = (e.get("row_id"), e.get("outcome_subject"))
            if v is None:
                reason = "no_variance"          # unusable in a variance-weighted model
            elif tt not in ("standardized_independent",):
                reason = "researcher_made"
            elif is_subgroup(e):
                reason = "subgroup"
            elif is_cognitive(e):
                reason = "cognitive_test"
            elif e.get("outcome_role") == "subscale":
                reason = "redundant_subscale"
            elif e.get("outcome_role") is None and grp in comp_groups \
                    and not has_composite(e.get("test_name")):
                reason = "redundant_subscale"
            include = 0 if reason or g is None else 1

            out_rows.append({
                "es_id": f"{slug}-{i:02d}",
                "cluster": slug,
                "row_id": e.get("row_id"),
                "report_group": slug,           # cluster key for the CE model
                "study": d.get("report"),
                "outcome_subject": e.get("outcome_subject"),
                "grade_band": e.get("grade_band"),
                "g": g, "v": v, "se": se,
                "n_t": e.get("n_t"), "n_c": e.get("n_c"),
                "n_clusters": e.get("n_clusters"), "icc_assumed": e.get("icc"),
                "cluster_adjusted": e.get("cluster_adjusted"),
                "pretest_adjusted": e.get("pretest_adjusted"),
                "test_type": tt, "test_name": e.get("test_name"),
                "include": include, "exclude_reason": reason,
                "extraction_method": e.get("g_method"),
                "source_stat": e.get("impact_estimate"),
                "page_ref": e.get("page_ref"),
                "extractor": "subagent", "confidence": d.get("confidence"),
                "notes": e.get("notes"),
            })

    with OUT.open("w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLS)
        w.writeheader()
        w.writerows(out_rows)

    n_inc = sum(r["include"] for r in out_rows)
    n_cl = len({r["cluster"] for r in out_rows if r["include"]})
    print(f"wrote {OUT.relative_to(ROOT)}: {len(out_rows)} effect sizes "
          f"({n_inc} included across {n_cl} clusters)")
    from collections import Counter
    rc = Counter(r["exclude_reason"] for r in out_rows if r["exclude_reason"])
    for k, v in rc.items():
        print(f"  excluded {v:2d}: {k}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
