## lib_effectsize.R -- Hedges (2007) cluster correction for standardized mean
## differences computed from individual-level statistics in cluster-randomized
## designs. Total-variance standardization, as operationalized in D. B. Wilson's
## "Practical Meta-Analysis" / Campbell Collaboration clustered-d calculator.
##
## Hedges, L. V. (2007). Effect sizes in cluster-randomized designs. JEBS 32(4).
##
## Correctness is self-checked at the rho = 0 boundary, where every formula must
## reduce to the ordinary Hedges' g and its standard variance (see test below).

## small-sample correction factor (Hedges' g), df = h
hedges_J <- function(h) 1 - 3 / (4 * h - 1)

## Cluster-correct a naive (individual-level) standardized mean difference.
##   d        : naive SMD (Cohen's d, or g; we treat the input as d)
##   n1, n2   : treatment / control individual sample sizes
##   nclust   : total number of clusters across both arms
##   rho      : intraclass correlation
## Returns list(g, v, d_adj, J, n_bar, design_effect).
cluster_correct <- function(d, n1, n2, nclust, rho) {
  N <- n1 + n2
  n_bar <- N / nclust                       # average cluster size
  de <- 1 + (n_bar - 1) * rho               # design effect

  # point-estimate clustering adjustment
  d_adj <- d * sqrt(1 - (2 * (n_bar - 1) * rho) / (N - 2))

  # effective df for the small-sample correction (Hedges 2007)
  num_h <- ((N - 2) - 2 * (n_bar - 1) * rho)^2
  den_h <- (N - 2) * (1 - rho)^2 + n_bar * (N - 2 * n_bar) * rho^2 +
           2 * (N - 2 * n_bar) * rho * (1 - rho)
  h <- num_h / den_h
  J <- hedges_J(h)

  # variance of the cluster-adjusted d (total-variance standardization)
  v_d <- (N / (n1 * n2)) * de +
         d_adj^2 * den_h / (2 * (N - 2) * ((N - 2) - 2 * (n_bar - 1) * rho))

  g <- J * d_adj
  v <- J^2 * v_d
  list(g = g, v = v, d_adj = d_adj, J = J, n_bar = n_bar, design_effect = de)
}

## ---- self-test: at rho = 0 must equal the ordinary Hedges' g + variance ----
.test_cluster_correct <- function() {
  d <- 0.30; n1 <- 400; n2 <- 380; N <- n1 + n2; nclust <- 40
  got <- cluster_correct(d, n1, n2, nclust, rho = 0)
  J0 <- hedges_J(N - 2)
  exp_g <- J0 * d
  exp_v <- J0^2 * ((n1 + n2) / (n1 * n2) + d^2 / (2 * (N - 2)))
  stopifnot(abs(got$g - exp_g) < 1e-10, abs(got$v - exp_v) < 1e-10,
            abs(got$design_effect - 1) < 1e-12)
  # at rho > 0 the variance must inflate
  pos <- cluster_correct(d, n1, n2, nclust, rho = 0.20)
  stopifnot(pos$v > got$v, pos$design_effect > 1)
  invisible(TRUE)
}
if (identical(Sys.getenv("RUN_ES_TESTS"), "1")) {
  .test_cluster_correct(); cat("lib_effectsize.R self-tests passed\n")
}
