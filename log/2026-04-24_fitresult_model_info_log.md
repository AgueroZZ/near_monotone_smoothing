# Update Log: FitResult Diagnostics and Model Argument Introspection

## Summary

Added lightweight user-facing diagnostics for fitted BayesGP objects and a
model-argument lookup helper for formula smooth terms.

## Changes

- Added `print.FitResult()` so printing a fitted object shows:
  - response family
  - fixed Gaussian SD, when applicable
  - log marginal likelihood
  - number of smooth terms and posterior samples
  - smooth-term model, computation method, basis size, region, curvature, and
    `c` shift when available
- Updated `summary.FitResult()` to return fit diagnostics, smooth-term
  specifications, and the existing posterior/prior parameter table.
- Added `supported_models()` for a compact list of valid `f(..., model = ...)`
  choices.
- Added `model_arguments(model, computation)` for model-specific `f()`
  argument lookup, including near-monotone FEM `region / range` and the
  near-monotone default `c = 1`.
- Added regression coverage in
  `BayesGP/tests/testthat/test-near-monotone-gaussian.R`.

## Validation

- Ran:
  `Rscript -e 'devtools::load_all("BayesGP", quiet = TRUE); testthat::test_file("BayesGP/tests/testthat/test-near-monotone-gaussian.R")'`
- Result: all targeted near-monotone Gaussian tests passed.
