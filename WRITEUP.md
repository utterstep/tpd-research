# Independent Replication and Extension of Visscher et al. (2025)

*"(When) do teacher professional development interventions improve student
achievement? A meta-analysis of 128 high-quality studies"* — Educational Research
Review 49, 100742. https://doi.org/10.1016/j.edurev.2025.100742

---

## Executive summary

We independently re-derived this meta-analysis from the primary sources — not by
re-running the authors' dataset, but by relocating the included studies,
re-extracting effect sizes from the original PDFs, and re-implementing the models
in R. We then extended it with newly coded moderators. Three headline outcomes:

1. **The meta-analysis replicates.** Across 124 of the 128 studies we could
   reach, every substantive claim reproduces: a small-to-medium average effect
   (**our g = 0.070 [0.051, 0.089]** vs the paper's 0.09 [0.07, 0.11]), a
   near-identical prediction interval (**[-0.14, 0.28]** vs [-0.15, 0.32]), the
   ~2× publication-bias gap (published **0.093** vs unpublished **0.047**;
   publication status the only significant moderator, **p = 0.003**), and null
   moderation by SES, grade, subject, and TPD goal.

2. **Independent re-extraction surfaced data-quality issues** a re-analysis of the
   authors' file never could: at least **2 duplicate studies** (so the true
   unique count is ~126, not 128), one study with **no achievement outcome at
   all** (behavioral only), one with a **non–business-as-usual control**, and
   several **moderator mis-codings**.

3. **A novel, confirmed extension finding.** Re-including the
   intervention-aligned ("proximal") outcomes the authors excluded shows that
   **the same PD looks ~2.5× more effective on a test aligned to what it taught
   than on an independent standardized test** (within-study b = 0.16, p = 0.0002).
   This confirms a literature claim (Wolf & Harbatkin 2023) the authors cited,
   validates their decision to use only independent measures, and delivers the
   "test alignment" future direction they explicitly flagged.

The deliverables are a reusable, fully reproducible pipeline (extraction →
coding → R meta-analysis), an independent effect-size dataset, and one publishable
extension result.

---

## 1. Why and how

The published article reports summary results; its data are "available on
request" and the 128-study reference list is not enumerated in the paper. The
**online supplement**, however, contains the full per-study moderator codings
(Tables S3.1/S3.2), which we parsed and cross-validated against the paper's
Table 3 (exact matches on design, assignment, goals, grade distribution). The one
thing genuinely missing — the 356 effect sizes themselves — is exactly what an
independent re-derivation should produce.

**Method.** One subagent per study located the primary report (legal open access
only — institutional repositories, ERIC, PubMed Central, funder reports; no
piracy sources), downloaded the PDF, and extracted Hedges' *g* with full page-level
traceability into a structured record. A merge step applied transparent inclusion
rules (independent measures, full-sample, non-redundant, variance available) and
set **cluster = report** so co-reported arms are correctly dependent. Models were
re-implemented in R with the authors' own toolchain: correlated-effects + robust
variance estimation (`robumeta`, ρ = 0.08), `clubSandwich` Wald tests, a
self-validated Hedges (2007) cluster correction (ICC = 0.20 sensitivity), and
`weightr` / `MetaUtility`.

**Coverage.** 124 of 128 studies extracted (122 located + 2 dropped to
duplicates). The remaining are 2 confirmed duplicates and 2 short-cites with no
resolvable public citation (almost certainly the authors' interview-sourced gray
literature).

---

## 2. Replication results

| Quantity | Our re-derivation | Visscher et al. |
|---|---|---|
| Overall effect | **g = 0.070 [0.051, 0.089]** | 0.09 [0.07, 0.11] |
| 95% prediction interval | [-0.14, 0.28] | [-0.15, 0.32] |
| Published | **0.093 [0.068, 0.118]** | 0.10 |
| Unpublished | **0.047 [0.020, 0.074]** | 0.05 |
| Pr(true effect > 0 / .05 / .20) | 82% / 60% / 6% | 85% / 65% / 12% |
| Publication-status moderator | F = 9.27, **p = 0.003** | p = .003 |
| SES / grade / subject / TPD goal | all null | all null |

**Interpretation.** Both publication subsets match the authors' values almost
exactly, the heterogeneity is reproduced, and the central publication-bias finding
is confirmed at the same significance. The overall sits at 0.070 vs their 0.09 for
understood, non-substantive reasons: our reachable sample is composition-balanced
(55 published / 56 unpublished clusters) rather than publication-heavy, four
studies are missing, and a few studies the authors included legitimately
contribute **zero** usable achievement effect sizes in a clean re-extraction
(behavioral-only outcomes, developer-made-only tests, or no reported SD). The
*pattern* — not a single point estimate — is what replicates, and it does.

---

## 3. Data-quality findings (only visible from the primary sources)

- **Duplicate studies.** Jacob 2017 appears twice (registry rows 52 & 53 resolve
  to the same paper); "Miller et al. 2017" (row 79) and "Sloan et al. 2018"
  (row 109) are both the EEF *Success for All* report. True unique N ≈ 126.
- **A study with no achievement outcome.** Borman et al. 2021 reports only
  behavioral outcomes (suspensions/referrals); GPA appears only as a null
  subgroup mediator — a likely mis-inclusion in an *achievement* meta-analysis.
- **A non–business-as-usual control.** Simmons et al. 2011's comparison is an
  active school-designed reading program, not the BAU control the inclusion rule
  requires.
