## 00_setup.R -- install/load the meta-analytic toolchain used by Visscher et al. (2025)
## Run once:  Rscript R/00_setup.R

repos <- "https://cloud.r-project.org"

pkgs <- c(
  "robumeta",     # correlated-effects (CE) model + RVE (their primary engine)
  "clubSandwich", # small-sample Wald tests for multi-constraint moderators
  "metafor",      # cross-check / rma.mv + robust()
  "weightr",      # weight-function selection model (publication-bias, Table S4.4)
  "MetaUtility",  # prop_stronger(): % of true effects beyond a threshold (cluster bootstrap)
  "readr", "dplyr", "tidyr", "stringr", "purrr"  # data wrangling
)

installed <- rownames(installed.packages())
missing <- setdiff(pkgs, installed)
if (length(missing)) {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = repos)
}

ok <- vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)
cat(sprintf("%-14s %s\n", pkgs, ifelse(ok, "OK", "FAILED")))
if (!all(ok)) stop("Some packages failed to install; see above.")
cat("\nToolchain ready.\n")
