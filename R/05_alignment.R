## 05_alignment.R -- test-alignment EXTENSION analysis.
## Re-includes the proximal/researcher-made effect sizes that the original
## meta-analysis (and our canonical file) excludes, then tests whether outcomes
## aligned to the intervention (proximal) show larger effects than independent
## standardized tests (distal). This is the Wolf & Harbatkin / Visscher future
## direction. Alignment is taken from the per-effect-size `test_type`.
##
## Run:  ICC_ASSUMED=0.20 ES_FILE=data/extracted/effect_sizes_with_aligned.csv \
##       Rscript R/05_alignment.R

suppressPackageStartupMessages({
  library(robumeta); library(clubSandwich); library(dplyr)
})
ROOT <- getwd()
if (!file.exists(file.path(ROOT,"R","01_data.R"))) ROOT <- normalizePath(file.path(ROOT,".."))
dat <- source(file.path(ROOT,"R","01_data.R"), local=TRUE)$value

dat <- dat %>% mutate(alignment_es = factor(case_when(
  test_type == "standardized_independent" ~ "distal",
  test_type == "researcher_made"          ~ "proximal",
  TRUE ~ NA_character_), levels = c("distal","proximal")))

rb <- function(d) { m <- robu(g~1, data=d, studynum=factor(cluster), var.eff.size=v,
                              rho=0.08, modelweights="CORR", small=TRUE); m }
say <- function(tag, m){ rt<-m$reg_table; cat(sprintf("  %-26s g=%.3f [%.3f, %.3f]  (k=%d, ES=%d)\n",
                          tag, rt$b.r[1], rt$CI.L[1], rt$CI.U[1], m$N, m$M)) }

cat("\n=== Overall effect WITH proximal tests re-included ===\n")
say("all outcomes", rb(dat))
cat("  [canonical, distal-only = 0.070 (111 clusters, 340 ES)]\n")

cat("\n=== Proximal vs distal (all studies) ===\n")
d <- dat[!is.na(dat$alignment_es),]
for (lv in levels(d$alignment_es)) say(lv, rb(d[d$alignment_es==lv,]))
m1 <- robu(g ~ alignment_es, data=d, studynum=factor(cluster), var.eff.size=v,
           rho=0.08, modelweights="CORR", small=TRUE)
rt <- m1$reg_table
cat(sprintf("  proximal - distal: b=%.3f [%.3f, %.3f], p=%.4f\n",
            rt$b.r[2], rt$CI.L[2], rt$CI.U[2], rt$prob[2]))

cat("\n=== Within-study: studies reporting BOTH proximal & distal ===\n")
both <- d %>% group_by(cluster) %>%
  filter(n_distinct(alignment_es)==2) %>% ungroup()
cat(sprintf("  %d such studies, %d effect sizes\n", n_distinct(both$cluster), nrow(both)))
mb <- robu(g ~ alignment_es, data=both, studynum=factor(cluster), var.eff.size=v,
           rho=0.08, modelweights="CORR", small=TRUE)
rtb <- mb$reg_table
cat(sprintf("  proximal - distal (within both-reporters): b=%.3f [%.3f, %.3f], p=%.4f\n",
            rtb$b.r[2], rtb$CI.L[2], rtb$CI.U[2], rtb$prob[2]))
for (lv in levels(droplevels(both$alignment_es))) say(paste0("  ",lv), rb(both[both$alignment_es==lv,]))

cat("\n=== Adjusted (confirmatory covariates + alignment) ===\n")
ma <- robu(g ~ publication_status + ses_main + grade3 + tested_subject + tpd_goal + alignment_es,
           data=d, studynum=factor(cluster), var.eff.size=v, rho=0.08, modelweights="CORR", small=TRUE)
ta <- ma$reg_table[,c("labels","b.r","SE","CI.L","CI.U","prob")]; ta[,-1]<-round(ta[,-1],3)
print(ta[grepl("alignment_es", ta$labels),], row.names=FALSE)
