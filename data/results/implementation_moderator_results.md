# Implementation-conditions moderators — results

7 study-level moderators coded across 124 studies (`data/moderators2/`), tested in
the CE model (rho=0.08, ICC=0.20). Subgroup means = subset null models; omnibus =
clubSandwich CR2; joint model adjusts for the confirmatory covariates.

## The one robust finding: evaluator independence

| | studies | g [95% CI] |
|---|---|---|
| Independently evaluated | 66 | **0.049** [0.025, 0.073] |
| Developer-evaluated | 45 | **0.105** [0.077, 0.133] |

Omnibus **F = 11.0, p = 0.0014** — developer-run evaluations report **~2.1× larger**
effects. It **survives the joint model** (coef = 0.058, **p = 0.044**) adjusting for
publication status, SES, grade, subject, goal, and all other implementation
moderators — so it is not reducible to the other variables.

**Crucial caveat:** evaluator-independence is strongly correlated with publication
status (Cramér's V = **0.59**) — independent evaluations are largely the
unpublished IES/EEF gray literature; developer evaluations are largely published
journal articles. Numerically the split (0.105 / 0.049) mirrors published/
unpublished (0.093 / 0.047). So it is *partly* the publication-bias axis re-seen
from another angle — but it adds signal **beyond** publication status (joint p=.044).

## The honest nulls (hypothesized but not supported between studies)

| Moderator | levels (g) | omnibus p |
|---|---|---|
| Developer-delivered PD | no 0.081 / yes 0.060 | 0.62 |
| Cascade depth | cascade 0.067 / direct 0.063 | 0.86 |
| Counterfactual (active vs BAU) | active 0.069 / BAU 0.070 | 0.86 |
| Coaching intensity | none .062 / occ .072 / frequent .060 | 0.99 |
| Program maturity | first-yr .082 / mature .044 / single .068 | 0.36 |

- The **efficacy→effectiveness decay** the discovery agents saw *within* specific
  studies (Gore, Kitmitto, Pathway) does **not** generalize to a between-study
  pattern for delivery, cascade, or counterfactual — only the *evaluator* facet holds.
- **Coaching dose is flat** — more in-class coaching does not mean larger effects.
- **Maturity is inverse if anything** (mature 0.044 < first-year 0.082; joint coef
  −0.049, p=.054) — between studies, mature-measured trials are disproportionately
  the large independent effectiveness trials, so this is confounded, not a real
  "effects shrink with maturity."

## Suggestive
- **Added student-facing dose**: none 0.054 vs student_component 0.112 (joint coef
  0.083, **p = 0.090**) — studies that bundle tutoring/small-group/extra software
  dose show ~2× the effect, i.e. part of the "PD effect" is the extra instruction.

## Composite "developer-ideal-conditions" index (0–4)
Not monotonic (0.03, 0.07, 0.06, 0.05, 0.10; slope p = 0.38). Because only ONE of
its four components (evaluator independence) actually moves effects, the additive
index just dilutes that single signal.

## Disentangling: not test-alignment, not publication status

- **Not test-alignment in disguise.** The evaluator result is computed on the
  canonical set, which is 100% standardized/independent tests — so even on the
  *same* independent tests, developer-evaluated > independent (0.105 vs 0.049).
- **Not publication status in disguise** — if anything the reverse. Evaluator ×
  publication is 59% collinear, but in a joint model **evaluator independence
  survives (developer +0.044, p=0.041) while publication status drops out
  (unpublished −0.026, p=0.22)**. Visscher's publication-status moderator appears
  to be partly a *proxy* for who ran the evaluation. (Caveat: too collinear to
  separate definitively; the developer+unpublished cell is only k=6.)

## The combined artifact (evaluator × test-alignment, with-aligned set)

| | Distal (independent test) | Proximal (aligned test) |
|---|---|---|
| Independent eval | **0.049** [0.025, 0.073] (k=66) | 0.223 [-0.03, 0.47] (k=8) |
| Developer eval | 0.105 [0.077, 0.133] (k=45) | **0.235** [0.143, 0.327] (k=24) |

Cleanest → most-favorable: **0.049 → 0.235**; contrast **+0.227 [0.118, 0.336],
p < .001 (~4.8×)**. Additive model: aligned test **+0.16 (p=.003)**, developer
eval **+0.07 (p=.007)**, **interaction ≈ 0 (p=.85)** — two independent, additive
levers. The most rigorous cell (independent eval + independent test, k=66) gives
**g ≈ 0.05** — the trustworthy floor.

## Bottom line + the combined thesis
Of the seven, **only evaluator independence is a robust moderator** (student-dose
suggestive; the rest null). Combined with the test-alignment finding, a coherent,
publishable thesis emerges: **the apparent TPD effect is substantially inflated by
research artifacts — both developer-run evaluation and intervention-aligned tests
roughly halve when removed.** Under independent evaluation AND independent
measurement, the effect is small (~0.05). The "implementation chain" story is real
within studies but, at the between-study level, reduces mostly to *who evaluated*,
which is itself close to the publication-status axis.
