## 01_data.R -- load registry + extracted effect sizes, recode moderators to the
## analysis categories used by Visscher et al. (2025), and assemble the analysis frame.
##
## Effect-size file is chosen via env var ES_FILE; if unset it falls back to the
## SYNTHETIC fixture so the pipeline is runnable before real extraction. A loud
## banner makes clear when synthetic data is in use.
##
## Produces: data.frame `dat` (one row per effect size) and writes
##           data/extracted/analysis_frame.rds

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr)
})

## locate repo root whether invoked from repo root or from R/
ROOT <- getwd()
if (!file.exists(file.path(ROOT, "data", "registry", "studies.csv"))) {
  cand <- normalizePath(file.path(ROOT, ".."), mustWork = FALSE)
  if (file.exists(file.path(cand, "data", "registry", "studies.csv"))) ROOT <- cand
}
p <- function(...) file.path(ROOT, ...)

es_file <- Sys.getenv("ES_FILE", unset = p("data", "extracted", "effect_sizes.csv"))
if (!file.exists(es_file)) {
  fixture <- p("data", "extracted", "effect_sizes_FIXTURE.csv")
  message(strrep("=", 70))
  message("WARNING: ", es_file, " not found.")
  message("Falling back to SYNTHETIC FIXTURE: ", fixture)
  message("Results below are NOT a replication -- fixture is fabricated data.")
  message(strrep("=", 70))
  es_file <- fixture
}

reg <- read_csv(p("data", "registry", "studies.csv"), show_col_types = FALSE)
es  <- read_csv(es_file, show_col_types = FALSE)

## --- recode registry moderators to analysis categories ---------------------
reg2 <- reg %>%
  mutate(
    grade3 = case_when(
      grade_level %in% c("Pre-k", "prek", "K-2", "3-6") ~ "Primary",
      grade_level == "7-12"                              ~ "Secondary",
      grade_level == "Mixed"                             ~ "Mixed",
      TRUE                                               ~ NA_character_
    ),
    ses_clean = if_else(ses == "High SES", "Average/High SES", ses),
    # main model: unreported SES treated as Average/High (paper's assumption)
    ses_main  = if_else(ses_clean == "Low SES", "Low SES", "Average/High SES"),
    ses_3cat  = ses_clean,                       # Low / Average/High / Not reported
    n_principles_num = recode(n_principles,
      Zero = 0, One = 1, Two = 2, Three = 3, Four = 4, .default = NA_real_),
    across(c(coaching, performance_standards, self_regulation, cooperation),
           as.integer)
  )

## continuous TPD hours are NOT in the supplement (only Long/Short). Use the
## extracted column if present, else NA (exploratory model degrades gracefully).
if (!"tpd_hours" %in% names(es)) es$tpd_hours <- NA_real_

## apply the analysis inclusion filter (set by scripts/merge_pilot.py)
if ("include" %in% names(es)) {
  n0 <- nrow(es); es <- dplyr::filter(es, include == 1)
  message(sprintf("Inclusion filter: %d -> %d effect sizes (include==1)", n0, nrow(es)))
}

## --- join effect sizes to study-level moderators ---------------------------
dat <- es %>%
  mutate(row_id = as.integer(row_id)) %>%
  left_join(reg2, by = "row_id", suffix = c("", ".reg")) %>%
  mutate(
    cluster        = coalesce(report_group, study),
    tested_subject = factor(outcome_subject, levels = c("Reading", "STEM", "Other")),
    publication_status = factor(publication_status, levels = c("Published", "Unpublished")),
    ses_main  = factor(ses_main,  levels = c("Average/High SES", "Low SES")),
    ses_3cat  = factor(ses_3cat,  levels = c("Average/High SES", "Low SES", "Not reported")),
    grade3    = factor(grade3,    levels = c("Primary", "Secondary", "Mixed")),
    tpd_goal  = factor(tpd_goal,  levels = c("(P)CK", "Comprehensive approaches",
                                             "TPD for curricula", "TPD for digital tools", "Other")),
    tpd_trainer  = factor(tpd_trainer, levels = c("Res/Dev", "External")),
    n_principles = factor(n_principles, levels = c("Zero", "One", "Two", "Three", "Four")),
    tpd_hours    = suppressWarnings(as.numeric(tpd_hours))
  )

## --- central Hedges (2007) cluster correction --------------------------------
## Applied ONLY to effect sizes computed from individual-level stats in a
## clustered design (cluster_adjusted is false). Rows already from a multilevel
## model keep their reported (cluster-robust) variance. ICC is a sensitivity
## parameter: per-row icc_assumed if >0, else env ICC_ASSUMED (default 0.20).
source(p("R", "lib_effectsize.R"), local = TRUE)
icc_default <- as.numeric(Sys.getenv("ICC_ASSUMED", unset = "0.20"))
is_adj <- function(x) tolower(trimws(as.character(x))) %in% c("true","yes","y","1","t")
icc_row <- suppressWarnings(as.numeric(dat$icc_assumed))
dat <- dat %>% mutate(
  g_raw = g, v_raw = v,
  n_t = suppressWarnings(as.numeric(n_t)),
  n_c = suppressWarnings(as.numeric(n_c)),
  n_clusters = suppressWarnings(as.numeric(n_clusters)),
  icc_used = ifelse(!is.na(icc_row) & icc_row > 0, icc_row, icc_default),
  needs_cc = if ("cluster_adjusted" %in% names(.)) !is_adj(cluster_adjusted) else FALSE,
  needs_cc = needs_cc & is.finite(n_t) & is.finite(n_c) &
             is.finite(n_clusters) & n_clusters > 1 & icc_used > 0
)
if (any(dat$needs_cc, na.rm = TRUE)) {
  cc <- suppressWarnings(
    cluster_correct(dat$g_raw, dat$n_t, dat$n_c, dat$n_clusters, dat$icc_used))
  ix <- which(dat$needs_cc %in% TRUE)
  dat$g[ix] <- cc$g[ix]; dat$v[ix] <- cc$v[ix]
  cat(sprintf("Cluster-corrected %d effect sizes (ICC=%.2f); mean SE inflation x%.2f.\n",
      length(ix), icc_default,
      mean(sqrt(cc$v[ix]) / sqrt(dat$v_raw[ix]), na.rm = TRUE)))
}

cat(sprintf("Loaded %d effect sizes across %d clusters.\n",
            nrow(dat), dplyr::n_distinct(dat$cluster)))
n_unresolved <- sum(is.na(dat$tested_subject))
if (n_unresolved) cat(sprintf("  %d effect sizes missing tested_subject.\n", n_unresolved))
if (all(is.na(dat$tpd_hours)))
  cat("  NOTE: continuous TPD hours absent -> exploratory model omits the hours term.\n")

saveRDS(dat, p("data", "extracted", "analysis_frame.rds"))
invisible(dat)
