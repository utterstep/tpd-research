## 06_implementation_moderators.R -- test the implementation-conditions moderators
## (efficacy->effectiveness cluster + coaching dose + student dose + maturity).
## Each singly (subgroup means + clubSandwich omnibus), a composite "developer-
## ideal-conditions" index (continuous), a joint model, and collinearity checks.
##
## Run: ICC_ASSUMED=0.20 ES_FILE=data/extracted/effect_sizes.csv Rscript R/06_implementation_moderators.R

suppressPackageStartupMessages({ library(robumeta); library(clubSandwich); library(dplyr); library(readr) })
ROOT <- getwd(); if (!file.exists(file.path(ROOT,"R","01_data.R"))) ROOT <- normalizePath(file.path(ROOT,".."))
dat <- source(file.path(ROOT,"R","01_data.R"), local=TRUE)$value
m2 <- read_csv(file.path(ROOT,"data","moderators2","moderators2.csv"), show_col_types=FALSE)
dat <- dat %>% left_join(m2, by=c("cluster"="slug"))

na_unclear <- function(x) ifelse(x=="unclear", NA, x)
dat <- dat %>% mutate(
  eval_indep  = factor(na_unclear(eval_independence), levels=c("independent","developer")),
  dev_deliv   = factor(na_unclear(developer_delivered), levels=c("no","yes")),
  cascade     = factor(na_unclear(cascade_depth), levels=c("cascade","developer_direct")),
  counterf    = factor(na_unclear(counterfactual), levels=c("active_or_contaminated","business_as_usual")),
  coaching    = factor(na_unclear(coaching_intensity), levels=c("none","occasional","frequent_inclass")),
  student_dose= factor(na_unclear(added_student_dose), levels=c("none","student_component")),
  maturity    = factor(na_unclear(program_maturity), levels=c("first_year","mature","single_year_design"))
)
## composite: # of effect-inflating "ideal/efficacy" conditions (0-4)
dat <- dat %>% mutate(efficacy_score =
  (eval_independence=="developer") + (developer_delivered=="yes") +
  (cascade_depth=="developer_direct") + (counterfactual=="business_as_usual"))

rb <- function(d) robu(g~1, data=d, studynum=factor(cluster), var.eff.size=v, rho=0.08, modelweights="CORR", small=TRUE)
sub <- function(fname){
  d <- dat[!is.na(dat[[fname]]),]; d[[fname]] <- droplevels(d[[fname]])
  cat(sprintf("\n=== %s ===\n", fname))
  for(lv in levels(d[[fname]])){ dd<-d[d[[fname]]==lv,]
    if(dplyr::n_distinct(dd$cluster)<2){cat(sprintf("  %-18s (1 study)\n",lv));next}
    m<-rb(dd);rt<-m$reg_table; cat(sprintf("  %-18s k=%2d ES=%3d  g=%.3f [%.3f, %.3f]\n",lv,m$N,m$M,rt$b.r[1],rt$CI.L[1],rt$CI.U[1])) }
  f<-as.formula(paste("g ~",fname)); m1<-robu(f,data=d,studynum=factor(cluster),var.eff.size=v,rho=0.08,modelweights="CORR",small=TRUE)
  labs<-as.character(m1$reg_table$labels); idx<-grep(paste0("^",fname),labs)
  wt<-tryCatch(Wald_test(m1,constraints=constrain_zero(idx),vcov="CR2"),error=function(e)NULL)
  if(!is.null(wt)) cat(sprintf("  omnibus: F=%.2f, df=(%d, %.1f), p=%.4f\n",wt$Fstat,wt$df_num,wt$df_denom,wt$p_val))
}
for(f in c("eval_indep","dev_deliv","cascade","counterf","coaching","student_dose","maturity")) sub(f)

cat("\n=== COMPOSITE: developer-ideal-conditions score (0-4, continuous) ===\n")
for(s in 0:4){ dd<-dat[dat$efficacy_score==s,]
  if(dplyr::n_distinct(dd$cluster)>=2){m<-rb(dd);rt<-m$reg_table
    cat(sprintf("  score=%d  k=%2d  g=%.3f [%.3f, %.3f]\n",s,m$N,rt$b.r[1],rt$CI.L[1],rt$CI.U[1]))}}
ms<-robu(g~efficacy_score,data=dat,studynum=factor(cluster),var.eff.size=v,rho=0.08,modelweights="CORR",small=TRUE)
rt<-ms$reg_table
cat(sprintf("  slope per +1 ideal condition: b=%.3f [%.3f, %.3f], p=%.4f\n",rt$b.r[2],rt$CI.L[2],rt$CI.U[2],rt$prob[2]))

cat("\n=== JOINT model (confirmatory + key implementation moderators) ===\n")
dj <- dat %>% filter(!is.na(eval_indep),!is.na(counterf),!is.na(coaching),!is.na(student_dose),!is.na(maturity))
mj <- robu(g ~ publication_status + ses_main + grade3 + tested_subject + tpd_goal +
             eval_indep + counterf + coaching + student_dose + maturity,
           data=dj, studynum=factor(cluster), var.eff.size=v, rho=0.08, modelweights="CORR", small=TRUE)
t<-mj$reg_table[,c("labels","b.r","SE","CI.L","CI.U","prob")]; t[,-1]<-round(t[,-1],3)
print(t[grepl("eval_indep|counterf|coaching|student_dose|maturity",t$labels),], row.names=FALSE)

cat("\n=== collinearity (Cramer's V, study-level) ===\n")
sl <- dat %>% distinct(cluster,.keep_all=TRUE)
cv<-function(a,b){tb<-table(a,b);if(any(dim(tb)<2))return(NA);x<-suppressWarnings(chisq.test(tb)$statistic);sqrt(x/(sum(tb)*(min(dim(tb))-1)))}
for(nm in c("eval_indep","cascade","dev_deliv","counterf","coaching")){
  cat(sprintf("  %-12s vs pubstatus=%.2f country?goal=%.2f eval_indep=%.2f cascade=%.2f\n",nm,
    cv(sl[[nm]],sl$publication_status), cv(sl[[nm]],sl$tpd_goal), cv(sl[[nm]],sl$eval_indep), cv(sl[[nm]],sl$cascade)))}
