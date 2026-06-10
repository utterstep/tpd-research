# Replicating & extending a published meta-analysis with agentic pipelines

A blueprint, distilled from doing this end-to-end for Visscher et al. (2025)
(teacher PD → student achievement; this repo is the worked example). Written for
teammates who want to apply the approach to **other meta-analyses**.

---

## The generic idea

A published meta-analysis is a *pipeline whose intermediate data is usually
hidden*: primary studies → coded effect sizes + moderators → statistical models →
headline claims. The paper publishes the two ends; the middle ("available on
request") is where both errors and judgment calls live.

The approach: **rebuild the middle yourself.** LLM subagents make the
historically-prohibitive step — reading ~100+ primary studies and extracting
effect sizes from each — cheap (days, not person-years). You then own an
independent dataset over the same study universe, which buys you three distinct
products:

1. **A replication verdict** — do the headline numbers reproduce from the primary
   sources? (Far stronger than re-running their spreadsheet: you re-derive it.)
2. **A data-quality audit for free** — duplicates, mis-codings, inclusion-rule
   violations, studies with no qualifying outcome. These are *invisible* in the
   authors' own dataset and only surface when someone independently re-reads the
   sources. We found ≥2 duplicate studies, one included study with no achievement
   outcome, one disallowed control condition, and several mis-coded moderators.
3. **An extension platform** — once you hold per-study PDFs + your own coded
   dataset, every new moderator is a cheap coding pass + one meta-regression. The
   original team would need a new grant for this; you need an afternoon.

The deepest extension wins come from **what the original excluded or didn't
code**. Our headline finding (test-aligned outcomes inflate effects ~2.5× within
study; developer-run evaluations ~2× across studies; additive) was built almost
entirely from effect sizes the original authors *discarded* and a moderator they
*didn't code*.

## When this works (candidate checklist)

Pick a target meta-analysis where:

- ✅ The **included-study list is recoverable** — ideally a supplement with
  per-study tables (our case: codings in the supplement, full citations *not*
  published, recovered via search + "fingerprint" matching). If neither a list
  nor codings exist anywhere, stop.
- ✅ **Published numbers exist to compare against** (overall effect, subgroup
  estimates, moderator tables). These are your ground truth for validation.
- ✅ The **primary literature is substantially accessible** — gray literature
  (government/funder reports) is ideal: open, detailed, and standardized.
  Education, development economics, and policy evaluation are good fields. A
  corpus that is 90% paywalled journals needs institutional access up front.
- ✅ The **effect-size arithmetic is reconstructible** — means/SDs, model
  coefficients + SEs, or test statistics in the primary papers. (Some studies
  will still report impacts with no SD — accept losses, document them.)
- ⚠️ Know the **irreproducible parts before you start.** Anything the authors
  coded from private sources (interviews, author correspondence) can't be matched
  from publications. Scope around it explicitly.

## Phase plan

Time estimates assume one person driving + subagent batches. Token costs scale
with corpus size; for ~125 studies the whole thing was a few tens of millions of
subagent tokens, run in batches of 8–14 agents.

### Phase 0 — Map the target (half a day)
Read the paper closely. Write down: effect-size metric and adjustments; the exact
model (software, estimator, ρ/ICC assumptions); every published number you can
later compare against (headline, subgroups, moderator tables, sensitivity
analyses); the inclusion rules; what data is public vs on-request. Decide the
replication scope (we skipped the search/screening phase — not reproducible —
and started from the included-study list).

### Phase 1 — Recover the study universe (a day)
Parse the supplement / appendix into a machine-readable **registry**: one row per
study arm, carrying every coding the authors published. **Cross-validate the
registry against the paper's descriptive table** (study counts per moderator
level) before going further — this catches parsing errors and *source
inconsistencies* (we found off-by-ones between supplement and paper; flag, don't
silently fix). The registry is the backbone: every later artifact joins to it.

### Phase 2 — Rebuild the analysis pipeline first (a day)
Re-implement the models in the **authors' own toolchain** (here: R `robumeta`
CE+RVE, `clubSandwich`, `weightr`) *before extracting any data*, and smoke-test
on a **synthetic fixture** with a planted true effect. This decouples "is the
statistics code right" from "is the data right" — when real data arrives you
trust the machinery. Include the auxiliary corrections (cluster/ICC adjustment)
as a self-tested library (test at the boundary where it must reduce to the
ordinary formula).

### Phase 3 — Pilot extraction (~8 studies, a day)
Write an **extraction spec** (`docs/EXTRACTION_SPEC.md` pattern): effect-size
definitions, what counts as one effect, which wave/sample, the JSON output
schema, and the rule *never invent numbers — null + explain*. Launch one subagent
per study on the easiest sub-corpus (gray literature). Then merge and run the
model on the pilot.

The pilot's real job is to break your assumptions cheaply. Ours caught a real
bug (inclusion decisions scanned free-text notes and mis-flagged a primary
outcome — fix: **structured fields, never prose**, for anything the merge logic
keys on) and calibrated the schema (added `outcome_role`, `is_full_sample`).

### Phase 4 — Scale extraction in batches (days, interleaved with access)
- Batch 8–14 agents at a time; expect platform session limits — design everything
  to be **resumable from disk** (one JSON per study is the unit of progress;
  re-running a batch is idempotent).
- **Legal sources only**: OpenAlex/Unpaywall/CORE/ERIC/PMC, funder & institutional
  repositories, author pages. No Sci-Hub/LibGen — and budget for a human with
  institutional access to backfill the genuinely paywalled remainder (in our
  case ~25 studies, supplied by the project owner in three rounds).
