# BayesGP near-monotone class and PSD density log

## Context

`model_fit()` stored near-monotone `mgp` and `tiwp2` fitted terms as native
`iwp` S4 objects. This made `class(fit$instances[[1]])` misleading and allowed
`var_density(..., h = ...)` to use native IWP PSD scaling for `tiwp2`, which is
incorrect on the original input scale.

## Changes

- Added first-class `mgp` and `tiwp2` S4 classes with the shared matrix fields
  consumed by the fitter.
- Updated near-monotone instance construction to preserve the model class.
- Split native IWP checks from boundary-design handling in fitting and sample
  indexing.
- Extended `var_density()` and `var_plot()` with `x = NULL` and model-specific
  PSD correction for near-monotone terms.
- Added tests for near-monotone class identity, plotting, and PSD density
  scaling with stored and overridden original-scale `x`.
- Bumped `BayesGP` to version `0.1.3` and updated `NEWS.md`.

## Validation

- `testthat::test_file("BayesGP/tests/testthat/test-near-monotone-gaussian.R")`: passed.
- `testthat::test_file("BayesGP/tests/testthat/test-fitresult-usability.R")`: passed.
- `testthat::test_file("BayesGP/tests/testthat/test-psd-helpers.R")`: passed.
- `devtools::document("BayesGP")`: regenerated `var_density.Rd` and `var_plot.Rd`.
- `devtools::test("BayesGP", reporter = "summary")`: passed.
- `R CMD build --no-build-vignettes BayesGP`: built `BayesGP_0.1.3.tar.gz`.
- `R CMD check --no-manual --ignore-vignettes BayesGP_0.1.3.tar.gz`: `Status: OK`.
- `R CMD INSTALL -l /Users/ziangzhang/Library/R/arm64/4.5/library BayesGP`: installed version `0.1.3`.
- Installed smoke check: `class(mod_tiwp2$instances[[1]])` is `"tiwp2"` and
  `var_density(mod_tiwp2, component = "x")` returns `PSD`, `post.PSD`, and
  `prior.PSD`.
