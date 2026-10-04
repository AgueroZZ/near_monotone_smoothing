library(devtools)

load_all("BayesGP", quiet = TRUE)

set.seed(123)
obs_max <- 8
samp_max <- 10
c_shift <- 1
sd_noise <- 4
n <- 100
prior_median <- 5

truth_fun <- function(x) (3 + 4 * log(x + c_shift))^1.5
x <- seq(0, samp_max, length.out = n + 1)[-1]
y <- truth_fun(x) + rnorm(n, sd = sd_noise)

data_sim <- data.frame(x = x, y = y)
data_train <- subset(data_sim, x < obs_max)

fit_exact <- model_fit(
  y ~ f(
    x,
    model = "tiwp2",
    computation = "state-space",
    a = 2,
    c = c_shift,
    grid = data_sim$x,
    sd.prior = list(prior = "exp", param = list(u = prior_median, alpha = 0.5), h = 2, x = 8)
  ),
  data = data_train,
  family = "gaussian",
  control.family = list(sd = sd_noise),
  M = 4000
)

exact_samples <- as.matrix(
  predict(fit_exact, newdata = data_sim, variable = "x", only.samples = TRUE)[, -1, drop = FALSE]
)

summarize_vs_exact <- function(label, samples, exact_reference){
  mean_fit <- rowMeans(samples)
  mean_exact <- rowMeans(exact_reference)
  lower <- apply(samples, 1, quantile, probs = 0.025)
  upper <- apply(samples, 1, quantile, probs = 0.975)
  lower_exact <- apply(exact_reference, 1, quantile, probs = 0.025)
  upper_exact <- apply(exact_reference, 1, quantile, probs = 0.975)
  train_index <- data_sim$x < obs_max
  holdout_index <- !train_index

  data.frame(
    model = label,
    rmse_to_truth = sqrt(mean((mean_fit - truth_fun(data_sim$x))^2)),
    avg_width = mean(upper - lower),
    max_abs_mean_diff_from_exact = max(abs(mean_fit - mean_exact)),
    rmse_mean_diff_from_exact = sqrt(mean((mean_fit - mean_exact)^2)),
    rmse_mean_diff_train = sqrt(mean((mean_fit[train_index] - mean_exact[train_index])^2)),
    rmse_mean_diff_holdout = sqrt(mean((mean_fit[holdout_index] - mean_exact[holdout_index])^2)),
    avg_abs_width_diff_from_exact = mean(abs((upper - lower) - (upper_exact - lower_exact))),
    corr_mean_with_exact = cor(mean_fit, mean_exact)
  )
}

comparison_rows <- list(
  summarize_vs_exact("state-space", exact_samples, exact_samples)
)

for(k in c(20, 30, 60, 120)){
  fit_fem <- model_fit(
    y ~ f(
      x,
      model = "tiwp2",
      computation = "fem",
      a = 2,
      c = c_shift,
      k = k,
      grid = data_sim$x,
      sd.prior = list(prior = "exp", param = list(u = prior_median, alpha = 0.5), h = 2, x = 8)
    ),
    data = data_train,
    family = "gaussian",
    control.family = list(sd = sd_noise),
    M = 4000
  )

  fem_samples <- as.matrix(
    predict(fit_fem, newdata = data_sim, variable = "x", only.samples = TRUE)[, -1, drop = FALSE]
  )

  comparison_rows[[length(comparison_rows) + 1]] <- summarize_vs_exact(
    paste0("fem_k", k),
    fem_samples,
    exact_samples
  )
}

comparison_table <- do.call(rbind, comparison_rows)
print(comparison_table, digits = 6)
