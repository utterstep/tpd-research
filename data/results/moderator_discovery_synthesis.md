# Bottom-up moderator discovery — synthesis

16 agents re-read all 124 study PDFs and proposed moderators grounded in what the
papers actually vary on (`data/moderator_ideas/chunk*.json`, 114 raw suggestions).
The striking result: independent agents reading different studies **converged on
one construct family** — the *implementation / transmission chain* (efficacy→
effectiveness decay), not the nominal PD design Visscher coded.

## Frequency (how many of the 16 agent-batches surfaced each)

| Candidate family | #chunks | strong | codeable from pubs? | clean moderator? |
|---|---|---|---|---|
| Fidelity / realized dose / take-up | 14 | 6 | partly | ⚠️ POST-treatment (mediator/collider) |
| **Coaching dose / cadence / in-class locus** | 13 | 10 | yes | ✅ pre-treatment design feature |
| Program maturity / measurement year | 12 | 3 | yes | ✅ (sharpens outcome-timing) |
| **Added student-facing dose** (tutoring/small-grp/time) | 12 | 3 | yes | ✅ isolates a real confound |
| **Evaluator independence / efficacy-vs-effectiveness** | 11 | 8 | yes | ✅ pre-treatment |
| **Counterfactual strength** (BAU vs active control) | 9 | 4 | yes | ✅ pre-treatment |
| **Cascade / train-the-trainer depth** | 9 | 5 | yes | ✅ pre-treatment |
| Causal-chain length / proximal-change-without-transfer | 7 | 3 | partly | ⚠️ partly post-treatment |
| Baseline teacher experience (novice vs veteran) | 7 | 2 | sometimes | ~ usually only a sample mean |
| Product-led vs teacher-practice-change | 5 | 1 | subjective | ~ fuzzy to code |
| Targeted vs universal delivery | 4 | 1 | yes | ✅ |
| Buy-in / voluntariness | 4 | 0 | rarely | ⚠️ |
| Active rehearsal / practice-with-feedback | 3 | 1 | yes | ✅ |
| Teacher–student language/cultural match | 2 | 0 | yes | narrow |

## The headline construct: efficacy → effectiveness decay

A cluster of co-varying, **pre-treatment, codeable** moderators all describe the
same thing — how far a study sits from "ideal developer-controlled conditions":
**evaluator independence / developer-delivered**, **cascade depth**,
**counterfactual strength**, and **program maturity at measurement**. Within-study
evidence agents surfaced is compelling:
- Gore 2021: identical protocol, **g = 0.12 researcher-led vs 0.02 adviser-led**.
- Vaughn 2022: same PD, **g ≈ 0.5–0.6 on researcher tests vs ≈ 0 on independent**.
- Pathway/Olson: developer single-district efficacy d ≈ .48–.67 → **0.32 / .06**
  under independent multi-district scale-up.
- Kitmitto: an efficacy-proven program **nulls out** under a train-the-trainer cascade.
- EEF independent effectiveness trials cluster near zero throughout.

Note this is **distinct** from Visscher's coded "trainer = researcher/developer vs
external" (which is only who runs the *workshop*) — these capture who *evaluated*
the study, how far it *scaled*, and what it was *compared against*.

This dovetails with our test-alignment finding: both say a large share of the
apparent TPD effect is an artifact of measurement/conditions (proximal tests +
developer-ideal settings) that does not survive independent, scaled, real-world
implementation. Together they form a strong, publishable thesis.

## Methodological cautions
- **Fidelity, realized-dose/take-up, and "did the proximal mediator move"** are
  the MOST prevalent ideas but are **post-treatment** → moderating on them risks
  collider/mediator bias. Use as descriptive stratifiers, not causal moderators.
- The efficacy→effectiveness moderators **co-vary** (multicollinearity) — code
  them, test singly, then consider a composite "implementation-conditions" index.

## Recommended next step
Code the **efficacy→effectiveness cluster** (evaluator independence + cascade
depth + counterfactual strength), plus the two strong stand-alone design
moderators **coaching dose/locus** and **added student-facing dose** — all
pre-treatment and codeable. Test each singly in the CE model, then jointly with a
VIF check, framed as exploratory (as Visscher did for RQ3).
