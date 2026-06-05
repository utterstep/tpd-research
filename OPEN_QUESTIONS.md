# Open questions / decisions to revisit

Deferred judgment calls in the replication. Each currently has a provisional
default (noted); revisit before any final write-up.

## 1. Simmons et al. 2011 (registry row 108) — active comparison, not business-as-usual?
The comparator is an **active** "typical practice intervention" (a school-designed
supplemental small-group reading program delivered for equal time by comparable
staff), **not** a no-treatment / business-as-usual control. Confirmed from the
paper (Exceptional Children 77(2); see `data/extracted/pilot/simmons_2011.json`
`problems`). The meta-analysis's stated inclusion rule requires business-as-usual
controls — so by that rule this study arguably should not be in the dataset.
Also borderline: the "TPD" is only ~2 days of interventionist training.

- **Current default:** INCLUDED (12 effect sizes; published; K-2 reading; g ≈ 0.05–0.51).
- **Decision needed:** keep (the authors included it) or exclude as failing the
  BAU-control criterion? Excluding would slightly lower the Published estimate.

## 2. Thiede et al. 2018 (registry rows 120-122) — no SD, Hedges' g not computable
Reports impacts in MAP (NWEA RIT) points with SEs but **no SD / variance
components anywhere**, so g cannot be standardized without an external SD. The
DMT arm (row 121) was significant (+1.54 MAP pts, p<.01); FA and DMT+FA n.s.

- **Current default:** contributes 0 usable effect sizes (g/v left null; agent
  correctly declined to guess an SD).
- **Decision needed:** supply the published NWEA MAP RIT SD (~15 for these grades)
  to compute g, or leave it out? Caveat: using an external standardizing SD is an
  assumption not applied anywhere else in this dataset.

## 3. Borman et al. 2021 (registry row 10) — no student-achievement outcome
The paper (AERJ 59(2); identity-based/values-affirmation intervention) reports
only **behavioral** outcomes (suspensions, office disciplinary referrals). GPA
appears solely as a Black-subgroup mediator and is null (b=0.04, p=.52). So a
study included in an *achievement* meta-analysis that does not measure academic
achievement at the full-sample level. See `data/extracted/pilot/borman_2021.json`.

- **Current default:** auto-EXCLUDED — its one effect size is flagged subgroup /
  not-full-sample, so the merge gives it 0 included effect sizes.
- **Decision needed:** confirm exclusion (recommended) and flag to the authors as
  a likely mis-inclusion, OR did they use a GPA/achievement outcome we should
  chase (the full Black-subgroup GPA table is online-only, not in the PDF)?
