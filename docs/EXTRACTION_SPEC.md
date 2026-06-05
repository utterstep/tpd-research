# Effect-size extraction spec (read this fully before extracting)

You are independently re-extracting student-achievement effect sizes from ONE
primary study that was included in the meta-analysis:

> Visscher, Dmoshinskaia, Pellegrini & Rey-Naizaque (2025). "(When) do teacher
> professional development interventions improve student Achievement? A
> meta-analysis of 128 high-quality studies." *Educational Research Review* 49.

The intervention is **teacher professional development (TPD)**; the comparison is
**business-as-usual** (no alternative treatment); the outcome is **student
academic achievement**. Your job: find the report, get its PDF, and extract the
numbers needed to compute **Hedges' *g*** for each TPD-vs-control achievement
contrast, with full traceability.

## Effect-size definition (match the paper)

- **Hedges' *g*** = small-sample-corrected standardized mean difference,
  `g = J * d`, `J = 1 - 3/(4*df - 1)`. Positive = favors TPD.
- **Prefer covariate/pretest-adjusted** estimates (ANCOVA / HLM impact estimate),
  because the paper adjusted for pretest. If the report gives a model-based
  impact coefficient `b` and a pooled/standardizing SD `s`, use `d = b / s`.
- If only raw posttest means/SDs are available: `d = (M_t - M_c) / s_pooled`.
- **Variance**: record the impact estimate's SE if given (preferred). Otherwise
  `Var(d) = (n_t+n_c)/(n_t*n_c) + d^2/(2*(n_t+n_c))`, then `Var(g)=J^2*Var(d)`.
- **Cluster-randomized designs** (assignment = School or Teacher/Class): if the
  impact estimate + SE come from a multilevel model they already account for
  clustering — set `cluster_adjusted=true` and record `n_clusters` and `icc`
  (the design-effect ICC) if reported. If you can only compute *g* from
  student-level means/SDs, set `cluster_adjusted=false` and record `n_clusters`
  + `icc` so it can be corrected centrally (Hedges 2007). NEVER guess an ICC.

## What counts as an effect size (one row each)

One effect size per distinct **(arm × outcome subject × test × grade/sample ×
timepoint)** TPD-vs-control contrast. Guidance:

- **Timepoint**: extract the **immediate post-intervention** measurement. If the
  study spans multiple years, take the end-of-treatment wave; note other waves.
- **Test type**: record whether the test is **standardized/independent** (e.g.
  state test, NWEA, GRADE, ITBS) or **researcher/developer-made**. The paper
  included only independent measures, but extract whatever achievement outcomes
  are reported and label the type — we filter centrally.
- **outcome_subject** mapping: reading/literacy/ELA → `Reading`; math or science
  → `STEM`; writing/language/other → `Other`.
- Multiple TPD arms vs one control (this report may have several): one set of
  effect sizes per arm. Use the `row_id`(s) you were given to label arms.
- Do **not** invent numbers. If a needed statistic is missing, leave it null and
  explain in `notes`/`problems`.
- Set the **structured** fields `outcome_role` and `is_full_sample` on every
  record (do not bury this in prose). `outcome_role`: `primary` (the report's
  headline/confirmatory outcome), `secondary`, `composite` (an aggregate that
  subsumes other extracted outcomes, e.g. a total score or GCSE Attainment 8),
  `subscale` (a component of a composite you also extracted), or `subgroup` (a
  non-randomised subset such as FSM-eligible pupils). `is_full_sample=false` for
  any subgroup. Central merge logic keys on these fields, not on your notes.

## Procedure

1. **Identify** the exact publication (title, full citation, report number, DOI,
   URL) via web search. These pilot studies are mostly US **IES/NCEE** reports
   (ies.ed.gov) or UK **EEF** reports (educationendowmentfoundation.org.uk),
   which publish full PDFs openly.
2. **Download** the main report PDF with curl to `data/fulltext/<slug>.pdf`
   (slug = lowercase author_year, e.g. `garet_2008`). Verify it downloaded
   (non-trivial file size, is a PDF).
3. **Read** the PDF (use the Read tool with the `pages` parameter; locate the
   impact/results tables — usually an executive summary table plus detailed
   appendix tables).
4. **Extract** every qualifying contrast into the JSON below, citing the page and
   table for each number.
5. **Write** the JSON to `data/extracted/pilot/<slug>.json`.
6. **Return** a SHORT summary (see end). Do not dump the PDF text.

## Output JSON schema

```json
{
  "report": "<short cite you were given>",
  "rows": [<row_id, ...>],
  "citation": "<full APA citation>",
  "report_number": "<e.g. NCEE 2008-4030, or EEF project name>",
  "url": "<source URL of the PDF>",
  "pdf_path": "data/fulltext/<slug>.pdf",
  "pdf_downloaded": true,
  "design": "<RCT/QED; assignment level; #schools/classes; subject; grades>",
  "confidence": "high|medium|low",
  "problems": "<anything missing/ambiguous, or empty string>",
  "effect_sizes": [
    {
      "row_id": <int>,
      "arm_label": "<which TPD arm / which study within report>",
      "outcome_subject": "Reading|STEM|Other",
      "grade_band": "<e.g. K-2>",
      "test_name": "<instrument>",
      "test_type": "standardized_independent|researcher_made|unclear",
      "timepoint": "<e.g. post, spring Y1>",
      "n_t": <int|null>, "n_c": <int|null>,
      "n_clusters": <int|null>, "icc": <num|null>,
      "impact_estimate": <num|null>, "impact_se": <num|null>,
      "mean_t": <num|null>, "sd_t": <num|null>,
      "mean_c": <num|null>, "sd_c": <num|null>,
      "g": <num|null>, "g_var": <num|null>, "g_se": <num|null>,
      "g_method": "<how g was computed + which SD standardized it>",
      "pretest_adjusted": <true|false>,
      "cluster_adjusted": <true|false>,
      "outcome_role": "primary|secondary|composite|subscale|subgroup",
      "is_full_sample": <true|false>,
      "page_ref": "<p./Table>",
      "notes": "<per-effect notes>"
    }
  ]
}
```

## Return summary (your final message — keep it compact)

- Full citation + report number + URL
- PDF path and whether the download succeeded
- Number of effect sizes extracted, with each `g` (and test_type, subject)
- Your confidence and any blockers/ambiguities
- Do NOT include the raw PDF text or the full JSON; it's already written to disk.
