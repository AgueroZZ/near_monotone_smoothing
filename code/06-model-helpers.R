if(!exists("resolve_curvature_parameter")){
  source("code/01-state-space.R")
}

if(!exists("Compute_Prec")){
  source("code/02-FEM.R")
}

if(!exists("sim_IWp_Var")){
  source("code/03-sampling.R")
}

make_boxcox_transform <- function(a = NULL, alpha = NULL, c = 1,
                                  normalized = TRUE, ref_location = 0){
  curvature <- resolve_curvature_parameter(a = a, alpha = alpha)
  lambda <- (curvature - 1) / curvature
  reference <- c + ref_location

  if(normalized){
    if(isTRUE(all.equal(lambda, 0))){
      return(function(x){
        reference * (log(x + c) - log(reference))
      })
    }

    return(function(x){
      ((x + c)^lambda - reference^lambda) / (lambda * reference^(lambda - 1))
    })
  }

  if(isTRUE(all.equal(lambda, 0))){
    return(function(x){
      log(x + c)
    })
  }

  function(x){
    (x + c)^lambda
  }
}

make_boxcox_transform_derivative <- function(x, a = NULL, alpha = NULL, c = 1,
                                             normalized = TRUE, ref_location = 0){
  curvature <- resolve_curvature_parameter(a = a, alpha = alpha)
  lambda <- (curvature - 1) / curvature
  reference <- c + ref_location

  if(normalized){
    return(((x + c) / reference)^(lambda - 1))
  }

  if(isTRUE(all.equal(lambda, 0))){
    return(1 / (x + c))
  }

  lambda * (x + c)^(lambda - 1)
}

normalize_psd_model <- function(model) {
  model <- tolower(model)

  if (model %in% c("mgp", "tiwp2")) {
    return(model)
  }

  if (model %in% c("tiwp", "tiwp-2", "t-iwp2")) {
    return("tiwp2")
  }

  stop("`model` must be one of 'mgp' or 'tiwp2'.")
}

PSD_compute_tiwp2 <- function(x, h, a = NULL, alpha = NULL,
                              c = 1, sd = 1, normalized = TRUE){
  transform <- make_boxcox_transform(
    a = a,
    alpha = alpha,
    c = c,
    normalized = normalized
  )
  transformed_step <- transform(x + h) - transform(x)
  abs(sd) * sqrt((transformed_step^3) / 3)
}

PSD_compute <- function(model, h, x = NULL, sd = 1, ...) {
  model <- normalize_psd_model(model)

  if (model %in% c("mgp", "tiwp2") && is.null(x)) {
    stop("`x` must be supplied when `model` is 'mgp' or 'tiwp2'.")
  }

  switch(
    model,
    mgp = PSD_compute_mgp(x = x, h = h, sd = sd, ...),
    tiwp2 = PSD_compute_tiwp2(x = x, h = h, sd = sd, ...)
  )
}

simulate_tiwp_boxcox <- function(x, a = NULL, alpha = NULL, c = 1, sd = 1,
                                 initial_level = 0, initial_slope = 1,
                                 normalized_transform = TRUE){
  transform <- make_boxcox_transform(
    a = a,
    alpha = alpha,
    c = c,
    normalized = normalized_transform,
    ref_location = x[1]
  )
  transformed_x <- transform(x)
  transformed_initial_slope <- initial_slope / make_boxcox_transform_derivative(
    x = x[1],
    a = a,
    alpha = alpha,
    c = c,
    normalized = normalized_transform,
    ref_location = x[1]
  )

  sim_IWp_Var(
    t = transformed_x,
    p = 2,
    sd = sd,
    initial_vec = c(initial_level, transformed_initial_slope)
  )[, 2]
}

