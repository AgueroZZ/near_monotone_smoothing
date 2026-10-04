library(BayesGP)

### simulate a dataset:
set.seed(123)

true_shift <- 2
f <- function(x) {
  15 * log(x + true_shift)
}

x <- seq(-1, 10, by = 0.1)
y <- f(x) + rnorm(length(x), sd = 5)

plot(x, y)

df <- data.frame(x = x, y = y)

mod_mgp <- model_fit(
  formula = y ~ f(
    x,
    model = "mgp",
    computation = "fem",
    a = 2,
    c = 1,
    region = c(-1, 16),
    initial_location = "left",
    normalized_boundary = TRUE,
    boundary.prior = list(mean = 0, prec = 0.001),
    sd.prior = list(
      prior = "exp",
      param = list(u = 1, alpha = 0.5),
      h = 5,
      x = 0
    )
  ),
  data = df
)

mod_mgp$mod$normalized_posterior$lognormconst
# -141.7817
# -137.889

pred_result <- predict(
  mod_mgp,
  variable = "x",
  newdata = data.frame(x = seq(-1, 15, by = 0.1))
)
plot(pred_result$mean ~ pred_result$x, type = "l", col = "red")
# add the truth
lines(f(pred_result$x) ~ pred_result$x, col = "blue", lty = 2)
polygon(
  c(pred_result$x, rev(pred_result$x)),
  c(pred_result$q0.025, rev(pred_result$q0.975)),
  col = rgb(1, 0, 0, 0.2),
  border = NA
)
points(x, y, cex = 0.1)
