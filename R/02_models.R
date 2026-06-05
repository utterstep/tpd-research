## 02_models.R -- replicate the meta-analytic models of Visscher et al. (2025).
##
## Maps directly onto the paper:
##   fit_null()          -> RQ1 overall effect (g=0.09 [0.07,0.11]) + 95% PI [-0.15,0.32]
##                          + % true effects beyond {0, .05, .20}
##   fit_confirmatory()  -> Table 4 / Table S5.1 (pub status, SES, grade, subject, goal)
##   fit_exploratory()   -> Table 5 (+ trainer, hours, #principles)
##   sens_rho()          -> Table S4.1   sens_winsor() -> Table S4.2
##   fit_confirmatory(ses="3cat") -> Table S4.3        selection_model() -> Table S4.4
##
## Engine: robumeta correlated-effects (CORR) model, rho = 0.08, small-sample
## corrections (small = TRUE); multi-constraint moderator tests via clubSandwich.
##
## Run:  Rscript R/02_models.R      (uses ES_FILE or the synthetic fixture)

suppressPackageStartupMessages({
  library(robumeta); library(clubSandwich); library(dplyr)
})

ROOT <- getwd()
if (!file.exists(file.path(ROOT, "R", "01_data.R")))
  ROOT <- normalizePath(file.path(ROOT, ".."), mustWork = FALSE)
p <- function(...) file.path(ROOT, ...)
RHO <- 0.08