compile_tmb_model <- function(dll = "fitGP_known_sd", rebuild = FALSE){
  source_file <- file.path("code", paste0(dll, ".cpp"))
  shared_object <- TMB::dynlib(file.path("code", dll))

  if(rebuild || !file.exists(shared_object)){
    TMB::compile(source_file)
  }

  if(!(dll %in% names(getLoadedDLLs()))){
    dyn.load(shared_object)
  }

  invisible(shared_object)
}

build_augmented_observation_matrix <- function(data_sim, data_train,
                                               subset_mode = c("prefix", "match")){
  subset_mode <- match.arg(subset_mode)
  n_grid <- nrow(data_sim)

  observation_matrix <- Matrix::Diagonal(n = 2 * n_grid, x = 1)
  observation_matrix <- observation_matrix[seq(1, 2 * n_grid, by = 2), , drop = FALSE]

  if(subset_mode == "prefix"){
    selected_rows <- seq_len(nrow(data_train))
  } else {
    selected_rows <- match(data_train$x, data_sim$x)
    if(anyNA(selected_rows)){
      stop("Each training location must appear in `data_sim$x` when `subset_mode = 'match'`.")
    }
  }

  observation_matrix[selected_rows, , drop = FALSE]
}

fit_exact_known_sd_model <- function(y, X, B, P, u, sig_noise,
                                     betaprec = 0.001, pc_alpha = 0.5,
                                     dll = "fitGP_known_sd"){
  compile_tmb_model(dll = dll)

  logPdet <- determinant(P)$modulus
  tmbdat <- list(
    y = y,
    X = X,
    B = B,
    P = P,
    logPdet = as.numeric(logPdet),
    betaprec = betaprec,
    sig = sig_noise,
    u = u,
    alpha = pc_alpha
  )

  tmbparams <- list(
    W = numeric(ncol(X) + ncol(B)),
    theta = 0
  )

  objective <- TMB::MakeADFun(
    data = tmbdat,
    parameters = tmbparams,
    DLL = dll,
    random = "W",
    silent = TRUE
  )

  objective$he <- function(w){
    numDeriv::jacobian(objective$gr, w)
  }

  aghq::marginal_laplace_tmb(objective, k = 4, startingvalue = 0)
}

sample_exact_known_sd_fit <- function(model_object, M = 3000){
  posterior_samples <- aghq::sample_marginal(quad = model_object$fit, M = M)
  n_grid <- model_object$n_grid

  function_samples <- posterior_samples$samps[seq(1, 2 * n_grid, by = 2), , drop = FALSE]
  beta_samples <- posterior_samples$samps[(2 * n_grid + 1):nrow(posterior_samples$samps), , drop = FALSE]

  function_samples + model_object$X_sim %*% beta_samples
}

fit_iwp_known_sd <- function(data_sim, data_train, u, sig_noise,
                             betaprec = 0.001, pc_alpha = 0.5,
                             subset_mode = c("prefix", "match")){
  subset_mode <- match.arg(subset_mode)
  X_train <- as(cbind(1, data_train$x), "dgCMatrix")
  X_sim <- as(cbind(1, data_sim$x), "dgCMatrix")
  B <- as(build_augmented_observation_matrix(data_sim, data_train, subset_mode = subset_mode), "dgCMatrix")
  P <- IWP_joint_prec(t_vec = data_sim$x)

  fit <- fit_exact_known_sd_model(
    y = data_train$y,
    X = X_train,
    B = B,
    P = P,
    u = u,
    sig_noise = sig_noise,
    betaprec = betaprec,
    pc_alpha = pc_alpha
  )

  list(fit = fit, X_sim = X_sim, n_grid = nrow(data_sim), model = "iwp2")
}

