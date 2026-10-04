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

relative_variance_error <- function(approximate, reference){
  max(abs(diag(approximate) - diag(reference))) / max(abs(diag(reference)))
}

extract_lml <- function(fit){
  as.numeric(fit$mod$normalized_posterior$lognormconst)
}

extract_prior_covariance <- function(fit){
  instance <- fit$instances[[1]]
  design <- as.matrix(instance@B)
  precision <- as.matrix(instance@P)
  design %*% solve(precision, t(design))
}

reference_value <- function(x, reference_kind){
  switch(
    reference_kind,
    left = min(x),
    middle = mean(range(x)),
    stop("Unknown reference kind.")
  )
}

original_scale_shift <- function(original_shift = 1.25){
  original_shift
}

fit_prior_probe <- function(model_name, computation_method, x, reference_kind,
                            k = 80, accuracy = 0.005){
  data <- data.frame(x = x, y = rep(0, length(x)))
  c_original <- original_scale_shift()
  base_prior <- list(prior = "exp", param = list(u = 1, alpha = 0.5))

  if(computation_method == "state-space"){
    return(model_fit(
      y ~ f(
        x,
        model = model_name,
        computation = "state-space",
        a = 2,
        c = c_original,
        initial_location = reference_kind,
        grid = x,
        boundary.prior = list(mean = 0, prec = 1e6),
        sd.prior = base_prior
      ),
      data = data,
      family = "gaussian",
      control.family = list(sd = 1),
      control.fixed = list(intercept = list(mean = 0, prec = 1e6)),
      aghq_k = 1,
      M = 20
    ))
  }

  model_fit(
    y ~ f(
      x,
      model = model_name,
      computation = "fem",
      a = 2,
      c = c_original,
      initial_location = reference_kind,
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
    M = 20
  )
}

run_prior_covariance_check <- function(){
  evaluation_x <- c(0.20, 0.45, 0.80, 1.20, 1.70, 2.40, 3.20, 4.10)
  k_values <- c(20, 40, 80, 160)
  rows <- list()

  for(model_name in c("mgp", "tiwp2")){
    for(reference_kind in c("left", "middle")){
      exact_fit <- fit_prior_probe(
        model_name = model_name,
        computation_method = "state-space",
        x = evaluation_x,
        reference_kind = reference_kind
      )
      exact_covariance <- extract_prior_covariance(exact_fit)

      for(k in k_values){
        fem_accuracy <- 0.4 / k
        fem_fit <- fit_prior_probe(
          model_name = model_name,
          computation_method = "fem",
          x = evaluation_x,
          reference_kind = reference_kind,
          k = k,
          accuracy = fem_accuracy
        )
        fem_covariance <- extract_prior_covariance(fem_fit)

        rows[[length(rows) + 1]] <- data.frame(
          model = model_name,
          reference = reference_kind,
          k = k,
          fem_accuracy = if(model_name == "mgp") fem_accuracy else NA_real_,
          frobenius_rel_error = relative_frobenius_error(fem_covariance, exact_covariance),
          max_rel_error = relative_max_error(fem_covariance, exact_covariance),
          variance_rel_error = relative_variance_error(fem_covariance, exact_covariance)
        )
      }
    }
  }

  do.call(rbind, rows)
}

truth_function <- function(x){
  1 + 0.8 * log(x + 1.25)
}

fit_posterior_probe <- function(model_name, computation_method, reference_kind,
                                data_train, prediction_x, k = 160, M = 800){
  c_original <- original_scale_shift()
  sd_prior <- list(
    prior = "exp",
    param = list(u = 1.2, alpha = 0.5),
    h = 0.8,
    x = 0
  )

  if(computation_method == "state-space"){
    return(model_fit(
      y ~ f(
        x,
        model = model_name,
        computation = "state-space",
        a = 2,
        c = c_original,
        initial_location = reference_kind,
        grid = prediction_x,
        normalized_boundary = TRUE,
        boundary.prior = list(mean = 0, prec = 0.001),
        sd.prior = sd_prior
      ),
      data = data_train,
      family = "gaussian",
      control.family = list(sd = 0.25),
      aghq_k = 3,
      M = M
    ))
  }

  model_fit(
    y ~ f(
      x,
      model = model_name,
      computation = "fem",
      a = 2,
      c = c_original,
      initial_location = reference_kind,
      k = k,
      accuracy = 0.4 / k,
      region = range(prediction_x),
      normalized_boundary = TRUE,
      boundary.prior = list(mean = 0, prec = 0.001),
      sd.prior = sd_prior
    ),
    data = data_train,
    family = "gaussian",
    control.family = list(sd = 0.25),
    aghq_k = 3,
    M = M
  )
}

summarize_posterior_difference <- function(model_name, reference_kind,
                                           exact_fit, fem_fit,
                                           prediction_data){
  exact_summary <- predict(
    exact_fit,
    newdata = prediction_data,
    variable = "x",
    only.samples = FALSE
  )
  fem_summary <- predict(
    fem_fit,
    newdata = prediction_data,
    variable = "x",
    only.samples = FALSE
  )

  exact_width <- exact_summary$q0.975 - exact_summary$q0.025
  fem_width <- fem_summary$q0.975 - fem_summary$q0.025
  exact_mean_range <- diff(range(exact_summary$mean))

  data.frame(
    model = model_name,
    reference = reference_kind,
    k = fem_fit$instances[[1]]@k,
    exact_log_marginal_likelihood = extract_lml(exact_fit),
    fem_log_marginal_likelihood = extract_lml(fem_fit),
    abs_log_marginal_likelihood_diff = abs(extract_lml(exact_fit) - extract_lml(fem_fit)),
    mean_rmse = sqrt(mean((fem_summary$mean - exact_summary$mean)^2)),
    mean_max_abs_diff = max(abs(fem_summary$mean - exact_summary$mean)),
    mean_relative_rmse = sqrt(mean((fem_summary$mean - exact_summary$mean)^2)) /
      max(exact_mean_range, sqrt(.Machine$double.eps)),
    interval_width_rmse = sqrt(mean((fem_width - exact_width)^2)),
    interval_width_relative_rmse = sqrt(mean((fem_width - exact_width)^2)) /
      max(mean(exact_width), sqrt(.Machine$double.eps))
  )
}

run_posterior_prediction_check <- function(){
  prediction_x <- seq(0.20, 4.10, length.out = 21)
  training_x <- prediction_x[seq(1, length(prediction_x), by = 2)]
  data_train <- data.frame(
    x = training_x,
    y = truth_function(training_x) + 0.12 * sin(seq_along(training_x) * 1.7)
  )
  prediction_data <- data.frame(x = prediction_x)
  rows <- list()

  for(model_name in c("mgp", "tiwp2")){
    for(reference_kind in c("left", "middle")){
      set.seed(1001)
      exact_fit <- fit_posterior_probe(
        model_name = model_name,
        computation_method = "state-space",
        reference_kind = reference_kind,
        data_train = data_train,
        prediction_x = prediction_x
      )
      set.seed(1001)
      fem_fit <- fit_posterior_probe(
        model_name = model_name,
        computation_method = "fem",
        reference_kind = reference_kind,
        data_train = data_train,
        prediction_x = prediction_x
      )

      rows[[length(rows) + 1]] <- summarize_posterior_difference(
        model_name = model_name,
        reference_kind = reference_kind,
        exact_fit = exact_fit,
        fem_fit = fem_fit,
        prediction_data = prediction_data
      )
    }
  }

  do.call(rbind, rows)
}

assert_no_failures <- function(prior_results, posterior_results){
  failures <- character()

  for(model_name in c("mgp", "tiwp2")){
    for(reference_kind in c("left", "middle")){
      subset_rows <- prior_results[
        prior_results$model == model_name & prior_results$reference == reference_kind,
      ]
      first_row <- subset_rows[which.min(subset_rows$k), ]
      last_row <- subset_rows[which.max(subset_rows$k), ]

      if(last_row$frobenius_rel_error >= first_row$frobenius_rel_error){
        failures <- c(
          failures,
          sprintf("%s/%s prior Frobenius error did not decrease.", model_name, reference_kind)
        )
      }
      if(last_row$variance_rel_error >= first_row$variance_rel_error){
        failures <- c(
          failures,
          sprintf("%s/%s prior variance error did not decrease.", model_name, reference_kind)
        )
      }
      if(last_row$frobenius_rel_error > 0.01){
        failures <- c(
          failures,
          sprintf("%s/%s final prior Frobenius error is too large.", model_name, reference_kind)
        )
      }
      if(last_row$max_rel_error > 0.01){
        failures <- c(
          failures,
          sprintf("%s/%s final prior max error is too large.", model_name, reference_kind)
        )
      }
    }
  }

  if(any(posterior_results$mean_relative_rmse > 0.02)){
    bad_rows <- posterior_results[posterior_results$mean_relative_rmse > 0.02, ]
    failures <- c(
      failures,
      paste(
        "Posterior mean relative RMSE exceeded 0.02 for",
        paste(paste(bad_rows$model, bad_rows$reference, sep = "/"), collapse = ", "),
        "."
      )
    )
  }
  if(any(posterior_results$mean_max_abs_diff > 0.05)){
    bad_rows <- posterior_results[posterior_results$mean_max_abs_diff > 0.05, ]
    failures <- c(
      failures,
      paste(
        "Posterior mean max absolute difference exceeded 0.05 for",
        paste(paste(bad_rows$model, bad_rows$reference, sep = "/"), collapse = ", "),
        "."
      )
    )
  }
  if(any(posterior_results$abs_log_marginal_likelihood_diff > 0.05)){
    bad_rows <- posterior_results[posterior_results$abs_log_marginal_likelihood_diff > 0.05, ]
    failures <- c(
      failures,
      paste(
        "Log marginal likelihood difference exceeded 0.05 for",
        paste(paste(bad_rows$model, bad_rows$reference, sep = "/"), collapse = ", "),
        "."
      )
    )
  }
  if(any(posterior_results$interval_width_relative_rmse > 0.08)){
    bad_rows <- posterior_results[posterior_results$interval_width_relative_rmse > 0.08, ]
    failures <- c(
      failures,
      paste(
        "Posterior interval-width relative RMSE exceeded 0.08 for",
        paste(paste(bad_rows$model, bad_rows$reference, sep = "/"), collapse = ", "),
        "."
      )
    )
  }

  if(length(failures) > 0){
    stop(paste(failures, collapse = "\n"))
  }

  invisible(TRUE)
}

prior_results <- run_prior_covariance_check()
posterior_results <- run_posterior_prediction_check()

write.csv(
  prior_results,
  file = "output/reference_location_prior_covariance_metrics.csv",
  row.names = FALSE
)
write.csv(
  posterior_results,
  file = "output/reference_location_posterior_consistency_metrics.csv",
  row.names = FALSE
)

assert_no_failures(prior_results, posterior_results)

cat("\nPrior covariance convergence metrics:\n")
print(prior_results, digits = 6)

cat("\nPosterior prediction consistency metrics:\n")
print(posterior_results, digits = 6)

cat("\nReference-location consistency checks passed.\n")
