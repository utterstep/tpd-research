# How much of the measured TPD effect is a research artifact?

An extension of the independent replication of Visscher et al. (2025). Where the
replication asked *whether* their result reproduces (it does — see `WRITEUP.md`),
this asks *what the average effect is once two methodological choices are made
rigorous*: which outcome test is used, and who runs the evaluation.

---

## Executive summary

Re-extracting effect sizes from the 124 reachable primary studies and coding two
moderators the original meta-analysis did not test, we find that the headline
"teacher PD raises achievement by g ≈ 0.09" rests substantially on two research
artifacts that have nothing to do with the PD itself:

1. **Test alignment.** Outcomes aligned to the intervention (developer/researcher-
   made, "proximal") show **g = 0.237** vs **0.070** for independent standardized
   ("distal") tests. The clean **within-study** comparison — 25 studies reporting
   both — gives proximal 0.224 vs distal 0.090 (**b = 0.16, p = 0.0002**),
   isolating the measure from study-level confounds.

2. **Evaluator independence.** Studies evaluated by the program's own developers
   report **g = 0.105** vs **0.049** for independently-evaluated studies
   (**p = 0.001**), *on the same independent tests*. This is **not** publication
   bias relabeled — in a joint model evaluator independence survives (p = 0.04)
   while publication status, the moderator Visscher did find, drops out (p = 0.22).

These two levers are **independent and additive** (no interaction, p = 0.85).
Crossing them:

| | Independent test | Aligned test |
|---|---|---|
| **Independent evaluator** | **0.049** (k=66) | 0.223 (k=8) |
| **Developer evaluator** | 0.105 (k=45) | **0.235** (k=24) |

From the cleanest cell to the most developer-favorable, the effect rises
**0.049 → 0.235** (**+0.227, p < 0.001, ≈ 4.8×**) — from *trivially small* to
*medium-large* on essentially the same interventions.

**Bottom line.** Under independent evaluation **and** independent measurement —
the most rigorous, best-powered condition (k = 66) — the average effect of teacher
PD on student achievement is **g ≈ 0.05: real, but small.** The larger numbers in
the literature are substantially manufactured by *who studies the program and what
test they choose*, not by the program's effect on learning.

---

## 1. Method (in brief)

From the independent re-extraction (effect sizes recomputed from the primary PDFs;
correlated-effects model, RVE, ρ = 0.08, Hedges-2007 cluster correction at
ICC = 0.20 — see `WRITEUP.md` and `README.md`), we added two layers:

- **Test alignment** is taken from the per-effect-size measure type (independent
  standardized vs researcher/developer-made). Testing it required *re-including*
  the proximal effect sizes the original meta-analysis (and our canonical file)
  exclude — `effect_sizes_with_aligned.csv`, 422 effects (`R/05_alignment.R`).
- **Evaluator independence** (and six other implementation-conditions moderators)
  were coded for all 124 studies against a codebook (`docs/MODERATOR_CODEBOOK_2.md`,
  `data/moderators2/`), after a bottom-up discovery step in which 16 agents
  re-read every paper and proposed candidate moderators
  (`data/results/moderator_discovery_synthesis.md`). Tested in `R/06`.

## 2. Test alignment (`data/results/alignment_extension.md`)

Re-allowing aligned tests raises the overall effect from **0.070 to 0.101 (+44%)**.
Proximal 0.237 [0.150, 0.323] vs distal 0.070 [0.051, 0.089]. The within-study
estimate (b = 0.16, p = 0.0002; adjusted for covariates 0.163, p = 0.003) is the
decisive one: in the very same studies, the *same* PD looks ~2.5× more effective
on a test built around what it taught. This confirms Wolf & Harbatkin (2023),
which the authors cited, and operationalizes the alignment future-direction they
flagged.

## 3. Evaluator independence — and why it is not a known moderator in disguise
(`data/results/implementation_moderator_results.md`)

