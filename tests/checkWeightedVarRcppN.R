##########################################################
# Compare weighted unbiased variance C version with R code
library(carSurv)

# Standard R-Funktion
weightSelfVar <- function(x, w) {
  wMean <- sum(w*x) / length(x)
  firstSum <- sum(w*(x-wMean)^2)
  firstSum / length(x)
}

# Simple example: 
# Does Rcpp version have identical results with R-Version Function?
set.seed(1)
response <- rnorm(250)
set.seed(2)
weightResp <- runif(249)
weightResp <- weightResp / sum(weightResp)
weightResp[250] <- 1-sum(weightResp)
check1 <- all.equal(weightedVarRcppN(y=response, w=weightResp),
                    weightSelfVar(x=response, w=weightResp))
stopifnot(check1)

# Is the estimated variance greater or equal than zero?
check2 <- weightedVarRcpp(y=response, w=weightResp) >= 0
stopifnot(check2)

# Is Rcpp version faster than the regular variant?
library(microbenchmark)
microBench1 <- microbenchmark(weightedVarRcppN(y=response, w=weightResp), 
                              weightSelfVar(x=response, w=weightResp), 
                              times=1000)
check2 <- summary(microBench1)$expr [which.min(summary(microBench1)$mean)]==
  summary(microBench1)$expr[1]
stopifnot(check2)
