# tIWP2 FEM Boundary Prediction Log

## Context

The left-reference tIWP2 FEM prediction branch passed the fitted boundary
coefficient directly to the native IWP prediction helper. That helper used the
normalized transformed coordinate as its boundary basis even when fitting had
used an unnormalized original-scale Box-Cox basis. Consequently, posterior
curves could disagree with the fitted model, including when an intercept was
included.

The correction is based on BayesGP commit `8d50e96`.
The package fix was subsequently committed as `7d8ad78` on
`bayesgp-near-monotone-usability` at the user's request.

## Changes

- Set `global_samps = NULL` in the left-reference native IWP reconstruction
  call, then add the boundary contribution through `boundary_basis_matrix()`
  with the fitted normalization setting.
- Retain the fitted process coordinate, priors, and intercept handling.
- Add an independent regression check against the fitted design matrices
  for each posterior draw, with and without the intercept.
- Check the analytic boundary contribution on a new evaluation grid for
  `a = 2` and `a = 1`, both normalization choices, and left, middle, and right
  references.
- Add a development release note in `BayesGP/NEWS.md`.

## Validation

- Before the correction, the initial regression test produced three failures
  for the left-reference, unnormalized case: `smooth_samples()` and
  `predict()` with and without the intercept. The other reference and
  normalization cases passed.
- After the correction, the expanded targeted test passed all 48 assertions.
- `OPENBLAS_NUM_THREADS=1 Rscript -e 'devtools::test(".", reporter = "summary", stop_on_failure = TRUE)'`:
  passed all nine test files.
- `git diff --check`: passed in both repos.

## Notes

This update addresses the first review finding only. Analysis pages and their
rendered HTML were not changed or published.
