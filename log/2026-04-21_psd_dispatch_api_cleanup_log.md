# Update Log: PSD Dispatch API Cleanup

Date: 2026-04-21

## Summary

Reworked the predictive-standard-deviation helper API so `BayesGP` now exposes
a single dispatcher:

- `PSD_compute(model, h, x = NULL, sd = 1, ...)`

instead of overloading `PSD_compute()` with an `mgp`-specific meaning and
keeping a separate `PSD_tIWP2_compute()` entry point.

## Package Changes

- Updated `BayesGP/R/07_near_monotone_helpers.R`:
  - added `normalize_psd_model()`
  - added `PSD_compute_tiwp2()`
  - redefined `PSD_compute()` as a model dispatcher for:
    - `mgp`
    - `tiwp2`
    - `iwp`
    - `sgp`
- Updated `BayesGP/R/04_near_monotone_state_space.R`:
  - renamed the exact mGP helper implementation to `PSD_compute_mgp()`
  - updated `prior_conversion_mgp()` to use the renamed backend
- Updated `BayesGP/R/01_utility.R`:
  - added `PSD_compute_iwp()`
  - added `PSD_compute_sgp()`
  - routed `prior_conversion_iwp()` and `prior_conversion_sgp()` through those
    model-specific PSD helpers
- Updated `BayesGP/NAMESPACE` so the PSD helpers and `prior_conversion_mgp()`
  are available under `library(BayesGP)`.
- Updated `BayesGP/man/near_monotone_utils.Rd` to document the dispatcher and
  the model-specific PSD helper functions.

## Repository Alignment

- Updated active analysis sources to use the dispatcher form:
  - `analysis/casecross.rmd`
  - `analysis/illustration.rmd`
  - `analysis/simulation1.rmd`
  - `analysis/simulation2.rmd`
  - `analysis/PSD.rmd`
  - `analysis/tiwp2_method_consistency_check.R`
  - `analysis/illustration_reproduction_check.R`
- Updated the transitional `NearMonotoneGP` layer to use the same PSD helper
  names.
- Updated the legacy `code/` helper layer and regression script so local
  reference code no longer advertises the old `PSD_tIWP2_compute()` naming.

## Regression Coverage

- Added `BayesGP/tests/testthat/test-psd-helpers.R` to verify:
  - dispatcher routing
  - argument validation
  - consistency between PSD helpers and `prior_conversion_*()` utilities

## Verification

- `testthat::test_file("BayesGP/tests/testthat/test-psd-helpers.R")`
  - passed
- `testthat::test_file("BayesGP/tests/testthat/test-near-monotone-gaussian.R")`
  - passed
- `testthat::test_file("BayesGP/tests/testthat/test-exact-iwp-state-space.R")`
  - passed
- `devtools::load_all("NearMonotoneGP", quiet = TRUE)` followed by a
  `PSD_compute(model = "tiwp2", ...)` smoke call
  - passed
- `source("code/01-state-space.R")`,
  `source("code/06-model-helpers.R")`, and
  `source("code/07-regression-checks.R")`
  - passed
- `R CMD INSTALL -l /tmp/Rlib BayesGP`
  - passed
- `library(BayesGP)` from both `/tmp/Rlib` and the user library
  - `PSD_compute(...)` available and callable

## Notes

- Historical rendered `.html` outputs in `analysis/` and `docs/` still show the
  old helper names until the workflowr site is rebuilt.