fit_tiwp_known_sd <- function(data_sim, data_train, u, a = NULL, alpha = NULL,
                              c = 1, sig_noise, betaprec = 0.001,
                              pc_alpha = 0.5, subset_mode = c("prefix", "match"),
                              normalized_transform = TRUE){
  subset_mode <- match.arg(subset_mode)
  transform <- make_boxcox_transform(
    a = a,
    alpha = alpha,
    c = c,
    normalized = normalized_transform
  )

  X_train <- as(cbind(1, transform(data_train$x)), "dgCMatrix")
  X_sim <- as(cbind(1, transform(data_sim$x)), "dgCMatrix")
  B <- as(build_augmented_observation_matrix(data_sim, data_train, subset_mode = subset_mode), "dgCMatrix")
  P <- IWP_joint_prec(t_vec = transform(data_sim$x))

  fit <- fit_exact_known_sd_model(
    y = data_train$y,
    X = X_train,
    B = B,
    P = P,
    u = u,
    sig_noise = sig_noise,
    betaprec = betaprec,
    pc_alpha = pc_alpha
  )

  list(fit = fit, X_sim = X_sim, n_grid = nrow(data_sim), model = "tiwp2")
}

fit_mgp_known_sd <- function(data_sim, data_train, u, a = NULL, alpha = NULL,
                             c = 1, sig_noise, betaprec = 0.001,
                             pc_alpha = 0.5, subset_mode = c("prefix", "match"),
                             normalized_boundary = FALSE){
  subset_mode <- match.arg(subset_mode)
  boundary <- make_boxcox_transform(
    a = a,
    alpha = alpha,
    c = c,
    normalized = normalized_boundary
  )

  X_train <- as(cbind(1, boundary(data_train$x)), "dgCMatrix")
  X_sim <- as(cbind(1, boundary(data_sim$x)), "dgCMatrix")
  B <- as(build_augmented_observation_matrix(data_sim, data_train, subset_mode = subset_mode), "dgCMatrix")
  P <- mGP_joint_prec(t_vec = data_sim$x, a = a, alpha = alpha, c = c)

  fit <- fit_exact_known_sd_model(
    y = data_train$y,
    X = X_train,
    B = B,
    P = P,
    u = u,
    sig_noise = sig_noise,
    betaprec = betaprec,
    pc_alpha = pc_alpha
  )

  list(fit = fit, X_sim = X_sim, n_grid = nrow(data_sim), model = "mgp")
}

fit_mgp_fem_known_sd <- function(data_sim, data_train, u, a = NULL, alpha = NULL,
                                 c = 1, sig_noise, k = 30, betaprec = 0.001,
                                 pc_alpha = 0.5, boundary = TRUE,
                                 normalized_boundary = TRUE, accuracy = 0.01){
  boundary_function <- make_boxcox_transform(
    a = a,
    alpha = alpha,
    c = c,
    normalized = normalized_boundary
  )

  region <- range(data_sim$x)
  X_train <- as(cbind(1, boundary_function(data_train$x)), "dgCMatrix")
  X_sim <- as(cbind(1, boundary_function(data_sim$x)), "dgCMatrix")
  B_train <- as(Compute_Design(data_train$x, k = k, region = region, boundary = boundary), "dgCMatrix")
  B_sim <- as(Compute_Design(data_sim$x, k = k, region = region, boundary = boundary), "dgCMatrix")
  P <- Compute_Prec(a = a, alpha = alpha, c = c, k = k, region = region,
                    accuracy = accuracy, boundary = boundary)

  fit <- fit_exact_known_sd_model(
    y = data_train$y,
    X = X_train,
    B = B_train,
    P = P,
    u = u,
    sig_noise = sig_noise,
    betaprec = betaprec,
    pc_alpha = pc_alpha
  )

  list(fit = fit, X_sim = X_sim, B_sim = B_sim, model = "mgp_fem")
}

sample_mgp_fem_known_sd_fit <- function(model_object, M = 3000){
  posterior_samples <- aghq::sample_marginal(quad = model_object$fit, M = M)
  basis_samples <- posterior_samples$samps[1:(nrow(posterior_samples$samps) - 2), , drop = FALSE]
  beta_samples <- posterior_samples$samps[(nrow(posterior_samples$samps) - 1):nrow(posterior_samples$samps), , drop = FALSE]

  model_object$X_sim %*% beta_samples + model_object$B_sim %*% basis_samples
}

