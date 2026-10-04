library(devtools)
library(Matrix)

load_all("BayesGP", quiet = TRUE)

dir.create("output", showWarnings = FALSE)

relative_frobenius_error <- function(approximate, reference){
  sqrt(sum((approximate - reference)^2) / sum(reference^2))
}

relative_max_error <- function(approximate, reference){
  max(abs(approximate - reference)) / max(abs(reference))
}

extract_prior_covariance <- function(fit){
  instance <- fit$instances[[1]]
  design <- as.matrix(instance@B)
  precision <- as.matrix(instance@P)
  design %*% solve(precision, t(design))
}

attempt_public_c_zero_fit <- function(model_name, computation_method){
  x <- seq(0, 4.1, length.out = 9)
  data <- data.frame(x = x, y = rep(0, length(x)))
  base_prior <- list(prior = "exp", param = list(u = 1, alpha = 0.5))

  fit_call <- if(computation_method == "state-space"){
    quote(model_fit(
      y ~ f(
        x,
        model = model_name,
        computation = "state-space",
        a = 2,
        c = 0,
        initial_location = "left",
        grid = x,
        sd.prior = base_prior
      ),
      data = data,
      family = "gaussian",
      control.family = list(sd = 1),
      M = 10
    ))
  } else {
    quote(model_fit(
      y ~ f(
        x,
        model = model_name,
        computation = "fem",
        a = 2,
        c = 0,
        initial_location = "left",
        region = range(x),
        k = 30,
        sd.prior = base_prior
      ),
      data = data,
      family = "gaussian",
      control.family = list(sd = 1),
      M = 10
    ))
  }

  tryCatch({
    eval(fit_call)
    data.frame(
      model = model_name,
      computation = computation_method,
      c = 0,
      fit_succeeded = TRUE,
      message = NA_character_
    )
  }, error = function(error){
    data.frame(
      model = model_name,
      computation = computation_method,
      c = 0,
      fit_succeeded = FALSE,
      message = conditionMessage(error)
    )
  })
}

fit_prior_probe <- function(model_name, computation_method, x, c_shift,
                            k = 80, accuracy = 0.005){
  data <- data.frame(x = x, y = rep(0, length(x)))
  base_prior <- list(prior = "exp", param = list(u = 1, alpha = 0.5))

  if(computation_method == "state-space"){
    return(model_fit(
      y ~ f(
        x,
        model = model_name,
        computation = "state-space",
        a = 2,
        c = c_shift,
        initial_location = "left",
        grid = x,
        boundary.prior = list(mean = 0, prec = 1e6),
        sd.prior = base_prior
      ),
      data = data,
      family = "gaussian",
      control.family = list(sd = 1),
      control.fixed = list(intercept = list(mean = 0, prec = 1e6)),
      aghq_k = 1,
      M = 10
    ))
  }

  model_fit(
    y ~ f(
      x,
      model = model_name,
      computation = "fem",
      a = 2,
      c = c_shift,
      initial_location = "left",
      k = k,
      accuracy = accuracy,
      region = range(x),
      boundary.prior = list(mean = 0, prec = 1e6),
      sd.prior = base_prior
    ),
    data = data,
    family = "gaussian",
    control.family = list(sd = 1),
    control.fixed = list(intercept = list(mean = 0, prec = 1e6)),
    aghq_k = 1,
    M = 10
  )
}

run_small_positive_c_check <- function(){
  evaluation_x <- c(0.20, 0.45, 0.80, 1.20, 1.70, 2.40, 3.20, 4.10)
  rows <- list()

  for(c_shift in c(1e-6, 1e-4, 1e-2, 0.1, 1.25)){
    for(model_name in c("mgp", "tiwp2")){
      exact_covariance <- extract_prior_covariance(fit_prior_probe(
        model_name = model_name,
        computation_method = "state-space",
        x = evaluation_x,
        c_shift = c_shift
      ))

      for(k in c(40, 80, 160)){
        fem_covariance <- extract_prior_covariance(fit_prior_probe(
          model_name = model_name,
          computation_method = "fem",
          x = evaluation_x,
          c_shift = c_shift,
          k = k,
          accuracy = 0.4 / k
        ))

        rows[[length(rows) + 1]] <- data.frame(
          model = model_name,
          c = c_shift,
          k = k,
          frobenius_rel_error = relative_frobenius_error(fem_covariance, exact_covariance),
          max_rel_error = relative_max_error(fem_covariance, exact_covariance)
        )
      }
    }
  }

  do.call(rbind, rows)
}