Developer-evaluated 0.105 vs independent 0.049 (omnibus p = 0.0014; survives the
full confirmatory adjustment, p = 0.044). Two disguises ruled out:

- **Not test-alignment.** The evaluator result is computed on the canonical set,
  which is 100% independent standardized tests — so even holding the test type
  fixed, developer evaluations report ~2× larger effects.
- **Not publication status.** Evaluator and publication status are 59% collinear,
  but in a joint model **evaluator independence wins (developer +0.044, p = 0.041)
  and publication status loses (unpublished −0.026, p = 0.22)**. The publication-
  bias moderator Visscher reported appears to be partly a *downstream proxy* for
  who ran the evaluation. (Honest caveat: the two are too entangled to separate
  definitively; the developer-evaluated-and-unpublished cell is only k = 6.)

## 4. The combined artifact

Both levers contribute independently (additive model: aligned test +0.16, p=.003;
developer evaluation +0.07, p=.007) and do **not** compound (interaction ≈ 0,
p = 0.85) — they simply stack. The 2×2 above quantifies the full range: 0.049 to
0.235. The most rigorous cell is also the best powered (k = 66), so the ~0.05
floor is the most trustworthy single estimate in the entire analysis.

## 5. What did NOT moderate (the honest nulls)

We coded and tested many candidates; most returned null, which matters for not
over-claiming:

- **Curriculum-coupled PD** (bundled 0.086 vs practice-only 0.038) looked strong
  bivariately (p = 0.06) but is confounded with TPD goal (Cramér's V = 0.51) and
  attenuates to non-significance when adjusted.
- **Delivery mode** (in-person/blended/online), **coaching intensity** (flat
  across none/occasional/frequent), **cascade depth**, **developer-delivered**,
  **counterfactual strength** (active vs business-as-usual), and **program
  maturity** were all null between studies. The vivid within-study "efficacy→
  effectiveness decay" several studies show (e.g. a protocol that works
  researcher-led and nulls under a train-the-trainer cascade) did **not**
  generalize to a between-study pattern for delivery/cascade/counterfactual —
  only the *evaluator* facet held up.
- **Outcome timing** is near-constant (118/124 measured immediately) and
  **teacher monetary incentives** are essentially absent from the literature —
  neither can be a moderator here, but both are findings about the field.

## 6. Limitations

- **4 of 128 studies unextracted** (2 confirmed duplicates, 2 unidentifiable);
  the replication baseline (overall 0.070 vs the paper's 0.090) is slightly low
  for compositional reasons documented in `WRITEUP.md`.
- **Evaluator/publication collinearity (0.59)** and the thin off-diagonal and
  independent-proximal cells mean the disentangling, though directionally clear,
  cannot be proven decisively.
- These moderators are **exploratory and observational** — associations, not
  causal effects; the curriculum-coupling case shows how confounding can mislead.
- Coding is from publications only (the original authors augmented theirs with 115
  interviews), so some cells are "not reported."

## 7. Implication

For anyone consuming TPD evidence: weight **independently-evaluated trials using
independent standardized tests** most heavily. In that subset, teacher PD's
average effect on achievement is small but real (~0.05). Treat larger published
averages as partly an artifact of evaluation and measurement choices.

## Reproducibility

```bash
Rscript R/02_models.R                              # replication baseline
KEEP_RESEARCHER_MADE=1 OUT_FILE=data/extracted/effect_sizes_with_aligned.csv \
  uv run scripts/merge_pilot.py
ICC_ASSUMED=0.20 ES_FILE=data/extracted/effect_sizes_with_aligned.csv \
  Rscript R/05_alignment.R                         # test alignment
Rscript R/06_implementation_moderators.R           # evaluator + implementation moderators
```
Results: `data/results/{alignment_extension,implementation_moderator_results,
new_moderator_results,moderator_discovery_synthesis}.md`.
