suppressPackageStartupMessages({
  library(Matrix)
  library(LaplacesDemon)
})

source("code/01-state-space.R")
source("code/02-FEM.R")
source("code/03-sampling.R")
source("code/06-model-helpers.R")

check_base_models <- function(){
  c_shift <- 1.1
  grid <- seq(0, 5, by = 0.1)
  curvature_values <- c(0.5, 1, 2, -1, -2, -0.5)

  for(curvature in curvature_values){
    if(curvature == 1){
      truth <- function(x) log(x + c_shift)
      derivative <- function(x) 1 / (x + c_shift)
    } else {
      lambda <- (curvature - 1) / curvature
      truth <- function(x) (x + c_shift)^lambda
      derivative <- function(x) lambda * (x + c_shift)^(lambda - 1)
    }

    deterministic_path <- mGP_sim(
      t = grid,
      alpha = curvature,
      c = c_shift,
      initial_vec = c(truth(0), derivative(0)),
      sd = 0
    )

    if(max(abs(deterministic_path[, "func"] - truth(deterministic_path[, "t"]))) > 1e-10){
      stop("Base-model regression failed for a = ", curvature, ".")
    }
  }
}

build_mgp_covariance_from_precision <- function(grid, a, c_shift){
  precision <- as.matrix(mGP_joint_prec(t_vec = grid, a = a, c = c_shift))
  solve(precision)
}

build_exact_function_covariance <- function(grid, a, c_shift){
  covariance <- build_mgp_covariance_from_precision(grid, a = a, c_shift = c_shift)
  covariance[seq(1, 2 * length(grid), by = 2), seq(1, 2 * length(grid), by = 2)]
}

check_mgp_exact_covariance <- function(){
  grid <- c(0.4, 1.2, 2.5, 4.0)
  c_shift <- 1.1

  for(curvature in c(0.5, 1, 2, -1, -2, -0.5)){
    exact_covariance <- outer(
      grid,
      grid,
      Vectorize(function(x1, x2){
        s <- max(x1, x2)
        t <- min(x1, x2)
        mspline_cov(s = s, t = t, a = curvature, c = c_shift)
      })
    )

    precision_covariance <- build_exact_function_covariance(grid, a = curvature, c_shift = c_shift)
    if(max(abs(precision_covariance - exact_covariance)) > 1e-8){
      stop("Exact covariance regression failed for a = ", curvature, ".")
    }
  }
}

check_mgp_fem_approximation <- function(){
  c_shift <- 1.1
  evaluation_grid <- seq(0.4, 4, length.out = 8)

  for(curvature in c(0.5, 1, 2, -1, -2, -0.5)){
    precision <- as.matrix(
      Compute_Prec(a = curvature, c = c_shift, k = 120,
                   region = range(c(0, evaluation_grid)),
                   accuracy = 0.002, boundary = TRUE)
    )
    design <- as.matrix(
      Compute_Design(evaluation_grid, k = 120,
                     region = range(c(0, evaluation_grid)),
                     boundary = TRUE)
    )
    fem_covariance <- design %*% solve(precision, t(design))
    exact_covariance <- outer(
      evaluation_grid,
      evaluation_grid,
      Vectorize(function(x1, x2){
        s <- max(x1, x2)
        t <- min(x1, x2)
        mspline_cov(s = s, t = t, a = curvature, c = c_shift)
      })
    )

    relative_error <- max(abs(fem_covariance - exact_covariance)) / max(abs(exact_covariance))
    if(relative_error > 5e-3){
      stop("FEM covariance regression failed for a = ", curvature, ".")
    }
  }
}

check_tiwp_psd <- function(){
  closed_form <- PSD_compute_tiwp2(x = 0.8, h = 1.7, a = 2, c = 1, sd = 1)
  dispatched <- PSD_compute(model = "tiwp2", h = 1.7, sd = 1, x = 0.8, c = 1, a = 2)

  if(abs(closed_form - dispatched) > 1e-12){
    stop("The canonical t-IWP PSD helper disagrees with the PSD dispatcher.")
  }
}

check_base_models()
check_mgp_exact_covariance()
check_mgp_fem_approximation()
check_tiwp_psd()

message("Canonical regression checks passed.")
