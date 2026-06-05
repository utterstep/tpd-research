# Exploratory new-moderator results

Coded across 124 studies (`data/moderators/`), tested in the correlated-effects
model (rho=0.08, ICC=0.20). Subgroup means = subset null CE models; omnibus =
clubSandwich CR2 Wald test. Joint model adds all three to the confirmatory set.

## curriculum_coupled — the strongest signal (but confounded)
| level | studies (k) | g [95% CI] |
|---|---|---|
| practice-only (PD on existing curriculum) | 45 | **0.038** [0.016, 0.059] |
| bundled (PD + new curriculum/materials) | 65 | **0.086** [0.059, 0.113] |

Omnibus p = **0.064**. Bundled ≈ **2.3×** practice-only — the most striking
contrast we found. **Caveat:** strongly confounded with TPD goal (Cramér's V =
0.51; "TPD for curricula/digital tools" ≈ bundled). In the joint model adjusting
for goal etc., the bundled coefficient shrinks to **0.035, p = 0.16** — so the
signal is largely entangled with the goal variable and cannot be cleanly
separated here. Suggestive, not confirmatory.

## test_alignment — cannot be properly tested in this corpus
| level | studies (k) | g [95% CI] |
|---|---|---|
| independent (distal) | 84 | 0.070 [0.048, 0.092] |
| mixed | 24 | 0.065 [0.026, 0.104] |
| aligned (proximal) | 3 | 0.120 [-0.214, 0.454] |

Omnibus p = 0.83. **No apparent difference — but this is an artifact of the
design.** Visscher's inclusion rule (and our matching `researcher_made` exclusion)
filters OUT proximal/developer-made tests, so the "aligned" cell collapses to 3
studies. To actually test the alignment hypothesis (Wolf & Harbatkin; Visscher's
own flagged future direction), the analysis must **re-include the researcher-made
effect sizes** — a deliberate deviation from the original design. This is the
single most worthwhile follow-up.

## delivery_mode — no evidence of a difference (underpowered for online)
| level | studies (k) | g [95% CI] |
|---|---|---|
| in-person | 87 | 0.068 [0.046, 0.089] |
| blended | 17 | 0.081 [0.028, 0.134] |
| online | 3 | 0.036 [-0.003, 0.075] |

Omnibus p = 0.16 (3-level) / 0.58 (in-person vs has-online). No reliable
difference; the online cell (3 studies with usable effects) is too small to
conclude online PD is worse. Not confounded with existing moderators (V ≤ 0.15).

## outcome_timing — near-constant, not modelable
118 immediate / 4 both / 2 delayed. Confirms Visscher's note that virtually all
TPD achievement effects are measured immediately; fade-out can't be studied here.

## Bottom line
- **Curriculum-coupling** is the most promising new moderator (bundled ~2× practice-only)
  but is confounded with TPD goal.
- **Test alignment** is the most scientifically valuable to pursue, but requires
  re-including aligned tests (next step).
- **Delivery mode** shows no difference; needs more online studies to be conclusive.
- **Outcome timing** is effectively constant — a documented limitation, not a moderator.
