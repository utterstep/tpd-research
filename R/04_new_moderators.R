## 04_new_moderators.R -- exploratory test of the Tier-1 candidate moderators
## (delivery_mode, test_alignment, curriculum_coupled; outcome_timing is near-
## constant so it is only described, not modelled).
##
## For each moderator: per-level conditional means via subset null CE models
## (robu g~1, rho=0.08), plus the omnibus Wald test (clubSandwich CR2) from the
## g~moderator model. Then a joint exploratory model adding all three to the
## confirmatory set, with a crude collinearity check.
##
## Run:  ICC_ASSUMED=0.20 ES_FILE=data/extracted/effect_sizes.csv Rscript R/04_new_moderators.R

suppressPackageStartupMessages({
  library(robumeta); library(clubSandwich); library(dplyr); library(readr)
})
ROOT <- getwd()
if (!file.exists(file.path(ROOT,"R","01_data.R"))) ROOT <- normalizePath(file.path(ROOT,".."))
p <- function(...) file.path(ROOT, ...)

dat <- source(p("R","01_data.R"), local=TRUE)$value
mods <- read_csv(p("data","moderators","moderators.csv"), show_col_types=FALSE)
dat <- dat %>% left_join(mods, by=c("cluster"="slug"))

dat <- dat %>% mutate(
  delivery   = factor(na_if(delivery_mode,"not_reported"), levels=c("in_person","blended","online")),
  delivery2  = factor(case_when(delivery_mode=="in_person"~"in_person",
                                delivery_mode %in% c("blended","online")~"has_online"),
                      levels=c("in_person","has_online")),
  alignment  = factor(test_alignment, levels=c("independent","mixed","aligned")),
  alignment2 = factor(case_when(test_alignment=="independent"~"independent",
                                test_alignment %in% c("mixed","aligned")~"some_aligned"),
                      levels=c("independent","some_aligned")),
  curriculum = factor(if_else(curriculum_coupled %in% c("bundled","practice_only"),
                              curriculum_coupled, NA_character_),
                      levels=c("practice_only","bundled"))
)

robu1 <- function(d) robu(g~1, data=d, studynum=factor(cluster), var.eff.size=v,
                          rho=0.08, modelweights="CORR", small=TRUE)

subgroup <- function(fname){
  d <- dat[!is.na(dat[[fname]]),]; d[[fname]] <- droplevels(d[[fname]])
  cat(sprintf("\n=== %s ===\n", fname))
  for (lv in levels(d[[fname]])){
    dd <- d[d[[fname]]==lv,]
    if (dplyr::n_distinct(dd$cluster) < 2){ cat(sprintf("  %-14s (only %d study)\n", lv, dplyr::n_distinct(dd$cluster))); next }
    m <- robu1(dd); rt <- m$reg_table
    cat(sprintf("  %-14s k=%2d ES=%3d  g=%.3f [%.3f, %.3f]\n",
                lv, m$N, m$M, rt$b.r[1], rt$CI.L[1], rt$CI.U[1]))
  }
  f <- as.formula(paste("g ~", fname))
  m1 <- robu(f, data=d, studynum=factor(cluster), var.eff.size=v, rho=0.08, modelweights="CORR", small=TRUE)
  labs <- as.character(m1$reg_table$labels); idx <- grep(paste0("^",fname), labs)
  wt <- tryCatch(Wald_test(m1, constraints=constrain_zero(idx), vcov="CR2"), error=function(e) NULL)
  if(!is.null(wt)) cat(sprintf("  omnibus: F=%.2f, df=(%d, %.1f), p=%.4f\n", wt$Fstat, wt$df_num, wt$df_denom, wt$p_val))
}

for (f in c("delivery2","delivery","alignment2","alignment","curriculum")) subgroup(f)

## --- joint exploratory model: confirmatory covariates + 3 new moderators -----
cat("\n=== JOINT exploratory model (confirmatory + new moderators) ===\n")
dj <- dat %>% filter(!is.na(delivery2), !is.na(alignment2), !is.na(curriculum))
mj <- robu(g ~ publication_status + ses_main + grade3 + tested_subject + tpd_goal +
             delivery2 + alignment2 + curriculum,
           data=dj, studynum=factor(cluster), var.eff.size=v, rho=0.08, modelweights="CORR", small=TRUE)
t <- mj$reg_table[,c("labels","b.r","SE","CI.L","CI.U","prob")]; t[,-1]<-round(t[,-1],3)
print(t[grepl("delivery2|alignment2|curriculum", t$labels),], row.names=FALSE)

## crude collinearity check: Cramer's V among new + key existing moderators (study level)
studylvl <- dat %>% distinct(cluster, .keep_all=TRUE)
cv <- function(a,b){ t<-table(a,b); if(any(dim(t)<2)) return(NA); x<-suppressWarnings(chisq.test(t)$statistic); sqrt(x/(sum(t)*(min(dim(t))-1))) }
cat("\nCramer's V (study-level association with existing moderators):\n")
for(nm in c("delivery2","alignment2","curriculum")){
  cat(sprintf("  %-11s vs goal=%.2f subject=%.2f pubstatus=%.2f grade=%.2f\n", nm,
      cv(studylvl[[nm]],studylvl$tpd_goal), cv(studylvl[[nm]],studylvl$tested_subject),
      cv(studylvl[[nm]],studylvl$publication_status), cv(studylvl[[nm]],studylvl$grade3)))
}