dat <- source(p("R", "01_data.R"), local = TRUE)$value
dir.create(p("data", "results"), showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------------------
## RQ1: null correlated-effects model
## ---------------------------------------------------------------------------
fit_null <- function(d, rho = RHO) {
  robu(g ~ 1, data = d, studynum = factor(cluster), var.eff.size = v,
       rho = rho, modelweights = "CORR", small = TRUE)
}

null_summary <- function(m) {
  rt <- m$reg_table
  tau2 <- m$mod_info$tau.sq
  se <- rt$SE[1]; est <- rt$b.r[1]
  pi_hw <- 1.96 * sqrt(as.numeric(tau2) + se^2)      # 95% prediction interval
  list(est = est, se = se, ci = c(rt$CI.L[1], rt$CI.U[1]),
       tau2 = as.numeric(tau2),
       pi = c(est - pi_hw, est + pi_hw),
       k = m$N, n_es = m$M)
}

## % of true effects beyond a threshold.
## Point estimate is the parametric normal-approx Pr(theta > q) ~ N(est, tau2).
## When the raw effect sizes `d` are supplied we additionally use
## MetaUtility::prop_stronger's *calibrated* method (what the paper used), which
## is distribution-free and yields cluster-bootstrap CIs -- for exact matching on
## real data. Returns a named matrix (rows: parametric, calibrated).
prop_beyond <- function(est, tau2, se, qs = c(0, 0.05, 0.20), d = NULL) {
  tau <- sqrt(max(tau2, 0))
  par_est <- if (tau > 0) 1 - pnorm((qs - est) / tau) else as.numeric(est > qs)
  calib <- rep(NA_real_, length(qs))
  if (!is.null(d) && requireNamespace("MetaUtility", quietly = TRUE)) {
    calib <- vapply(qs, function(q) {
      r <- tryCatch(suppressWarnings(
        MetaUtility::prop_stronger(q = q, tail = "above",
                                   estimate.method = "calibrated",
                                   ci.method = "calibrated",
                                   dat = d, yi.name = "g", vi.name = "v",
                                   cluster.name = "cluster")),
        error = function(e) list(est = NA_real_))
      as.numeric(r$est)
    }, numeric(1))
  }
  out <- rbind(parametric = par_est, calibrated = calib)
  colnames(out) <- paste0(">", qs)
  out
}

## ---------------------------------------------------------------------------
## RQ2/RQ3: meta-regression + per-moderator omnibus Wald tests (clubSandwich)
## ---------------------------------------------------------------------------
fit_reg <- function(d, rhs) {
  f <- as.formula(paste("g ~", paste(rhs, collapse = " + ")))
  robu(f, data = d, studynum = factor(cluster), var.eff.size = v,
       rho = RHO, modelweights = "CORR", small = TRUE)
}

## omnibus test that all coefficients for a moderator's dummies are zero.
## NB: robumeta stores coefficient names in reg_table$labels (rownames are just
## 1..k), so we match on labels: a factor term's dummies all share the term as a
## name prefix (e.g. "grade3Secondary"), a continuous term matches its name exactly.
moderator_tests <- function(m, d, rhs) {
  labs <- as.character(m$reg_table$labels)
  res <- lapply(rhs, function(term) {
    idx <- if (is.factor(d[[term]])) grep(paste0("^", term), labs)
           else which(labs == term)
    if (!length(idx)) return(NULL)
    wt <- tryCatch(Wald_test(m, constraints = constrain_zero(idx), vcov = "CR2"),
                   error = function(e) NULL)
    if (is.null(wt)) return(NULL)
    data.frame(moderator = term, Fstat = round(wt$Fstat, 2), df_num = wt$df_num,
               df_denom = round(wt$df_denom, 1), p = round(wt$p_val, 4))
  })
  out <- do.call(rbind, Filter(Negate(is.null), res))
  if (is.null(out))
    out <- data.frame(moderator = character(), Fstat = numeric(),
                      df_num = numeric(), df_denom = numeric(), p = numeric())
  out
}

confirmatory_rhs <- function(ses = c("main", "3cat")) {
  ses <- match.arg(ses)
  c("publication_status", if (ses == "main") "ses_main" else "ses_3cat",
    "grade3", "tested_subject", "tpd_goal")
}

exploratory_rhs <- function(d) {
  base <- c(confirmatory_rhs("main"), "tpd_trainer", "n_principles")
  if (!all(is.na(d$tpd_hours))) base <- c(base, "tpd_hours")
  base
}

## ---------------------------------------------------------------------------
## Sensitivity analyses
## ---------------------------------------------------------------------------
sens_rho <- function(d, rhos = c(0, .2, .4, .6, .8, 1)) {
  do.call(rbind, lapply(rhos, function(r) {
    s <- null_summary(fit_null(d, rho = r))
    data.frame(rho = r, ES = round(s$est, 4), SE = round(s$se, 4),
               tau = round(sqrt(s$tau2), 4))
  }))
}

winsorize <- function(x, mult = 1.5) {
  q <- quantile(x, c(.25, .75), na.rm = TRUE); iqr <- diff(q)
  lo <- q[1] - mult * iqr; hi <- q[2] + mult * iqr
  pmin(pmax(x, lo), hi)
}
sens_winsor <- function(d) { d$g <- winsorize(d$g); fit_null(d) }

## ---------------------------------------------------------------------------
## Selection / weight-function model (publication bias) -- Table S4.4
## ---------------------------------------------------------------------------
## weightr has no clustering option, so we first collapse to ONE inverse-variance-
## weighted effect size per study (cluster) -- this keeps the weight-function
## model's independence assumption from being violated by multiple ES per study.
selection_model <- function(d, steps = c(0.025, 0.05, 0.10, 0.50, 1.00)) {
  if (!requireNamespace("weightr", quietly = TRUE)) return(NULL)
  agg <- d %>%
    dplyr::filter(is.finite(v), v > 0) %>%
    dplyr::group_by(cluster) %>%
    dplyr::summarise(w = sum(1 / v), g = sum(g / v) / w, v = 1 / w, .groups = "drop")
  cat(sprintf("(selection model on %d study-level effect sizes)\n", nrow(agg)))
  tryCatch(weightr::weightfunct(effect = agg$g, v = agg$v, steps = steps),
           error = function(e) { message("weightr failed: ", conditionMessage(e)); NULL })
}

## ===========================================================================
## RUN
## ===========================================================================
cat("\n================ RQ1: NULL MODEL ================\n")
m0 <- fit_null(dat); s0 <- null_summary(m0)
cat(sprintf("g = %.3f, SE = %.3f, 95%% CI [%.3f, %.3f]\n",
            s0$est, s0$se, s0$ci[1], s0$ci[2]))
cat(sprintf("tau^2 = %.4f (tau = %.3f); 95%% PI [%.3f, %.3f]\n",
            s0$tau2, sqrt(s0$tau2), s0$pi[1], s0$pi[2]))
cat(sprintf("studies(clusters) = %d, effect sizes = %d\n", s0$k, s0$n_es))
pb <- prop_beyond(s0$est, s0$tau2, s0$se, d = dat)
cat("Pr(true effect > q) [parametric]: ",
    paste(sprintf("%s=%.0f%%", colnames(pb), 100 * pb["parametric", ]), collapse = "  "), "\n")
if (!all(is.na(pb["calibrated", ])))
  cat("Pr(true effect > q) [calibrated]: ",
      paste(sprintf("%s=%.0f%%", colnames(pb), 100 * pb["calibrated", ]), collapse = "  "), "\n")
cat("[paper targets: g=0.09 [0.07,0.11]; PI [-0.15,0.32]; >0=85% >.05=65% >.20=12%]\n")

cat("\n============ RQ2/3: CONFIRMATORY MODEL ===========\n")
rhs_c <- confirmatory_rhs("main")
mc <- fit_reg(dat, rhs_c)
labeled <- function(m) { t <- m$reg_table[, c("labels","b.r","SE","CI.L","CI.U","prob")]
  t[, -1] <- round(t[, -1], 3); t }
print(labeled(mc), row.names = FALSE)
cat("\nOmnibus moderator tests (clubSandwich CR2):\n")
print(moderator_tests(mc, dat, rhs_c), row.names = FALSE)

cat("\n============== EXPLORATORY MODEL =================\n")
rhs_e <- exploratory_rhs(dat)
me <- fit_reg(dat, rhs_e)
print(labeled(me), row.names = FALSE)

cat("\n=========== SENSITIVITY: rho sweep (S4.1) ========\n")
print(sens_rho(dat), row.names = FALSE)

cat("\n========= SENSITIVITY: winsorized (S4.2) =========\n")
sw <- null_summary(sens_winsor(dat))
cat(sprintf("winsorized g = %.3f, 95%% CI [%.3f, %.3f]\n", sw$est, sw$ci[1], sw$ci[2]))

cat("\n============ SELECTION MODEL (S4.4) ==============\n")
sm <- selection_model(dat)
if (!is.null(sm)) print(sm) else cat("(skipped)\n")

## persist machine-readable outputs for 03_compare.R
saveRDS(list(null = s0, prop_beyond = pb,
             confirmatory = mc$reg_table, confirmatory_tests = moderator_tests(mc, dat, rhs_c),
             exploratory = me$reg_table, rho_sweep = sens_rho(dat),
             winsorized = sw),
        p("data", "results", "our_results.rds"))
cat("\nWrote data/results/our_results.rds\n")
