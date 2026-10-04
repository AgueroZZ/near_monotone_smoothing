reference_x <- 10
set.seed(123)
### Write a non-linear function that is close to log but not exactly log
f <- function(x) {
  2 * log(x) * (1 + 0.5 * sin(x / 50))
}
f_deriv <- function(x) {
  2 * (1 + 0.5 * sin(x / 50)) / x + 2 * log(x) * (0.5 * cos(x / 50) / 50)
}
f_second_deriv <- function(x) {
  -2 *
    (1 + 0.5 * sin(x / 50)) /
    x^2 +
    2 * (0.5 * cos(x / 50) / 50) / x +
    2 * (0.5 * cos(x / 50) / 50) / x +
    2 * log(x) * (-0.5 * sin(x / 50) / 2500)
}
### Simulate some data
set.seed(123)
x <- runif(100, min = 0.1, max = 90)
y <- f(x) + rnorm(length(x), mean = 0, sd = 1)
plot(
  x,
  y,
  main = "Non-linear function close to sqrt",
  xlab = "x",
  ylab = "y",
  cex = 0.5
)
lines(
  seq(0.1, 90, by = 0.1),
  f(seq(0.1, 90, by = 0.1)),
  col = "blue",
  lwd = 1,
  lty = 2
)
library(BayesGP)
df <- data.frame(x = x, y = y)


##########################################
##########################################
##########################################
##########################################
### What if we fit a IWP2
mod_iwp2 <- model_fit(
  formula = y ~ f(
    x,
    model = "iwp",
    order = 2,
    region = c(0.1, 120),
    initial_location = reference_x,
    boundary.prior = list(mean = f_deriv(reference_x), prec = 100),
    sd.prior = list(prior = "exp", param = list(u = 1, alpha = 0.5), h = 10)
  ),
  data = df,
  family = "gaussian"
)
# mean(BayesGP:::extract_boundary_samples(mod_iwp2, component = "x"))

## Plot the posterior of sigma(h)
psd_density <- var_density(mod_iwp2, component = "x", h = 10)
matplot(
  psd_density$PSD,
  psd_density[, c("post.PSD", "prior.PSD")],
  type = "l",
  lty = c(1, 2),
  col = c("black", "red"),
  xlab = expression(sigma(h == 10)),
  ylab = "Density",
  main = "Posterior vs prior of 10-step PSD"
)
legend(
  "topright",
  lty = c(1, 2),
  col = c("black", "red"),
  legend = c("posterior", "prior"),
  bty = "n"
)
## Predict into the future!
x_new <- seq(0, 110, by = 0.5)
pred_iwp2 <- predict(
  mod_iwp2,
  variable = "x",
  newdata = data.frame(x = x_new)
)
plot(
  pred_iwp2$mean ~ pred_iwp2$x,
  type = "l",
  col = "red",
  lwd = 1.5,
  xlab = "x",
  ylab = "f(x)",
  main = "IWP2 posterior mean with extrapolation to x in [100, 150]"
)
polygon(
  c(pred_iwp2$x, rev(pred_iwp2$x)),
  c(pred_iwp2$q0.025, rev(pred_iwp2$q0.975)),
  col = rgb(1, 0, 0, 0.1),
  border = NA
)
lines(
  seq(0.1, 110, by = 0.1),
  f(seq(0.1, 110, by = 0.1)),
  col = "blue",
  lty = 2
)
points(x, y, cex = 0.4)


##########################################
##########################################
##########################################
##########################################
### What if we fit a tIWP2
mod_tiwp2 <- model_fit(
  formula = y ~ f(
    x,
    model = "tiwp2",
    a = 1,
    c = 0,
    initial_location = reference_x,
    region = c(0.1, 120),
    boundary.prior = list(mean = f_deriv(reference_x), prec = 100),
    sd.prior = list(
      prior = "exp",
      param = list(u = 1, alpha = 0.5),
      h = 10,
      x = reference_x
    )
  ),
  data = df,
  family = "gaussian"
)
## Plot the posterior of sigma(h)
psd_density <- var_density(mod_tiwp2, component = "x")
matplot(
  psd_density$PSD,
  psd_density[, c("post.PSD", "prior.PSD")],
  type = "l",
  lty = c(1, 2),
  col = c("black", "red"),
  xlab = expression(sigma(h == 10)),
  ylab = "Density",
  main = "Posterior vs prior of 10-step PSD"
)
legend(
  "topright",
  lty = c(1, 2),
  col = c("black", "red"),
  legend = c("posterior", "prior"),
  bty = "n"
)
## Predict into the future!
x_new <- seq(0.5, 110, by = 0.5)
pred_tiwp2 <- predict(
  mod_tiwp2,
  variable = "x",
  newdata = data.frame(x = x_new)
)
plot(
  pred_tiwp2$mean ~ pred_tiwp2$x,
  type = "l",
  col = "red",
  lwd = 1.5,
  xlab = "x",
  ylab = "f(x)",
  main = "tIWP2 posterior mean with extrapolation to x in [100, 150]"
)
polygon(
  c(pred_tiwp2$x, rev(pred_tiwp2$x)),
  c(pred_tiwp2$q0.025, rev(pred_tiwp2$q0.975)),
  col = rgb(1, 0, 0, 0.1),
  border = NA
)
lines(sort(x_new), f(sort(x_new)), col = "blue", lty = 2)
points(x, y, cex = 0.4)


##########################################
##########################################
##########################################
##########################################
### What if we fit a mGP
mod_mgp <- model_fit(
  formula = y ~ f(
    x,
    model = "mgp",
    a = 1,
    c = 0,
    region = c(0.1, 120),
    initial_location = reference_x,
    boundary.prior = list(mean = f_deriv(reference_x), prec = 100),
    sd.prior = list(
      prior = "exp",
      param = list(u = 1, alpha = 0.5),
      h = 10,
      x = reference_x
    ),
  ),
  data = df,
  family = "gaussian"
)
## Plot the posterior of sigma(h)
psd_density <- var_density(mod_mgp, component = "x")
matplot(
  psd_density$PSD,
  psd_density[, c("post.PSD", "prior.PSD")],
  type = "l",
  lty = c(1, 2),
  col = c("black", "red"),
  xlab = expression(sigma(h == 10)),
  ylab = "Density",
  main = "Posterior vs prior of 10-step PSD"
)
legend(
  "topright",
  lty = c(1, 2),
  col = c("black", "red"),
  legend = c("posterior", "prior"),
  bty = "n"
)
## Predict into the future!
x_new <- seq(0.5, 110, by = 0.5)
pred_mgp <- predict(
  mod_mgp,
  variable = "x",
  newdata = data.frame(x = x_new)
)
plot(
  pred_mgp$mean ~ pred_mgp$x,
  type = "l",
  col = "red",
  lwd = 1.5,
  xlab = "x",
  ylab = "f(x)",
  main = "mGP posterior mean with extrapolation to x in [100, 150]"
)
polygon(
  c(pred_mgp$x, rev(pred_mgp$x)),
  c(pred_mgp$q0.025, rev(pred_mgp$q0.975)),
  col = rgb(1, 0, 0, 0.1),
  border = NA
)
lines(sort(x_new), f(sort(x_new)), col = "blue", lty = 2)
points(x, y, cex = 0.4)
