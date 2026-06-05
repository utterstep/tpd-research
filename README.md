# Replication pipeline — Visscher et al. (2025) TPD meta-analysis

Independent re-derivation of **Visscher, Dmoshinskaia, Pellegrini & Rey-Naizaque
(2025), "(When) do teacher professional development interventions improve student
Achievement? A meta-analysis of 128 high-quality studies"**, *Educational
Research Review* 49, 100742. https://doi.org/10.1016/j.edurev.2025.100742

## Goal & scope

We **independently re-derive** the meta-analytic results starting from the
**already-filtered set of 128 included studies** — i.e. we do *not* reproduce the
3,966-record search/screening (which relied on Covidence + interviews with 115
researchers and is not externally reproducible). We re-extract effect sizes from
the primary studies and re-run the meta-analytic models in **R**, using the same
toolchain the authors used.

### What is reproducible vs. not

| Part | Reproducible from public materials? |
|------|--------------------------------------|
| Included-study list + moderator codings | ✅ Recovered from supplement (Tables S3.1/S3.2) |
| RQ1 overall effect (g = 0.09) | ✅ Re-derivable by re-extracting Hedges' *g* |
| RQ3 study/design moderators (grade, subject, pub status, SES, goal) | ✅ Codings public; re-derivable |
| The 4 learning-theory principles (RQ3 exploratory) | ⚠️ Authors used 115 **interviews** to code these; cannot be fully reproduced from publications alone |
| Continuous TPD **hours** | ❌ Supplement gives only Long/Short; need author data (see `email/`) |
| The 356 effect-size values + variances | ❌ Not public — this is exactly what we re-extract |

## Layout

```
1-s2.0-...-main.pdf          # the article
1-s2.0-...-mmc1.docx         # the online supplement (source of the study list + codings)
scripts/
  extract_supp_tables.py     # docx -> data/published/*.csv
  build_registry.py          # S3.1 + S3.2 -> data/registry/studies.csv
  make_fixture.py            # synthetic effect sizes for smoke-testing R
R/
  00_setup.R                 # install robumeta, clubSandwich, metafor, weightr, MetaUtility
  01_data.R                  # load registry + effect sizes, recode moderators
  02_models.R                # null CE+RVE, confirmatory/exploratory regression, sensitivity, selection
  03_compare.R               # our numbers vs published tables
data/
  published/                 # extracted comparison targets (S3.1, S3.2, S4.1-S4.4, S5.1)
  registry/studies.csv       # 143 arms / 128 reports + per-study moderator codes
  extracted/
    effect_sizes_TEMPLATE.csv  # schema for the re-extraction
    effect_sizes_FIXTURE.csv   # SYNTHETIC smoke-test data (not real)
    effect_sizes.csv           # <- the real re-extraction goes here
  results/                   # model outputs (our_results.rds)
email/data_request.md        # data request to the corresponding author
```

## How to run

```bash
# 1. (re)build inputs from the supplement
uv run scripts/extract_supp_tables.py
uv run scripts/build_registry.py
uv run scripts/make_fixture.py            # only needed for smoke-testing

# 2. R toolchain (once)
Rscript R/00_setup.R

# 3. analysis  (defaults to data/extracted/effect_sizes.csv; falls back to fixture)
Rscript R/02_models.R                      # smoke test on fixture
ES_FILE=data/extracted/effect_sizes.csv Rscript R/02_models.R   # real run
Rscript R/03_compare.R
```

## Models (map to the paper)

- **RQ1** — null correlated-effects (CE) model, RVE, ρ = 0.08, `robumeta`
  (`small = TRUE`). Targets: g = 0.09, 95% CI [0.07, 0.11]; 95% PI [-0.15, 0.32];
  Pr(true effect > 0 / .05 / .20) = 85% / 65% / 12% (`MetaUtility::prop_stronger`).
- **RQ2/RQ3 confirmatory** — meta-regression on publication status, SES, grade,
  tested subject, TPD goal; per-moderator omnibus tests via `clubSandwich`
  (Table 4 / S5.1).
- **Exploratory** — adds TPD trainer, hours, # learning-theory principles (Table 5).
- **Sensitivity** — ρ sweep (S4.1), winsorized outliers (S4.2), SES 3-category
  (S4.3); selection/weight-function model (S4.4, `weightr`).

## Known reconciliation items

- **129 vs 128 report groups.** Name-based grouping yields 129; one co-reported
  pair is split by inconsistent naming (`Jerrim et al. 2015` in S3.1 vs `2015a`
  in S3.2). Resolve when fetching that study.
