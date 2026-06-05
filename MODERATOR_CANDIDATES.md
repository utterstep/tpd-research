# Candidate moderators for extending the meta-analysis

Exploratory discovery of *new* moderators (beyond what Visscher et al. coded),
to test in the correlated-effects meta-regression once coded.

**Method.** Keyword scan of the 124 included-study PDFs (`scripts` ad-hoc) for
~20 feature families, plus domain synthesis. The **coverage %** below is the
share of PDFs whose text *mentions* the feature — a triage proxy that **overstates
codeable coverage** (keyword noise) and says nothing about whether the feature
*varies*. Real coding needs a per-study read (one agent per study, as we did for
extraction). Treat this as a prioritization aid, not a result.

**Already coded by Visscher (do NOT re-add):** study design, assignment unit,
publication status, sample size, SES, targeted population, TPD goal, **number of
TPD hours**, TPD trainer (res/dev vs external), the 4 learning-theory principles
(coaching, performance standards, self-regulation, **cooperation**), tested
subject, grade level, country.

---

## Tier 1 — high priority (strong theory · real variance · not redundant)

| Moderator | Hypothesis (direction) | Corpus evidence | Coding difficulty |
|---|---|---|---|
| **Delivery mode** (in-person / blended / online) | In-person > online; blended in between. Highly policy-relevant post-COVID. | Online & in-person both widely mentioned (keyword-noisy); true split needs reading. Clear variance exists (e.g. ABRA, ITSS, web tools vs summer institutes). | Medium — must read to separate delivery from incidental "online". |
| **Outcome test alignment** (researcher-aligned/proximal vs independent/distal) | Aligned/proximal tests yield 2–3× larger effects (Wolf & Harbatkin 2023, cited by Visscher). **Visscher names this an explicit future direction.** Varies even within their "independent-only" set. | ~37% discuss proximal/distal/alignment; we already tag `test_type` per effect size, so partial data exists. | Medium–High — judgment on test↔intervention overlap. |
| **Curriculum-coupled PD** (PD bundled with a new curriculum/materials vs PD on existing practice) | Bundled effects may reflect the *materials*, not the PD — a confound worth isolating. | 70% mention curriculum/instructional materials; correlates with (but is narrower than) the existing "TPD for curricula" goal. | Low–Medium. |
| **Outcome timing** (immediate vs delayed/follow-up) | Effects fade after PD ends; tests fade-out. Visscher note: almost all measured immediately; only ~48 studies ran >1 yr. | "Follow-up/delayed" mentioned 90% (boilerplate-noisy); genuinely delayed achievement outcomes are rarer. | Medium. |

## Tier 2 — promising, with caveats

| Moderator | Hypothesis | Corpus evidence | Caveat |
|---|---|---|---|
| **Dose received / attendance** (vs hours *offered*) | Treatment-on-treated > intent-to-treat; low take-up dilutes effects. | Dosage/attendance discussed 75%. | Refines the existing "PD hours" variable; partial overlap. |
| **Timing structure** (summer institute vs job-embedded) | Job-embedded/sustained > one-shot summer (Darling-Hammond). | summer ~21% vs embedded ~38% → real variance. | Correlates with duration (already coded). |
| **Teacher experience / career stage** (novice vs veteran) | PD may help novices more (more room to grow). | 58% report experience. | Often only a sample mean, not a moderatable split. |
| **Urbanicity** (urban / rural / suburban) | Context effects; rural delivery constraints. | 70% mention; urban 80 / rural 51 / suburban 30 → good variance. | Correlates with SES (already coded). |
| **Voluntary vs mandatory participation** | Volunteers more motivated → larger effects (selection). | voluntary 76 vs mandatory 15. | Imbalanced; thin "mandatory" cell. |

## Tier 3 — redundant or low-variance (note, don't prioritize)

- **PD hours stated** (~23%) → already a coded moderator.
- **PLC / teacher collaboration** (78%) → ≈ the existing *cooperation* principle.
- **Funder IES/NSF vs EEF/i3** (87%) → ≈ the US/UK country split.
- **Active-learning components** (84%) → near-universal (low variance) and overlaps the principles.
- **Control active vs BAU** (75%) → inclusion required BAU; mostly constant (but a useful data-quality check — caught Simmons 2011's active control).
- **Fidelity level** (80% measure it) → it's **post-treatment**, so moderating on it risks collider bias; better as a descriptive/sensitivity variable than a moderator.
- **Class size** (46%), **coaching delivery mode** (7%) → weak theory / too rare.

---

## Caveats before coding any of these

1. **Reporting limits.** Visscher ran 115 author interviews *because* publications
   under-report TPD features. A publications-only coding will have missing data;
   expect some "not reported" cells (handle as they did for SES).
2. **Multicollinearity.** Several candidates correlate with existing moderators
   (delivery↔recency, materials↔TPD-for-curricula, funder↔country, urbanicity↔SES,
   summer↔duration). Check VIF / run them singly before a joint model.
3. **Exploratory, not confirmatory.** Like Visscher's own RQ3, these describe
   moderation of an *association*, not a causal effect; interpret cautiously and
   report as hypothesis-generating.
4. **Fidelity is a mediator, not a moderator** — keep it out of the moderation model.

## Recommended next step

Code the **Tier-1 four** (delivery mode, test alignment, curriculum-coupled,
outcome timing) via one agent per study against a short codebook (same harness as
extraction), merge as columns, then run each through `R/02_models.R`'s
meta-regression (singly first, then a joint exploratory model with a VIF check).
Add Tier-2 picks if the user wants breadth.