- Track the missing set in a **status file regenerated with a filesystem
  cross-check** (a study is "missing" only if there's no extraction *and* no PDF
  on disk — we once listed a study as locked while its PDF sat in the folder).
- For unidentifiable short-cites, use **fingerprint matching**: the registry's
  codings (design, grade, arms, duration, trainer…) are close to a unique key.
  Match against the *source reviews'* included-study lists (the meta-analysis
  names the reviews it drew from). This resolved 6 of our 8 unknowns — including
  two that turned out to be **duplicates** of already-extracted studies.

### Phase 5 — Merge + run + compare (a day)
Central merge with **explicit inclusion rules**, every row carrying
`include`/`exclude_reason` (subgroup, redundant subscale, researcher-made test,
no variance…). Key decisions to make deliberately: cluster = report (co-reported
arms share a control); composite-vs-subscale defaults; central cluster/ICC
correction only for rows not already model-adjusted. Run the full model suite and
compare against every published number from Phase 0. **Explain residual gaps
compositionally** (which studies/cells are missing and which direction that
biases) rather than hand-waving. Park unresolved judgment calls in an
`OPEN_QUESTIONS.md` so they don't silently become defaults.

### Phase 6 — Extension: moderator discovery + coding (2–3 days)
Two complementary discovery passes:
- **Top-down**: brainstorm + keyword-triage the corpus (`pdftotext | grep`) for
  candidate features; rank by coverage *and* whether they actually vary. Cheap,
  noisy, fast.
- **Bottom-up**: agents *re-read* the papers and propose moderators grounded in
  what the studies themselves vary on or flag. Aggregate suggestions across
  batches by family; convergence across independent agents is the signal. (Ours
  converged hard on "implementation/transmission chain" themes.)

Then: write a **codebook** (levels, decision rules, `unclear`-don't-guess, one
evidence note per code), code all studies via agent batches, merge as columns,
and test in the meta-regression — **each moderator singly, then jointly**.

### Phase 7 — Kill your own findings before believing them
The single most valuable phase. For every "new" moderator that hits:
- **Confound matrix** (Cramér's V vs every existing moderator). Our
  curriculum-coupling "finding" (p=.06, 2.3×) was 0.51-confounded with an
  existing moderator and died in the joint model.
- **"Is it an old moderator in disguise?"** Test explicitly: joint models with
  the established moderator (our evaluator-independence survived while
  publication status dropped out — *reversing* the disguise hypothesis); and
  recompute on subsets that hold the rival constant.
- **Within-study contrasts** where possible — the strongest design. Studies
  reporting both levels of your moderator (e.g. both aligned and independent
  tests) let you difference out all study-level confounds.
- **Check post-treatment status.** The most popular suggestions (fidelity, dose
  received, "did the mediator move") are *outcomes of the intervention* —
  moderating on them is collider/mediator bias. Use as descriptives only.
- Report the **nulls** prominently. They're what make the surviving finding
  credible.

### Phase 8 — Write-ups + hygiene
Two documents: a **replication report** (verdict + comparison tables + the
data-quality audit) and an **extension report** (the new findings, with the
confound work shown). Plus the methodology notes (this file). Keep a running
project memory so the work survives session boundaries. Draft (don't
auto-send) author correspondence: request the unresolvable items, and offer the
data-quality findings back — it's both courteous and the fastest path to closing
the last gaps.

## Hard-won pitfalls (read before starting)

1. **Structured fields, not prose**, for anything merge/inclusion logic reads.
2. **Cluster = report.** Author-year labels are not unique study keys — expect
   duplicates *in the published study list itself*, multi-arm reports, and
   inconsistent naming between supplement tables.
3. **Effect sizes without variances are unusable** in weighted models — exclude
   with a reason code, don't improvise an SD (park it as an open question).
4. **Some included studies will contribute nothing** under honest re-extraction
   (no qualifying outcome, no statistics). That's a finding, not a failure.
5. **Validate the machinery on synthetic data first**; validate codings against
   the paper's own descriptive tables; self-test statistical corrections at
   boundary conditions.
6. **Composition explains most replication gaps.** Before claiming a discrepancy,
   ask which cells you're missing relative to the original (ours: paywalled =
   published = larger effects → our overall ran low until backfilled).
7. **Plan around session/usage limits**: batch sizes ~8–14 agents, durable
   per-study files, idempotent re-runs, a status regenerator with filesystem
   cross-checks.
8. **Copyright**: extraction from PDFs you have legal access to is fine;
   *redistributing* the PDFs is a separate decision with real consequences —
   make it consciously (repo visibility, who supplied what).
9. **Don't trust one agent's judgment on judgment calls.** The spec/codebook
   should force evidence notes + page refs; spot-check; and let `unclear` be a
   first-class answer.
10. **The extension is only as novel as your confound work.** Assume every
    exciting new moderator is an old one in disguise until joint models and
    within-study contrasts say otherwise.

## Artifact checklist (what a finished project contains)

- [ ] Registry (per-arm, authors' codings, cross-validated)
- [ ] Extraction spec + per-study JSONs with page-level traceability
- [ ] Canonical effect-size CSV with `include`/`exclude_reason` + variant builds
- [ ] Analysis code in the original toolchain + synthetic fixture + self-tests
- [ ] Comparison-vs-published tables; compositional explanation of gaps
- [ ] Moderator codebooks + codings + discovery records
- [ ] Results docs incl. **nulls** and confound analyses
- [ ] OPEN_QUESTIONS.md, missing-studies status, draft author correspondence
- [ ] Replication report + extension report (each with an executive summary)