- **Supplement vs Table 3 off-by-ones.** `tpd_trainer` Res/Dev = 103 in S3.2 but
  102 in Table 3; `n_principles` Zero = 20 / Two = 38 in S3.2 but 19 / 39 in
  Table 3. Minor source inconsistencies — flag, don't silently "fix".
- **SES `High SES` (n = 1)** is folded into `Average/High SES` (→ 60, matching the
  paper); `Not reported` (n = 28) → Average/High in the main model.

## Extraction (subagent-driven)

Each included study is extracted by one subagent (see `docs/EXTRACTION_SPEC.md`):
resolve citation → download open PDF to `data/fulltext/` → extract per the spec →
write `data/extracted/pilot/<slug>.json`. `scripts/merge_pilot.py` flattens the
JSONs into `data/extracted/effect_sizes.csv` with **cluster = report** and an
explicit `include` / `exclude_reason` per row.

### Gray-literature extraction (in progress)

**ALL ~62 unpublished reports attempted; 58 located & extracted** (100% hit rate
on findable open PDFs: US IES/NCEE/REL/MDRC/AIR/SRI/Harvard-CEPR + UK EEF/NFER).
236 raw effect sizes → **130 included across 55 clusters**. 4 not found, all
unidentifiable short-cites likely sourced via the authors' interviews: Heller
2012 (paywalled & likely a duplicate of Heller 2010), Miller 2017, Reid 2014,
Stokes 2018 (see `email/data_request.md`).

**Headline replication result (unpublished studies only, ICC=0.20):**
> **g = 0.047, 95% CI [0.019, 0.074]**, τ = 0.126

This independently reproduces the paper's *unpublished-subset* estimate of
**g = 0.05** almost exactly. Subgroup patterns track the paper's direction:
by goal (P)CK 0.06 → digital tools −0.01 (paper 0.10→0.04, same ordering); by
grade Primary 0.05 > Mixed 0.025 (paper 0.10>0.06). Adding the published studies
(which need institutional access) should pull the mean toward the headline 0.09
(published subset = 0.10).

Coding cross-checks surfaced vs the authors' supplement codings:
- **Cordray 2012** coded "digital tools/STEM" but measures reading only;
  **Wijekumar 2009** is math, not reading; several grade/assignment miscodes.
- **Fancsali 2015** coded QED but is a cluster RCT; **Portes 2018** coded
  "Unpublished" but is published in AERJ.
- Candidate **duplicates** to verify against the authors' data: Heller 2010 ≈
  Heller 2012 (same RCT); RAISE family (Fancsali 2015 / iRAISE / Jaciw 2016);
  **Miller 2017 (row 79) ≈ Sloan 2018 (row 109)** — both resolve to the EEF
  *Success for All* report (Miller, Biggart, Sloan & O'Hare 2017).
- Per-study details in each JSON `problems` field.

Coding cross-checks surfaced (vs the paper's supplement codings):
- **Cordray 2012** coded "TPD for digital tools" but the outcome is reading only.
- **Fancsali 2015** coded QED but is a cluster RCT.
- Several developer-made tests (Boylan CT, Cordray MAP, Finkelstein perf. task)
  correctly flagged `researcher_made` for central filtering.

## Open methodological decisions (reconcile vs author data)

- **Composite vs subscale.** Default keeps the composite/total, drops subscales
  (`exclude_reason=redundant_subscale`). The paper averaged ~2.8 ES/study, so it
  kept multiple outcomes — exact selection unknown without their dataset.
- **Cross-subject composites.** E.g. GCSE Attainment 8 (Other) overlaps GCSE
  English (Reading) + Maths (STEM); all three currently included. Flag.
- **Cluster correction not yet applied centrally.** Rows with
  `cluster_adjusted=false` (e.g. Gorard pupil-level SMD) need a Hedges (2007)
  correction using `n_clusters` + an assumed ICC; the email asks the authors for
  their ICC. Currently `v` is used as extracted (slightly over-precise).
- **SEs derived from p-values / CIs** for some studies (Garet 2016, James-Burdumy,
  EEF) — approximations; recorded in `g_method`/`notes`.
- **Inclusion flags must come from structured fields** (`outcome_role`,
  `is_full_sample`), not prose — a notes-scan once flagged a primary outcome as a
  subgroup. Spec updated; merge prefers structured fields.

## Status

- [x] Supplement extracted; study registry built and cross-validated vs Table 3
- [x] R analysis pipeline written; smoke-tested on synthetic fixture
- [x] Data-request email drafted
- [x] Subagent extraction harness + spec; **8-study pilot** extracted & analysed
- [ ] Scale extraction to the remaining ~120 reports (paywalled ones need access)
- [ ] Apply central cluster/ICC correction; finalise inclusion rules
- [ ] Run full analysis + compare to published Tables 4/5/S4.x/S5.1
