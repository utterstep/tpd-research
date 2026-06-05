## 03_compare.R -- put our re-derived numbers next to the published values.
##
## Compares:
##   * headline overall effect vs paper (g=0.09 [0.07,0.11]; PI [-0.15,0.32])
##   * confirmatory conditional means vs Table S5.1 (data/published/S5.1_confirmatory.csv)
##   * rho sweep vs Table S4.1
##
## Run after 02_models.R:  Rscript R/03_compare.R

suppressPackageStartupMessages({ library(readr); library(dplyr); library(stringr) })

ROOT <- getwd()
if (!file.exists(file.path(ROOT, "data", "results", "our_results.rds")))
  ROOT <- normalizePath(file.path(ROOT, ".."), mustWork = FALSE)
p <- function(...) file.path(ROOT, ...)

ours <- readRDS(p("data", "results", "our_results.rds"))

cat("\n================ HEADLINE (RQ1) =================\n")
n <- ours$null
cat(sprintf("%-12s ours: g=%.3f [%.3f, %.3f]   paper: g=0.09 [0.07, 0.11]\n",
            "overall", n$est, n$ci[1], n$ci[2]))
cat(sprintf("%-12s ours: [%.3f, %.3f]          paper: [-0.15, 0.32]\n",
            "95% PI", n$pi[1], n$pi[2]))
pb <- ours$prop_beyond["parametric", ]
cat(sprintf("%-12s ours: >0=%.0f%% >.05=%.0f%% >.20=%.0f%%   paper: 85%% / 65%% / 12%%\n",
            "Pr(>q)", 100*pb[1], 100*pb[2], 100*pb[3]))

cat("\n=========== CONFIRMATORY vs Table S5.1 ==========\n")
pub_path <- p("data", "published", "S5.1_confirmatory.csv")
if (file.exists(pub_path)) {
  pub <- suppressWarnings(read_csv(pub_path, show_col_types = FALSE))
  cat("Published (S5.1):\n"); print(pub, n = nrow(pub))
} else cat("(no published S5.1 csv found)\n")
cat("\nOurs (confirmatory reg_table):\n")
print(round(ours$confirmatory[, c("b.r", "SE", "CI.L", "CI.U", "prob")], 3))
cat("\nNOTE: row labels/contrasts must be aligned by hand on first real run;\n")
cat("      paper reports conditional means, robu reports treatment-coded betas.\n")

cat("\n============ rho sweep vs Table S4.1 ============\n")
s41 <- p("data", "published", "S4.1_rho_sensitivity.csv")
if (file.exists(s41)) { cat("Published:\n"); print(read_csv(s41, show_col_types = FALSE)) }
cat("Ours:\n"); print(ours$rho_sweep, row.names = FALSE)