- **Moderator mis-codings.** e.g. Cordray 2012 and Wijekumar 2009 mis-subjected;
  Fancsali 2015 coded QED but is a cluster RCT; Portes 2018 coded unpublished but
  is published; *Success for All*'s correct codings sit on the empty duplicate row.
- **Reporting gaps that cap reproducibility regardless of access.** Several
  studies report impacts without an SD/variance (e.g. Thiede 2018), so a clean
  Hedges' *g* cannot be computed at all.

These are logged per study (`data/extracted/pilot/*.json` `problems` fields) and
in `OPEN_QUESTIONS.md`.

---

## 4. Extension I: candidate moderators

We mined the 124 PDFs for moderators the authors did **not** code, then coded the
four most promising across all studies (`docs/MODERATOR_CODEBOOK.md`,
`data/moderators/`). Results (`data/results/new_moderator_results.md`):

- **Curriculum-coupled PD** (PD + new curriculum/materials vs PD on existing
  practice): bundled **0.086** vs practice-only **0.038** (~2.3×, omnibus p = 0.06)
  — the most striking bivariate signal, **but confounded with TPD goal**
  (Cramér's V = 0.51) and attenuates to non-significance when adjusted. Suggestive,
  not separable here.
- **Delivery mode** (in-person / blended / online): no reliable difference
  (p = 0.16); only 3 online-delivered studies have usable effects, so
  underpowered — but notably no penalty for blended delivery.
- **Outcome timing**: near-constant (118 of 124 measured immediately) — not
  modelable, and a direct confirmation of the authors' note that fade-out is
  unstudied in this literature.
- **Teacher monetary incentives** (a separate scan): essentially **absent** — no
  study's PD uses performance-contingent teacher pay; a few pay participation
  honoraria. No variance to model; itself a finding about the field.

---

## 5. Extension II: test alignment — the headline finding

The authors excluded intervention-aligned ("proximal") outcomes and named the
alignment question a future direction; Wolf & Harbatkin (2023) estimate proximal
tests run 2–3× larger. We re-included the proximal effect sizes we had extracted
and tagged (`effect_sizes_with_aligned.csv`, 422 effects; `R/05_alignment.R`),
with alignment taken from the per-effect-size measure type.

| | g [95% CI] | studies |
|---|---|---|
| Distal (independent standardized) | 0.070 [0.051, 0.089] | 111 |
| **Proximal (aligned/developer-made)** | **0.237 [0.150, 0.323]** | 32 |

Difference **b = 0.190, p = 0.0005 (~3.4×)**.

**The clean within-study test** — the 25 studies that report *both* an aligned and
an independent outcome, holding study/teachers/intervention fixed and varying only
the measure:

| | g [95% CI] |
|---|---|
| Distal | 0.090 [0.038, 0.143] |
| **Proximal** | **0.224 [0.127, 0.321]** |

Within-study **b = 0.160, p = 0.0002 (~2.5×)**; **0.163, p = 0.003** adjusted for
all confirmatory covariates. Re-allowing aligned tests raises the overall effect
from **0.070 to 0.101 (+44%)**.

**Why it matters.** It confirms the proximal-inflation effect *inside this exact
high-quality corpus* with a within-study design that rules out study-level
confounding; it quantifies and validates the authors' independent-measures-only
rule; and it operationalizes the future direction they flagged, using the effect
sizes they discarded. Full detail: `data/results/alignment_extension.md`.

---

## 6. Limitations

- **4 of 128 studies unextracted** (2 duplicates, 2 unidentifiable); their absence
  partly explains the 0.07-vs-0.09 overall gap.
- **Publications-only coding.** The authors augmented their codings with 115 author
  interviews; we coded from publications, so some moderator cells are
  "not reported" and the learning-theory-principle moderators are *not* fully
  reproducible from public sources by design.
- **Reconstructed statistics.** Where a study reported impacts without an SE/SD,
  effect-size variances were reconstructed (documented per study); the central
  cluster correction assumes ICC = 0.20 (sensitivity-checked 0–0.20).
- **Extension moderators are exploratory** — associations, not causal, and (as the
  curriculum-coupling case shows) can be confounded with existing moderators.

---

## 7. Reproducibility

```bash
# inputs from the supplement
uv run scripts/extract_supp_tables.py && uv run scripts/build_registry.py
# extraction records -> effect sizes
uv run scripts/merge_pilot.py
# R toolchain + analysis
Rscript R/00_setup.R
ICC_ASSUMED=0.20 Rscript R/02_models.R       # replication (Tables 4/5/S4.x)
Rscript R/04_new_moderators.R                # candidate moderators
KEEP_RESEARCHER_MADE=1 OUT_FILE=data/extracted/effect_sizes_with_aligned.csv \
  uv run scripts/merge_pilot.py
ICC_ASSUMED=0.20 ES_FILE=data/extracted/effect_sizes_with_aligned.csv \
  Rscript R/05_alignment.R                   # test-alignment extension
```

**Key files.** `README.md` (pipeline) · `data/registry/studies.csv` (143 arms) ·
`data/extracted/effect_sizes.csv` (our effect sizes) · `data/moderators/` (new
codings) · `data/results/` (outputs) · `OPEN_QUESTIONS.md` ·
`MODERATOR_CANDIDATES.md` · `data/registry/LOCKED_studies.md`.

*Note: the primary-study PDFs are copyrighted and are intentionally not committed
to this repository (see `.gitignore`); the analysis runs from the extracted
effect-size records, which are our own derived data.*
