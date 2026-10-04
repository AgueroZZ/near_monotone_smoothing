# tIWP2 FEM Boundary Prediction Plan

## Goal

Make posterior predictions for tIWP2 FEM terms use the same boundary basis as
the fitted model, including `normalized_boundary = FALSE` at a left reference.

## Implementation plan

- Reproduce the discrepancy between posterior predictions and the fitted
  design matrices using the same coefficient draws.
- Reconstruct the FEM process on its normalized transformed coordinate without
  a boundary contribution from the native IWP prediction helper.
- Add the boundary contribution using the fitted near-monotone basis and keep
  the existing intercept handling.
- Add regression coverage for square-root and logarithmic base functions,
  both boundary normalization choices, all three reference positions, and
  predictions on a new evaluation grid.
- Record the software correction in BayesGP's development release notes.

## Validation targets

- Confirm the new regression test fails on the original left-reference,
  unnormalized implementation.
- Run `testthat::test_file("tests/testthat/test-tiwp2-fem-boundary-prediction.R")`
  after the correction.
- Run `devtools::test(".", reporter = "summary", stop_on_failure = TRUE)`
  in the BayesGP repo with `OPENBLAS_NUM_THREADS=1`.
- Run `git diff --check` in both repos.
