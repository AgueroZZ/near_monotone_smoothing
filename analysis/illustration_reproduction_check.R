library(devtools)
library(Matrix)

load_all("BayesGP", quiet = TRUE)
source("code/06-model-helpers.R")

obs_max <- 8
samp_max <- 10
c_shift <- 1
sd_noise <- 4
n <- 100
prior_median <- 5

set.seed(123)
truth_fun <- function(x) (3 + 4 * log(x + c_shift))^1.5
x <- seq(0, samp_max, length.out = n + 1)[-1]
y <- truth_fun(x) + rnorm(n, sd = sd_noise)

data_sim <- data.frame(x = x, y = y)
data_train <- subset(data_sim, x < obs_max)

d <- 2
p <- 2
psd_iwp <- prior_median / sqrt((d^((2 * p) - 1)) / (((2 * p) - 1) * (factorial(p - 1)^2)))
psd_tiwp2 <- prior_median / PSD_compute(model = "tiwp2", h = 2, sd = 1, x = 8, c = c_shift, a = 2)
psd_mgp <- prior_median / PSD_compute(model = "mgp", x = 8, h = 2, a = 2, c = c_shift)

summarize_samples <- function(samples, truth_x){
  lower <- apply(samples, 1, quantile, probs = 0.025)
  upper <- apply(samples, 1, quantile, probs = 0.975)
  c(
    max_abs_mean_diff = max(abs(rowMeans(samples) - truth_x)),
    rmse_mean = sqrt(mean((rowMeans(samples) - truth_fun(data_sim$x))^2)),
    avg_width = mean(upper - lower)
  )
}

compare_legacy_and_compact <- function(label, legacy_samples, compact_samples){
  legacy_summary <- summarize_samples(legacy_samples, rowMeans(compact_samples))
  compact_summary <- summarize_samples(compact_samples, rowMeans(legacy_samples))

  data.frame(
    model = label,
    max_abs_posterior_mean_diff = max(abs(rowMeans(legacy_samples) - rowMeans(compact_samples))),
    legacy_rmse = legacy_summary[["rmse_mean"]],
    compact_rmse = compact_summary[["rmse_mean"]],
    legacy_avg_width = legacy_summary[["avg_width"]],
    compact_avg_width = compact_summary[["avg_width"]]
  )
}

legacy_iwp <- fit_iwp_known_sd(data_sim, data_train, u = psd_iwp, sig_noise = sd_noise)
set.seed(1)
legacy_iwp_samples <- sample_exact_known_sd_fit(legacy_iwp, M = 3000)

compact_iwp <- model_fit(
  y ~ f(
    x,
    model = "iwp",
    computation = "state-space",
    order = 2,
    initial_location = "left",
    grid = data_sim$x,
    sd.prior = list(prior = "exp", param = list(u = psd_iwp, alpha = 0.5))
  ),
  data = data_train,
  family = "gaussian",
  control.family = list(sd = sd_noise),
  M = 3000
)
set.seed(1)
compact_iwp_samples <- as.matrix(
  predict(compact_iwp, newdata = data_sim, variable = "x", only.samples = TRUE)[, -1, drop = FALSE]
)

legacy_tiwp <- fit_tiwp_known_sd(
  data_sim,
  data_train,
  u = psd_tiwp2,
  a = 2,
  c = c_shift,
  sig_noise = sd_noise,
  normalized_transform = TRUE
)
set.seed(2)
legacy_tiwp_samples <- sample_exact_known_sd_fit(legacy_tiwp, M = 3000)

compact_tiwp <- model_fit(
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
  M = 3000
)
set.seed(2)
compact_tiwp_samples <- as.matrix(
  predict(compact_tiwp, newdata = data_sim, variable = "x", only.samples = TRUE)[, -1, drop = FALSE]
)

legacy_mgp <- fit_mgp_known_sd(
  data_sim,
  data_train,
  u = psd_mgp,
  a = 2,
  c = c_shift,
  sig_noise = sd_noise,
  normalized_boundary = TRUE
)
set.seed(3)
legacy_mgp_samples <- sample_exact_known_sd_fit(legacy_mgp, M = 3000)

compact_mgp <- model_fit(
  y ~ f(
    x,
    model = "mgp",
    computation = "state-space",
    a = 2,
    c = c_shift,
    grid = data_sim$x,
    normalized_boundary = TRUE,
    sd.prior = list(prior = "exp", param = list(u = prior_median, alpha = 0.5), h = 2, x = 8)
  ),
  data = data_train,
  family = "gaussian",
  control.family = list(sd = sd_noise),
  M = 3000
)
set.seed(3)
compact_mgp_samples <- as.matrix(
  predict(compact_mgp, newdata = data_sim, variable = "x", only.samples = TRUE)[, -1, drop = FALSE]
)

legacy_mgp_fem <- fit_mgp_fem_known_sd(
  data_sim,
  data_train,
  u = psd_mgp,
  a = 2,
  c = c_shift,
  sig_noise = sd_noise,
  k = 30,
  normalized_boundary = TRUE
)
set.seed(4)
legacy_mgp_fem_samples <- sample_mgp_fem_known_sd_fit(legacy_mgp_fem, M = 3000)

compact_mgp_fem <- model_fit(
  y ~ f(
    x,
    model = "mgp",
    computation = "fem",
    a = 2,
    c = c_shift,
    k = 30,
    grid = data_sim$x,
    normalized_boundary = TRUE,
    sd.prior = list(prior = "exp", param = list(u = prior_median, alpha = 0.5), h = 2, x = 8)
  ),
  data = data_train,
  family = "gaussian",
  control.family = list(sd = sd_noise),
  M = 3000
)
set.seed(4)
compact_mgp_fem_samples <- as.matrix(
  predict(compact_mgp_fem, newdata = data_sim, variable = "x", only.samples = TRUE)[, -1, drop = FALSE]
)

comparison_table <- do.call(
  rbind,
  list(
    compare_legacy_and_compact("iwp_state_space", legacy_iwp_samples, compact_iwp_samples),
    compare_legacy_and_compact("tiwp2_state_space", legacy_tiwp_samples, compact_tiwp_samples),
    compare_legacy_and_compact("mgp_state_space", legacy_mgp_samples, compact_mgp_samples),
    compare_legacy_and_compact("mgp_fem_k30", legacy_mgp_fem_samples, compact_mgp_fem_samples)
  )
)

print(comparison_table)
