# Update Log: Near-Monotone Non-Left Reference Locations

## Summary

Extended BayesGP near-monotone terms so `initial_location` can be placed away
from the left boundary on supported computation paths.

## Changes

- Added `resolve_reference_location()` for near-monotone terms:
  - `"left"` maps to the left domain boundary
  - `"middle"` maps to the midpoint of the domain range
  - `"right"` maps to the right domain boundary
  - numeric values are allowed inside the domain
- Added two-sided FEM construction for `mgp`:
  - positive side uses `Compute_Prec()`
  - negative side uses `Compute_Prec_rev()`
  - random-effect design matrices and precision matrices are combined across
    sides
- Added two-sided FEM construction for `tiwp2` on the transformed scale.
- Added two-sided exact state-space support for `tiwp2` by splitting positive
  and negative transformed supports into independent IWP2 precision blocks.
- Added two-sided exact state-space support for `mgp` using the adjoint
  reverse-side transition/covariance functions from
  `code/04-state-space-adjoint.R`.
- Reverse exact `mgp` state-space currently supports non-left references only
  for `a` equal to 1, 2, or -1; unsupported curvatures fail clearly and direct
  users to the FEM path.
- Updated prediction helpers for two-sided FEM and exact `tiwp2`.
- Updated model-info text and FitResult smooth-term output to include the
  reference location.
- Added regression tests in
  `BayesGP/tests/testthat/test-near-monotone-gaussian.R`.

## Important Parameter Note

The package still interprets `c` on the shifted coordinate scale. The domain
must satisfy:

```r
x - initial_location + c > 0
```

For example, if the intended original-scale transform is based on `x + c0`,
then use `c = initial_location + c0` in the compact interface.

## Validation

- Ran:
  `Rscript -e 'devtools::load_all("BayesGP", quiet = TRUE); testthat::test_file("BayesGP/tests/testthat/test-near-monotone-gaussian.R")'`
- Result: all targeted tests passed.
- Also smoke-tested toy `mgp` FEM and exact state-space fits with
  `initial_location = "middle"` and prediction over `x = 0.1..15`.
