# Test-alignment extension — result

**Question.** Do outcome measures *aligned* to the intervention (proximal /
developer-made) show larger effects than *independent* standardized tests
(distal)? Visscher et al. excluded proximal tests by design and named this an open
question; Wolf & Harbatkin (2023) estimate proximal tests run 2–3× larger.

**Data.** The fuller effect-size set that re-includes researcher-made/proximal
outcomes (`effect_sizes_with_aligned.csv`): 422 effect sizes, 118 study-clusters
(340 distal + 81 proximal + 1 unclear). Alignment taken from per-effect-size
`test_type`. CE model, rho=0.08, ICC=0.20.

## Headline

| Estimate | g [95% CI] |
|---|---|
| Canonical (distal/independent tests only) | 0.070 [0.051, 0.089] |
| **All outcomes (proximal re-included)** | **0.101 [0.075, 0.126]** |

Re-allowing aligned tests **raises the average effect ~44%** (0.070 → 0.101) — a
direct demonstration of why the measure-inclusion rule matters.

## Proximal vs distal

| | g [95% CI] | k studies | ES |
|---|---|---|---|
| Distal (independent standardized) | 0.070 [0.051, 0.089] | 111 | 340 |
| **Proximal (aligned/developer-made)** | **0.237 [0.150, 0.323]** | 32 | 81 |

Difference **b = 0.190 [0.090, 0.289], p = 0.0005** — proximal effects are **~3.4×**
distal.

## Within-study (the clean test): 25 studies reporting BOTH

Holding the study, teachers, and intervention fixed and varying only the outcome
measure:

| | g [95% CI] |
|---|---|
| Distal | 0.090 [0.038, 0.143] |
| **Proximal** | **0.224 [0.127, 0.321]** |

Within-study difference **b = 0.160 [0.086, 0.233], p = 0.0002** (~2.5×).
**Adjusted** for the confirmatory covariates: proximal coefficient **0.163, p = 0.003**.

## Interpretation
- Strongly confirms Wolf & Harbatkin and **validates Visscher's decision to include
  only independent measures** — using aligned tests would have inflated the
  headline TPD effect from ~0.07 (small) to ~0.10–0.24 (medium).
- The within-study estimate (0.16, p=.0002) isolates measurement alignment from
  study-level confounds: the *same* PD looks ~2.5× more effective on a test built
  around what it taught than on an independent standardized test.
- This is a publishable extension: it operationalizes the future direction the
  original authors flagged, using the proximal effect sizes they discarded.
