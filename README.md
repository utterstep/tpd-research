# Replication & extension — Visscher et al. (2025) TPD meta-analysis

Independent re-derivation **and extension** of **Visscher, Dmoshinskaia,
Pellegrini & Rey-Naizaque (2025), "(When) do teacher professional development
interventions improve student Achievement? A meta-analysis of 128 high-quality
studies"**, *Educational Research Review* 49, 100742.
https://doi.org/10.1016/j.edurev.2025.100742

**Read first:**
- `WRITEUP.md` — the replication report (with executive summary).
- `EXTENSION_WRITEUP.md` — the extension: how much of the measured TPD effect is
  a research artifact (test alignment × evaluator independence).
- `REPLICATION_EXTENSION_METHODOLOGY.md` — generic blueprint for applying this
  approach to *other* meta-analyses.

## Headline results

**Replication (124/128 studies re-extracted; 111 clusters, 340 effect sizes):**

| Quantity | Our re-derivation | Visscher et al. |
|---|---|---|
| Overall effect | g = 0.070 [0.051, 0.089] | 0.09 [0.07, 0.11] |
| 95% prediction interval | [-0.14, 0.28] | [-0.15, 0.32] |
| Published / Unpublished | 0.093 / 0.047 | 0.10 / 0.05 |
| Publication-status moderator | F = 9.27, p = 0.003 | p = .003 |
| SES / grade / subject / TPD goal | all null | all null |

Every substantive claim reproduces. The overall sits slightly below 0.09 for
documented compositional reasons (4 missing studies; balanced vs publication-
tilted mix; studies contributing zero usable achievement effects).

**Extension (the artifact thesis):** two independent, additive levers inflate the
measured effect — *which test* (intervention-aligned vs independent) and *who
evaluates* (developer vs independent). Cleanest cell (independent evaluation ×
independent test, k = 66): **g ≈ 0.05**. Most developer-favorable cell: **g ≈
0.24** (~4.8× swing, p < .001). Details and caveats in `EXTENSION_WRITEUP.md`.

**Data-quality findings** (only visible from primary sources): ≥2 duplicate
studies in the original N=128 (Jacob rows 52≈53; Miller≈Sloan = same EEF Success
for All report), one included study with no achievement outcome (Borman 2021),
one non-BAU control (Simmons 2011), several moderator mis-codings (Cordray,
Wijekumar, Fancsali, Portes). See `WRITEUP.md` §3 and `OPEN_QUESTIONS.md`.

## Goal & scope

We **independently re-derive** the meta-analytic results starting from the
**already-filtered set of 128 included studies** — i.e. we do *not* reproduce the
3,966-record search/screening (which relied on Covidence + 115 author interviews
and is not externally reproducible). We re-extract effect sizes from the primary
studies and re-run the models in **R** with the authors' own toolchain
(`robumeta` CE+RVE ρ=0.08, `clubSandwich`, `weightr`, `MetaUtility`), then code
and test new moderators.

### What proved reproducible

| Part | Outcome |
|------|---------|
| Included-study list + moderator codings | ✅ recovered from supplement (S3.1/S3.2), cross-validated vs Table 3 |
| The 356 effect sizes | ✅ re-extracted: 735 raw → 340 included (vs their 356) from 124/128 studies |
| RQ1 overall effect, PI, publication-bias gap | ✅ reproduced (table above) |
| RQ3 study/design moderators | ✅ reproduced (same significance pattern) |
| The 4 learning-theory principles | ⚠️ interview-coded by the authors; not testable from publications alone |
| Continuous TPD hours | ❌ supplement gives only Long/Short; needs author data |
| 4 studies | ❌ 2 confirmed duplicates (contribute nothing — correctly), 2 unidentifiable short-cites (`little_2014`, `reid_2014`) |

## Layout

```
1-s2.0-...-main.pdf            # the article
1-s2.0-...-mmc1.docx           # the online supplement (study list + codings)
WRITEUP.md                     # replication report
EXTENSION_WRITEUP.md           # artifact-thesis extension report
REPLICATION_EXTENSION_METHODOLOGY.md  # generic blueprint for other meta-analyses
OPEN_QUESTIONS.md              # deferred judgment calls (Simmons, Thiede, Borman)
MODERATOR_CANDIDATES.md        # top-down candidate-moderator scan
docs/
  EXTRACTION_SPEC.md           # per-study effect-size extraction contract (subagents)
  MODERATOR_CODEBOOK.md        # tier-1 moderators (delivery, alignment, curriculum, timing)
  MODERATOR_CODEBOOK_2.md      # implementation-conditions moderators (evaluator, cascade, ...)
  MODERATOR_DISCOVERY_BRIEF.md # bottom-up discovery brief (agents propose moderators)
scripts/
  extract_supp_tables.py       # docx -> data/published/*.csv
  build_registry.py            # S3.1 + S3.2 -> data/registry/studies.csv
  merge_pilot.py               # per-study JSONs -> effect_sizes.csv (inclusion rules;
                               #   KEEP_RESEARCHER_MADE=1 / OUT_FILE for the aligned variant)
  make_fixture.py              # synthetic effect sizes for smoke-testing R
R/
  00_setup.R                   # install the toolchain
  01_data.R                    # load + recode; central Hedges-2007 cluster correction (ICC env)
  02_models.R                  # null CE+RVE, confirmatory/exploratory, sensitivity, selection
  03_compare.R                 # our numbers vs published tables
  04_new_moderators.R          # tier-1 moderator tests
  05_alignment.R               # test-alignment extension (proximal vs distal, within-study)
  06_implementation_moderators.R  # evaluator independence + implementation moderators
  lib_effectsize.R             # Hedges (2007) cluster correction (self-tested at rho=0)
data/
  published/                   # comparison targets from the supplement
  registry/
    studies.csv                # 143 arms / 128 reports + the authors' codings
    LOCKED_studies.md          # resolution status of the last unresolved studies
  fulltext/                    # primary-study PDFs (124 studies)
  extracted/
    pilot/<slug>.json          # per-study extraction records (page-level traceability)
    effect_sizes.csv           # canonical included set (independent tests only)
    effect_sizes_with_aligned.csv  # + proximal/researcher-made (for the alignment analysis)
  moderators/                  # tier-1 codings        (+ moderators.csv)
  moderators2/                 # implementation codings (+ moderators2.csv)
  moderator_ideas/             # bottom-up discovery output (16 chunks)
  results/                     # *.md results docs + model outputs
email/data_request.md          # draft data request to the corresponding author (not sent)
```

