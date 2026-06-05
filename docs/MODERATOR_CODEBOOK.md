# Codebook — Tier-1 candidate moderators (study/report level)

Code these FOUR variables for each assigned study by reading its local PDF in
`data/fulltext/<slug>.pdf`. You may use the existing extraction record
`data/extracted/pilot/<slug>.json` (fields `design`, `notes`, `test_name`,
`test_type`, `problems`) as a hint, but verify against the PDF. Be targeted: use
`pdftotext <pdf> - | grep -i` on the intervention/method/measures sections rather
than reading cover-to-cover. Code at the level of the **TPD-vs-control study**
(the whole report); if arms differ, code the shared design.

For every variable, if the publication genuinely does not say, use the
`not_reported` / `not_clear` level — do NOT guess. Give a one-line evidence note
with a page/section ref for each.

## 1. delivery_mode — how TEACHERS received the PD
(Not about any student-facing digital tool. A "TPD for digital tools" study can
still be delivered in person.)
- `in_person` — all/primarily face-to-face: workshops, summer institutes, on-site
  coaching, in-school meetings.
- `blended` — a genuine mix of in-person AND online/remote components.
- `online` — all/primarily online/remote: webinars, web platform, self-paced
  digital modules, remote/virtual coaching, video conferencing.
- `not_reported`.

## 2. test_alignment — alignment of the OUTCOME measure(s) used for the included
effect size(s) to the intervention content
- `aligned` — outcome is developer/researcher-made, or a standardized test that
  narrowly targets exactly what the intervention taught (proximal).
- `independent` — outcome is a broad independent standardized test (state
  assessment, NWEA/MAP, GRADE, ITBS, general achievement battery) not tailored to
  the intervention (distal).
- `mixed` — the study's included outcomes include both kinds.
- `not_clear`.
(Hint: `test_type` in the extraction JSON already flags
`standardized_independent` vs `researcher_made` per effect size — aggregate it,
but also judge proximal-vs-distal *among* standardized tests.)

## 3. curriculum_coupled — is the PD bundled with a NEW curriculum/materials?
- `bundled` — PD is tied to adopting a specific new curriculum, program, textbook,
  software, or instructional-materials package that teachers then use.
- `practice_only` — PD aims to improve teachers' knowledge/practice using the
  existing curriculum; no new curriculum/materials provided.
- `not_clear`.

## 4. outcome_timing — when the achievement outcome(s) for the included effect
size(s) were measured, relative to the END of the intervention
- `immediate` — same school year / at the end of the intervention.
- `delayed` — measured ≥1 year after the intervention ended (follow-up/maintenance,
  or a later-year measurement after treatment stopped).
- `both` — study reports both immediate and a delayed follow-up.
- `not_clear`.
(Code the wave(s) the EXTRACTED effect sizes came from — see the extraction JSON's
per-effect `timepoint`/`notes`.)

## Output — write ONE file per study: `data/moderators/<slug>.json`
```json
{
  "slug": "<slug>", "study": "<short cite>",
  "delivery_mode": "...", "delivery_evidence": "<note + p./section>",
  "test_alignment": "...", "test_alignment_evidence": "...",
  "curriculum_coupled": "...", "curriculum_evidence": "...",
  "outcome_timing": "...", "outcome_timing_evidence": "...",
  "confidence": "high|medium|low"
}
```
Return a compact one-line-per-study summary (slug + the 4 codes + confidence). Do
not dump PDF text.
