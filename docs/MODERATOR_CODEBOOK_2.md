# Codebook v2 — implementation-conditions moderators (study/report level)

Code these SEVEN study-level variables for each assigned study. **Primary source:
the existing extraction record `data/extracted/pilot/<slug>.json`** (its `design`,
`problems`, `notes`, `citation` fields already summarize who delivered, scale,
control type, coaching, and any student component). Verify against the PDF
(`data/fulltext/<slug>.pdf`, targeted `pdftotext | grep`) ONLY where the JSON is
silent or ambiguous. Code at the level of the TPD-vs-control study.

Use `unclear` (never guess) where the publication does not say. One short
evidence note per variable.

## The "efficacy → effectiveness" cluster (3 vars)

1. **eval_independence** — who conducted/authored the impact evaluation?
   - `developer` — the program's developers/researchers conducted or co-authored it.
   - `independent` — a third party with no developer stake (IES/NCEE/REL contractor,
     EEF independent evaluator, independent eval firm).
   - `unclear`.

2. **developer_delivered** — did the developers / research team themselves deliver
   the PD to the teachers (vs trained intermediaries / the school system)?
   - `yes` | `no` | `unclear`.

3. **cascade_depth** — transmission hops from developer to the classroom teacher.
   - `developer_direct` — developer/research-team trainers train the teachers directly.
   - `cascade` — train-the-trainer / lead-teacher cascade (≥1 extra hop).
   - `unclear`.

## Standalone design moderators

4. **counterfactual** — what the control group got.
   - `business_as_usual` — no alternative / true BAU.
   - `active_or_contaminated` — control got an active alternative PD/program, OR BAU
     contaminated by similar practice (e.g. control already used the same assessment).
   - `unclear`.

5. **coaching_intensity** — ongoing in-class coaching the teacher received (ordinal).
   - `none` — workshop/course only, no ongoing in-class coaching.
   - `occasional` — a few coaching/observation visits, light or periodic support.
   - `frequent_inclass` — recurring in-class coaching cycles (≈monthly+ / biweekly+)
     in the teacher's own classroom.
   - `unclear`.

6. **added_student_dose** — does the intervention add a direct student-facing dose
   beyond the teacher's regular instruction?
   - `none` — only the teacher's regular instruction changes.
   - `student_component` — adds tutoring, pull-out small-group, extra instructional
     minutes, or a substantial student-facing software dose.
   - `unclear`.

7. **program_maturity** — measurement wave relative to program rollout.
   - `first_year` — outcomes measured in the program's first implementation year
     (teachers new to it).
   - `mature` — measured after ≥1 prior implementation year (experienced teachers).
   - `single_year_design` — program is designed as a single year (no maturity axis).
   - `unclear`.

## Output — write `data/moderators2/<slug>.json`
```json
{
  "slug": "<slug>", "study": "<short cite>",
  "eval_independence": "...", "eval_evidence": "<note>",
  "developer_delivered": "...", "developer_evidence": "<note>",
  "cascade_depth": "...", "cascade_evidence": "<note>",
  "counterfactual": "...", "counterfactual_evidence": "<note>",
  "coaching_intensity": "...", "coaching_evidence": "<note>",
  "added_student_dose": "...", "student_dose_evidence": "<note>",
  "program_maturity": "...", "maturity_evidence": "<note>",
  "confidence": "high|medium|low"
}
```
Return a compact one-line-per-study summary (slug + the 7 codes + confidence).