## How to run

```bash
# 1. (re)build inputs from the supplement
uv run scripts/extract_supp_tables.py
uv run scripts/build_registry.py

# 2. R toolchain (once)
Rscript R/00_setup.R

# 3. replication
uv run scripts/merge_pilot.py                       # JSONs -> effect_sizes.csv
ICC_ASSUMED=0.20 Rscript R/02_models.R              # RQ1-RQ3 + sensitivity + selection
Rscript R/03_compare.R                              # vs published tables

# 4. extensions
Rscript R/04_new_moderators.R                       # tier-1 moderators
KEEP_RESEARCHER_MADE=1 OUT_FILE=data/extracted/effect_sizes_with_aligned.csv \
  uv run scripts/merge_pilot.py
ICC_ASSUMED=0.20 ES_FILE=data/extracted/effect_sizes_with_aligned.csv \
  Rscript R/05_alignment.R                          # test-alignment
ICC_ASSUMED=0.20 Rscript R/06_implementation_moderators.R   # evaluator independence etc.
```

## Models (map to the paper)

- **RQ1** — null correlated-effects (CE) model, RVE, ρ = 0.08, `robumeta`
  (`small = TRUE`); 95% PI; `prop_stronger` thresholds.
- **RQ2/RQ3 confirmatory** — meta-regression on publication status, SES, grade,
  tested subject, TPD goal; omnibus tests via `clubSandwich` CR2 (Table 4 / S5.1).
- **Exploratory** — + TPD trainer, hours, # principles (Table 5).
- **Sensitivity** — ρ sweep (S4.1), winsorized (S4.2), SES 3-category (S4.3);
  selection model on study-level aggregated effects (S4.4, `weightr`).
- **Effect sizes** — Hedges' *g*, pretest/covariate-adjusted where reported;
  central Hedges (2007) cluster correction for non-cluster-adjusted rows
  (`ICC_ASSUMED`, sensitivity-checked 0–0.20).

## Extraction pipeline (subagent-driven)

One subagent per study (`docs/EXTRACTION_SPEC.md`): resolve citation → obtain the
PDF (legal open access; user-supplied via institutional access for the paywalled
remainder) → extract every qualifying TPD-vs-control achievement contrast with
page refs → `data/extracted/pilot/<slug>.json`. `scripts/merge_pilot.py` applies
explicit inclusion rules (independent test, full sample, non-redundant, variance
present; every row keeps `include`/`exclude_reason`) with **cluster = report**.
Unidentifiable short-cites were resolved by **fingerprint matching** (the
supplement's codings + the source reviews' study lists) — see
`data/registry/LOCKED_studies.md` for the final per-study resolution.

## Known reconciliation items (vs the authors' materials)

- **Supplement vs Table 3 off-by-ones** (`tpd_trainer` 103 vs 102; `n_principles`
  Zero 20/Two 38 vs 19/39) and the `Jerrim 2015/2015a` naming split — flagged,
  not silently fixed.
- **SES** `High SES` (n=1) folded into Average/High; `Not reported` → Average/High
  in the main model (the paper's assumption; S4.3 variant kept separate).
- **Composite vs subscale / cross-subject composites** — our defaults documented
  in `merge_pilot.py`; exact original selection unknowable without author data.
- Deferred judgment calls live in `OPEN_QUESTIONS.md`.

## Status

- [x] Registry + R pipeline + fixture smoke test
- [x] All 128 studies attempted: 124 extracted (735 raw / 340 included effects)
- [x] Central cluster/ICC correction; inclusion rules finalized
- [x] Full replication vs published tables (`WRITEUP.md`)
- [x] Moderator discovery (top-down + bottom-up), tier-1 + implementation coding
- [x] Extension: test-alignment + evaluator-independence artifact analysis
      (`EXTENSION_WRITEUP.md`)
- [ ] Resolve `little_2014` / `reid_2014` + author correspondence (`email/`)
- [ ] Robustness pass on the artifact levers (leave-one-out, funnel on subsets)
