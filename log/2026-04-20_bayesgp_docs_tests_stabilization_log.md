# Update Log: BayesGP Docs and Tests Stabilization

## Summary

Added documentation and regression tests to stabilize the near-monotone support
that was integrated into the local `BayesGP` fork.

## Test Harness

- Fixed `BayesGP/tests/testthat.R` so `test_check("BayesGP")` targets the local
  package instead of the stale `OSplines` package name.

## New Tests

- Added `BayesGP/tests/testthat/test-formula-interface.R`:
  - checks parsing of near-monotone formula terms
  - checks that `f()` stores `method` / `computation`
- Added `BayesGP/tests/testthat/test-near-monotone-gaussian.R`:
  - exact `mgp` with known Gaussian SD
  - exact `tiwp2` with known Gaussian SD
  - FEM `mgp` with known Gaussian SD
  - FEM `tiwp2` with known Gaussian SD
  - posterior extraction through `predict(..., only.samples = TRUE)`
  - exact-fit support-grid enforcement
- Added `BayesGP/tests/testthat/test-near-monotone-casecrossover.R`:
  - native `mgp` FEM fit inside the case-crossover family

## Documentation

- Updated `BayesGP/README.Rmd` and `BayesGP/README.md` with a direct example of:
  - `f(..., model = "mgp", method = "state-space")`
  - `control.family = list(sd = value)`
  - posterior extraction through `predict()`
- Updated manual pages:
  - `BayesGP/man/f.Rd`
  - `BayesGP/man/model_fit.Rd`
  - `BayesGP/man/predict.FitResult.Rd`
- Added `BayesGP/man/near_monotone_utils.Rd` for the near-monotone helper set.

## Additional Fix

- Updated the core fitting code so the `model` argument can be supplied through
  evaluated objects in the calling environment, not only as a literal string in
  the formula. This removes an inconsistency that showed up during test writing.

## Verification

- `Rscript --vanilla -e 'testthat::test_local("BayesGP")'`
  - passed (`56` tests)
- `R CMD INSTALL -l /tmp/Rlib BayesGP`
  - passed
