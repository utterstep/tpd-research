# Brief — bottom-up moderator discovery

Goal: read your assigned primary studies and **propose candidate moderators** —
study-level features that could plausibly explain *why some teacher PD raises
student achievement and some does not*. We will aggregate suggestions across all
124 studies to decide which new moderators to code and test next.

This is DISCOVERY, not coding. Ground every suggestion in what you actually see in
your papers (a feature that genuinely **varies** across studies, or that a study's
own authors flag as important). Quality over quantity: 4–8 sharp suggestions per
batch. Use short evidence notes, not long quotations.

## Already coded — do NOT re-propose these
Visscher et al. already coded: study design (RCT/QED), assignment unit, publication
status, sample size, SES, targeted population, TPD goal, number of TPD hours, TPD
trainer (researcher/developer vs external), the four learning-theory principles
(coaching, performance standards, self-regulation, cooperation) and their count,
tested subject, grade level, country.
We have ALSO already coded/tested: delivery mode (in-person/blended/online), test
alignment (proximal/distal), curriculum-coupled (PD + new materials vs not),
outcome timing (immediate/delayed), and teacher monetary incentives (found absent).
Do not re-propose any of the above. Propose things BEYOND this set.

## What makes a good suggestion
- **Varies** across studies (so it can be a moderator), ideally with a plausible
  mechanism linking it to student achievement.
- Examples of the *kind* of thing (not a checklist — find your own): coaching
  dose/frequency/ratio; who delivers in-class support; degree of scripting /
  structure of the PD; whether teachers practiced/rehearsed with feedback;
  intervention duration in weeks; intensity (hours per week); group size of PD
  cohorts; teacher buy-in / voluntariness; baseline teacher knowledge or
  experience; implementation fidelity *as reported* (note: post-treatment);
  student baseline achievement level; dosage of the student-facing component;
  whether the PD targets a narrow skill vs broad practice; technology intensity;
  program developer involvement in delivery; country/system beyond US-UK; year/
  recency; attrition magnitude; etc. Surface whatever your papers actually suggest.

## Output — write `data/moderator_ideas/<chunkN>.json`
```json
{
  "chunk": <N>, "studies": ["<slug>", ...],
  "suggestions": [
    {
      "moderator": "<short name>",
      "definition": "<what it is + candidate levels>",
      "rationale": "<why it might moderate TPD -> achievement>",
      "studies_observed": ["<slug>", ...],   // which of YOUR batch show it vary / discuss it
      "reportability": "usually_reported | sometimes | rarely",
      "strength": "strong | moderate | weak"   // your judgment of promise
    }
  ]
}
```
Return a compact summary: the suggested moderator names + strength, and any one
cross-cutting pattern you noticed.