summarize_function_samples <- function(samples, probs = c(0.025, 0.975)){
  data.frame(
    mean = rowMeans(samples),
    lower = apply(samples, 1, quantile, probs = probs[1]),
    upper = apply(samples, 1, quantile, probs = probs[2])
  )
}

evaluate_train_prediction_draws <- function(samples, truth, n_train){
  safe_mean <- function(values){
    if(length(values) == 0){
      return(NA_real_)
    }
    mean(values)
  }

  compute_interval_metrics <- function(probability){
    interval <- apply(
      samples,
      1,
      quantile,
      probs = c((1 - probability) / 2, 1 - (1 - probability) / 2)
    )

    interpolation_index <- seq_len(n_train)
    prediction_index <- setdiff(seq_along(truth), interpolation_index)

    list(
      inter = safe_mean(
        truth[interpolation_index] >= interval[1, interpolation_index] &
          truth[interpolation_index] <= interval[2, interpolation_index]
      ),
      pred = safe_mean(
        truth[prediction_index] >= interval[1, prediction_index] &
          truth[prediction_index] <= interval[2, prediction_index]
      )
    )
  }

  mean_draw <- rowMeans(samples)
  interpolation_index <- seq_len(n_train)
  prediction_index <- setdiff(seq_along(truth), interpolation_index)

  coverage_50 <- compute_interval_metrics(0.5)
  coverage_80 <- compute_interval_metrics(0.8)
  coverage_95 <- compute_interval_metrics(0.95)

  list(
    data_inter = data.frame(
      coverage_50 = coverage_50$inter,
      coverage_80 = coverage_80$inter,
      coverage_95 = coverage_95$inter,
      rmse = sqrt(safe_mean((mean_draw[interpolation_index] - truth[interpolation_index])^2)),
      rmle = safe_mean(abs((mean_draw[interpolation_index] - truth[interpolation_index]) / truth[interpolation_index]))
    ),
    data_pred = data.frame(
      coverage_50 = coverage_50$pred,
      coverage_80 = coverage_80$pred,
      coverage_95 = coverage_95$pred,
      rmse = sqrt(safe_mean((mean_draw[prediction_index] - truth[prediction_index])^2)),
      rmle = safe_mean(abs((mean_draw[prediction_index] - truth[prediction_index]) / truth[prediction_index]))
    )
  )
}

evaluate_global_interval_draws <- function(samples, truth, alpha = 0.2){
  lower <- apply(samples, 1, quantile, probs = alpha / 2)
  upper <- apply(samples, 1, quantile, probs = 1 - alpha / 2)

  data.frame(
    coverage = mean(truth >= lower & truth <= upper),
    interval_width = mean(upper - lower)
  )
}

evaluate_regionwise_interval_draws <- function(samples, truth, x,
                                               alpha = 0.2,
                                               breaks = quantile(x, probs = c(0, 1 / 3, 2 / 3, 1)),
                                               labels = c("left", "middle", "right")){
  lower <- apply(samples, 1, quantile, probs = alpha / 2)
  upper <- apply(samples, 1, quantile, probs = 1 - alpha / 2)
  region_index <- findInterval(x, vec = breaks, all.inside = TRUE, rightmost.closed = TRUE)

  result <- data.frame(
    coverage = vapply(seq_along(labels), function(i){
      selected <- region_index == i
      mean(truth[selected] >= lower[selected] & truth[selected] <= upper[selected])
    }, numeric(1)),
    interval_width = vapply(seq_along(labels), function(i){
      selected <- region_index == i
      mean(upper[selected] - lower[selected])
    }, numeric(1))
  )

  rownames(result) <- labels
  result
}
