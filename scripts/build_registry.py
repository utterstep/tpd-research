# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Build the master study registry by merging supplementary tables S3.1 + S3.2.

The two tables are row-aligned (row i in S3.1 == row i in S3.2), so we merge by
position rather than by name -- a few study names are spelled inconsistently
between the tables (e.g. "Jerrim et al. 2015" vs "2015a", "Resendez & Azin" vs
"Resendez &Azin"), which we surface via the `name_mismatch` flag for cleanup.

The registry has one row per supplementary-table entry (143 = 128 reports, of
which 15 contributed >1 intervention arm). Analysis treats co-reported arms as a
single dependent cluster; we capture that grouping in `report_group`.

Columns fall into three blocks:
  * identity     : row_id, study, study_s31, study_s32, name_mismatch,
                   report_group, is_multi_arm
  * published codes (from supp, our comparison baseline): assignment_unit,
                   research_design, publication_status, grade_level, ses,
                   targeted_population, tpd_goal, tpd_duration, tpd_trainer,
                   n_principles, coaching, performance_standards,
                   self_regulation, cooperation
  * re-extraction worklist (blank, filled by later stages): full_citation,
                   doi_url, pdf_status, pdf_path, k_effect_sizes,
                   extraction_status, notes

Run:  uv run scripts/build_registry.py
"""

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUB = ROOT / "data" / "published"
OUT = ROOT / "data" / "registry" / "studies.csv"

S31_COLS = [
    "assignment_unit", "research_design", "publication_status",
    "grade_level", "ses", "targeted_population",
]
S32_COLS = [
    "tpd_goal", "tpd_duration", "tpd_trainer", "n_principles",
    "coaching", "performance_standards", "self_regulation", "cooperation",
]
WORKLIST_COLS = [
    "full_citation", "doi_url", "pdf_status", "pdf_path",
    "k_effect_sizes", "extraction_status", "notes",
]


def read(path: Path) -> tuple[list[str], list[list[str]]]:
    with path.open() as f:
        rows = list(csv.reader(f))
    return rows[0], rows[1:]


def norm(name: str) -> str:
    """Normalize a study name for grouping co-reported arms."""
    s = re.sub(r"\s+", " ", name).strip().lower()
    s = s.replace("& ", "&").replace(" &", "&")  # collapse "&" spacing
    return s


def main() -> int:
    _, r31 = read(PUB / "S3.1_methods_units_settings.csv")
    _, r32 = read(PUB / "S3.2_treatment.csv")
    assert len(r31) == len(r32), f"row count mismatch: {len(r31)} vs {len(r32)}"

    # Group key counts to flag multi-arm reports (using the more-complete S3.1 name).
    group_keys = [norm(row[0]) for row in r31]
    counts: dict[str, int] = {}
    for k in group_keys:
        counts[k] = counts.get(k, 0) + 1

    header = (
        ["row_id", "study", "study_s31", "study_s32", "name_mismatch",
         "report_group", "is_multi_arm"]
        + S31_COLS + S32_COLS + WORKLIST_COLS
    )

    out_rows = []
    for i, (a, b) in enumerate(zip(r31, r32), start=1):
        name_s31, name_s32 = a[0], b[0]
        gk = group_keys[i - 1]
        row = {
            "row_id": i,
            "study": name_s31,
            "study_s31": name_s31,
            "study_s32": name_s32,
            "name_mismatch": int(norm(name_s31) != norm(name_s32)),
            "report_group": gk,
            "is_multi_arm": int(counts[gk] > 1),
            **{c: a[j + 1] for j, c in enumerate(S31_COLS)},
            **{c: b[j + 1] for j, c in enumerate(S32_COLS)},
            **{c: "" for c in WORKLIST_COLS},
        }
        row["pdf_status"] = "todo"
        row["extraction_status"] = "todo"
        out_rows.append(row)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=header)
        w.writeheader()
        w.writerows(out_rows)

    n_reports = len(set(group_keys))
    n_multi = sum(1 for r in out_rows if r["is_multi_arm"])
    n_mismatch = sum(1 for r in out_rows if r["name_mismatch"])
    print(f"wrote {OUT.relative_to(ROOT)}")
    print(f"  {len(out_rows)} intervention rows")
    print(f"  {n_reports} unique report groups")
    print(f"  {n_multi} rows belong to multi-arm reports")
    print(f"  {n_mismatch} rows have S3.1/S3.2 name mismatches (need cleanup)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
