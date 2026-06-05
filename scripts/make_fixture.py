# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Generate a SYNTHETIC effect-size fixture for smoke-testing the R pipeline.

This lets us validate that 02_models.R runs end-to-end (robumeta / clubSandwich /
weightr / MetaUtility all wire up correctly) BEFORE we have any real extracted
data. The numbers are fabricated -- they are NOT a replication of anything.

It draws ~356 effect sizes across the 143 registry arms, with a true mean near
the paper's 0.09 and study-level heterogeneity, so the null model should return
something in the right ballpark and the moderator frame is fully populated.

Run:  uv run scripts/make_fixture.py
Out:  data/extracted/effect_sizes_FIXTURE.csv
"""

import csv
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REG = ROOT / "data" / "registry" / "studies.csv"
OUT = ROOT / "data" / "extracted" / "effect_sizes_FIXTURE.csv"

TARGET_N_ES = 356
SUBJECTS = (["Reading"] * 65) + (["STEM"] * 27) + (["Other"] * 8)  # paper proportions

HEADER = [
    "es_id", "row_id", "report_group", "study", "outcome_subject", "grade_band",
    "g", "v", "se", "n_t", "n_c", "n_clusters", "icc_assumed", "cluster_adjusted",
    "pretest_adjusted", "extraction_method", "source_stat", "page_ref",
    "extractor", "confidence", "notes",
]


def main() -> int:
    rng = random.Random(20250603)  # fixed seed -> reproducible fixture
    arms = list(csv.DictReader(REG.open()))
    if not arms:
        raise SystemExit("registry empty; run scripts/build_registry.py first")

    # Distribute ~TARGET_N_ES effect sizes across arms (1..4 each).
    counts = [1 + rng.randrange(4) for _ in arms]
    while sum(counts) < TARGET_N_ES:
        counts[rng.randrange(len(arms))] += 1

    rows = []
    eid = 0
    for arm, k in zip(arms, counts):
        study_true = rng.gauss(0.09, 0.12)  # between-study heterogeneity
        for _ in range(k):
            eid += 1
            se = round(rng.uniform(0.05, 0.22), 4)
            g = round(study_true + rng.gauss(0, se), 4)
            rows.append({
                "es_id": f"F{eid:04d}",
                "row_id": arm["row_id"],
                "report_group": arm["report_group"],
                "study": arm["study"],
                "outcome_subject": rng.choice(SUBJECTS),
                "grade_band": arm["grade_level"],
                "g": g,
                "v": round(se * se, 6),
                "se": se,
                "n_t": rng.randrange(60, 1500),
                "n_c": rng.randrange(60, 1500),
                "n_clusters": rng.randrange(20, 120),
                "icc_assumed": 0.20,
                "cluster_adjusted": "yes",
                "pretest_adjusted": "yes",
                "extraction_method": "SYNTHETIC",
                "source_stat": "SYNTHETIC",
                "page_ref": "",
                "extractor": "fixture",
                "confidence": "n/a",
                "notes": "SYNTHETIC FIXTURE -- not real data",
            })

    with OUT.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=HEADER)
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {OUT.relative_to(ROOT)}  ({len(rows)} synthetic effect sizes, "
          f"{len(arms)} arms)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
