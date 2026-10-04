# Original-Scale Near-Monotone `c` Log

## Summary

Updated the near-monotone `mgp` and `tiwp2` formula interface so `c` is interpreted on the original input scale. Users now specify the base model directly as `m(x) = (x + c)^((a - 1) / a)` or `m(x) = log(x + c)` when `a = 1`. The package computes the centered internal shift as `initial_location + c`.

## Code Changes

- `BayesGP/R/08_near_monotone_instance_builders.R`
  - Parses formula-level `c` as `c_original`.
  - Computes `c_shift = initial_location + c_original` for state-space, FEM, and centered Box-Cox calculations.
  - Stores both `c` and `internal_shift` in near-monotone metadata.
  - Updated zero-argument validation messages and restrictions for original-scale semantics.
- `BayesGP/R/07_near_monotone_helpers.R`
  - Treats `sd.prior$x` as an original-scale location.
  - Converts `sd.prior$x` to centered coordinates only when computing the internal process-SD prior.
  - Adds `centered_x` to the converted prior for diagnostics.
- `BayesGP/R/03_post_fit.R`
  - Reports user-facing `c` in `print()` / `summary()` smooth-term tables.
- `BayesGP/R/01_utility.R`, `BayesGP/R/02_model_fit.R`, and `BayesGP/R/11_model_info.R`
  - Updated documentation text and model argument descriptions.
- `BayesGP/tests/testthat/test-near-monotone-gaussian.R`
  - Updated tests from shifted-`c` assumptions to original-scale `c`.
  - Added checks that normalized boundary basis coefficients correspond to level and first derivative at the reference location across `left`, `middle`, and `right` references for `mgp` and `tiwp2` under both state-space and FEM.
- `analysis/reference_location_consistency_check.R`
  - Uses original-scale `c` directly.
- `analysis/c_zero_shift_check.R`
  - Updated zero-argument checks to use a domain whose original-scale lower endpoint is zero.

## Validation

- Focused near-monotone Gaussian tests passed.
- Full test suite passed via:
  - `Rscript -e 'devtools::load_all("BayesGP", quiet = TRUE); testthat::test_dir("BayesGP/tests/testthat", reporter = "summary")'`
- Reference-location consistency check passed:
  - final prior Frobenius errors: `mgp/left 0.00123`, `mgp/middle 0.00360`, `tiwp2/left 1.49e-05`, `tiwp2/middle 1.35e-05`
  - posterior log marginal likelihood differences all below `0.001`
  - posterior mean relative RMSE all below `0.006`
- `c = 0` / small-positive-`c` check passed:
  - public `c = 0` on a domain touching `x + c = 0` is rejected unless explicitly supported
  - opt-in `mgp c = 0` left-reference covariance convergence reached Frobenius error `9.88e-06` at `k = 160`
- Installed package successfully with `R CMD INSTALL BayesGP`.

## Notes

The exact reverse mGP implementation still uses the adjoint process on the negative side for non-left references. This change only alters how user-level `c` is mapped into the centered internal coordinate system.
