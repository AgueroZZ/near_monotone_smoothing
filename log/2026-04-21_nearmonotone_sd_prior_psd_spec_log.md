# Update Log: Near-Monotone `sd.prior` PSD Specification

Date: 2026-04-21

## Summary

Added PSD-scale prior specification support for near-monotone terms in the
local `BayesGP` fork, so `mgp` and `tiwp2` can now accept the target
predictive-standard-deviation prior directly inside `sd.prior`.

This removes the need to manually divide the desired PSD-scale prior bound by a
model-specific correction factor immediately before calling `model_fit()`.

## Package Changes

- Updated `BayesGP/R/07_near_monotone_helpers.R`:
  - added `resolve_step_prior_value()`
  - added `convert_nearmono_sd_prior()`
  - near-monotone terms now accept:
    - `sd.prior$h` or `sd.prior$step`
    - `sd.prior$x`
  - when supplied, the original PSD prior is stored in `psd.prior` and the
    internal `sd.prior$param` is converted to the latent `sigma` scale
- Updated `BayesGP/R/08_near_monotone_instance_builders.R` so both exact and
  FEM near-monotone terms apply the new conversion during instance
  construction.
- Updated `BayesGP/R/04_near_monotone_state_space.R`:
  - fixed `prior_conversion_mgp()` to return the package-standard
    `list(u, alpha)` structure
  - added `prior_conversion_tiwp2()` for the transformed IWP2 PSD scale
- Updated `BayesGP/NAMESPACE` and `BayesGP/man/near_monotone_utils.Rd` to
  expose and document the new helper surface.
- Updated `BayesGP/man/model_fit.Rd` to mention the new near-monotone
  `sd.prior` usage.

## Source Updates

- Updated active analysis sources to use direct PSD-scale prior specifications:
  - `analysis/casecross.rmd`
  - `analysis/illustration.rmd`
  - `analysis/tiwp2_method_consistency_check.R`
- Updated `analysis/PSD.rmd`:
  - replaced the old `prob` field with `alpha` in the
    `prior_conversion_mgp()` example
  - added a direct `model_fit(..., sd.prior = list(..., h = ..., x = ...))`
    example for `mgp`
- Updated `analysis/illustration_reproduction_check.R`:
  - compact `BayesGP` fits now use the direct PSD prior specification
  - legacy helper fits still keep the explicit converted `u` values for the
    apples-to-apples comparison

## Regression Coverage

- Added coverage in `BayesGP/tests/testthat/test-near-monotone-gaussian.R` for:
  - PSD-scale `sd.prior` conversion for exact `mgp`
  - PSD-scale `sd.prior` conversion for exact `tiwp2`
  - validation that `sd.prior$x` is required when `h` / `step` is supplied
- Updated `BayesGP/tests/testthat/test-psd-helpers.R` so:
  - `prior_conversion_mgp()` is checked against `alpha`
  - `prior_conversion_tiwp2()` is covered

## Verification

- `testthat::test_file("BayesGP/tests/testthat/test-psd-helpers.R")`
  - passed
- `testthat::test_file("BayesGP/tests/testthat/test-near-monotone-gaussian.R")`
  - passed
- `analysis/illustration_reproduction_check.R`
  - ran successfully after the compact-prior API update
- `devtools::load_all("BayesGP", quiet = TRUE)` case-crossover smoke fit using:
  - `sd.prior = list(prior = "exp", param = list(u = 0.01, alpha = 0.5), h = 5, x = 0)`
  - passed
- reinstalled `BayesGP` into the user library at:
  - `/Users/ziangzhang/Library/R/arm64/4.5/library/BayesGP`
- `library(BayesGP)` smoke fit from the installed package
  - confirmed the converted internal `sd.prior` and preserved `psd.prior`
    values
