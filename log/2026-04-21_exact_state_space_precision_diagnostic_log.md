# Update Log: Exact State-Space Precision Diagnostic Fix

Date: 2026-04-21

## Summary

Relaxed the exact state-space precision-matrix singularity guard in the local
`BayesGP` fork so well-spaced regular support grids are no longer rejected
purely because `rcond()` is small.

This fixes the false positive encountered in `analysis/casecross.rmd` for the
rounded PM2.5 grid used with:

- `f(x_rounded, model = "mgp", computation = "state-space", ...)`

where `min gap = 0.1` but the previous hard `rcond < 1e-10` cutoff still
stopped model construction.

## Implementation

- Updated `BayesGP/R/07_near_monotone_helpers.R`:
  - `build_exact_precision_with_diagnostics()` no longer treats a small
    `rcond()` value as a fatal condition by itself.
  - The diagnostic now attempts a Cholesky factorization and only errors when
    the precision matrix actually fails that positive-definiteness check.
  - The singularity error message still reports `rcond`, support-grid gap, and
    support-point count for debugging.

## Regression Coverage

- Added a new regression test in
  `BayesGP/tests/testthat/test-near-monotone-gaussian.R` that verifies a
  regular `0.1`-spaced support grid for exact `mgp` builds without error.
- Kept the existing nearly-duplicated-grid test in place, so true numerical
  singularities still fail early.

## Verification

- `testthat::test_file("BayesGP/tests/testthat/test-near-monotone-gaussian.R")`
  - passed
- `testthat::test_file("BayesGP/tests/testthat/test-exact-iwp-state-space.R")`
  - passed
- Reproduced the `analysis/casecross.rmd` rounded-grid fit with local
  `devtools::load_all("BayesGP", quiet = TRUE)`
  - exact `mgp` state-space fit now proceeds past precision construction and
    completes successfully
