# BayesGP Family-Aware FitResult Summary Log

Date: 2026-04-27

## Summary

Updated `FitResult` summaries so the top-level fit information is tailored to the fitted response family. Gaussian-only fields are no longer shown for case-crossover fits.

## Changes

- Added lightweight `family_info` metadata to `model_fit()` output.
- Updated `fit_result_info()` to append family-specific columns:
  - Gaussian fits show `gaussian_sd_known` and `gaussian_sd_value`.
  - Case-crossover fits show `strata`, `n_strata`, `max_stratum_size`, `count_source`, and `total_count`.
  - Binomial and Cox metadata helpers are included for future family-aware display.
- Updated `print.FitResult()` to show a concise strata line for case-crossover fits.
- Updated the `summary.FitResult()` S3 method signature to include `...`.
- Avoided the AGHQ cubic spline interpolation warning for `aghq_k < 4` by using polynomial interpolation in posterior density summaries when needed.
- Added targeted tests for Gaussian and case-crossover `summary.FitResult()` output.

## Verification

- Passed: `devtools::test(".", filter = "fitresult-usability", reporter = "summary")`
- Passed: `devtools::test(".", reporter = "summary")`
- Passed with existing package hygiene warnings/notes: `R CMD check --no-manual --ignore-vignettes --no-tests .`