fit_zero_c_mgp_probe <- function(computation_method, x, k = 80,
                                 accuracy = 0.005){
  data <- data.frame(x = x, y = rep(0, length(x)))
  base_prior <- list(prior = "exp", param = list(u = 1, alpha = 0.5))

  if(computation_method == "state-space"){
    return(model_fit(
      y ~ f(
        x,
        model = "mgp",
        computation = "state-space",
        a = 2,
        c = 0,
        allow_zero_c = TRUE,
        normalized_boundary = FALSE,
        initial_location = "left",
        grid = x,
        boundary.prior = list(mean = 0, prec = 1e6),
        sd.prior = base_prior
      ),
      data = data,
      family = "gaussian",
      control.family = list(sd = 1),
      control.fixed = list(intercept = list(mean = 0, prec = 1e6)),
      aghq_k = 1,
      M = 10
    ))
  }

  model_fit(
    y ~ f(
      x,
      model = "mgp",
      computation = "fem",
      a = 2,
      c = 0,
      allow_zero_c = TRUE,
      normalized_boundary = FALSE,
      initial_location = "left",
      k = k,
      accuracy = accuracy,
      region = range(x),
      boundary.prior = list(mean = 0, prec = 1e6),
      sd.prior = base_prior
    ),
    data = data,
    family = "gaussian",
    control.family = list(sd = 1),
    control.fixed = list(intercept = list(mean = 0, prec = 1e6)),
    aghq_k = 1,
    M = 10
  )
}

run_zero_c_mgp_opt_in_check <- function(){
  evaluation_x <- c(0, 0.20, 0.45, 0.80, 1.20, 1.70, 2.40, 3.20, 4.10)
  exact_covariance <- extract_prior_covariance(fit_zero_c_mgp_probe(
    computation_method = "state-space",
    x = evaluation_x
  ))
  rows <- list()

  for(k in c(20, 40, 80, 160)){
    fem_covariance <- extract_prior_covariance(fit_zero_c_mgp_probe(
      computation_method = "fem",
      x = evaluation_x,
      k = k,
      accuracy = 0.4 / k
    ))
    rows[[length(rows) + 1]] <- data.frame(
      model = "mgp",
      c = 0,
      k = k,
      frobenius_rel_error = relative_frobenius_error(fem_covariance, exact_covariance),
      max_rel_error = relative_max_error(fem_covariance, exact_covariance)
    )
  }

  do.call(rbind, rows)
}

assert_c_zero_behavior <- function(public_attempts, zero_c_results,
                                   small_positive_results){
  if(any(public_attempts$fit_succeeded)){
    stop("Public near-monotone fits unexpectedly accepted `c = 0`.")
  }
  if(any(!grepl("non-positive transformed arguments", public_attempts$message, fixed = TRUE))){
    stop("Public `c = 0` failures did not use the expected validation message.")
  }

  if(zero_c_results$frobenius_rel_error[zero_c_results$k == 160] > 0.002){
    stop("Opt-in `c = 0` mGP FEM covariance approximation was unexpectedly poor.")
  }

  finest_rows <- small_positive_results[small_positive_results$k == 160, ]
  if(any(finest_rows$frobenius_rel_error > 0.002)){
    stop("Small positive `c` FEM covariance approximation was unexpectedly poor.")
  }

  invisible(TRUE)
}

public_attempts <- do.call(rbind, lapply(c("mgp", "tiwp2"), function(model_name){
  do.call(rbind, lapply(c("state-space", "fem"), function(computation_method){
    attempt_public_c_zero_fit(model_name, computation_method)
  }))
}))

zero_c_results <- run_zero_c_mgp_opt_in_check()
small_positive_results <- run_small_positive_c_check()

write.csv(
  public_attempts,
  file = "output/c_zero_public_fit_attempts.csv",
  row.names = FALSE
)
write.csv(
  zero_c_results,
  file = "output/zero_c_mgp_prior_covariance_metrics.csv",
  row.names = FALSE
)
write.csv(
  small_positive_results,
  file = "output/small_positive_c_prior_covariance_metrics.csv",
  row.names = FALSE
)

assert_c_zero_behavior(public_attempts, zero_c_results, small_positive_results)

cat("\nPublic c = 0 fit attempts:\n")
print(public_attempts, row.names = FALSE)

cat("\nOpt-in c = 0 mGP prior covariance metrics:\n")
print(zero_c_results, digits = 6)

cat("\nSmall positive c prior covariance metrics:\n")
print(small_positive_results, digits = 6)

cat("\nc = 0 and small positive c checks passed.\n")
