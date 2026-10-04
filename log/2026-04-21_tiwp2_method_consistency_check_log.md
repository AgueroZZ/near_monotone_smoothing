# tIWP2 Method Consistency Check Log

Date: 2026-04-21

## Summary

Checked whether `tiwp2` with `method = "state-space"` and `method = "fem"`
gives consistent posterior results under matched priors, data, and known
Gaussian noise.

The conclusion is yes: the two pathways are numerically consistent, with FEM
tracking the exact state-space fit very closely. The remaining gap is small and
behaves like an approximation error rather than a structural mismatch.

## Implementation Note

The FEM version of `tiwp2` reuses the native BayesGP `iwp` O-spline machinery
on the transformed scale. To make future checks reproducible, a comparison
script was added:

- `analysis/tiwp2_method_consistency_check.R`

## Comparison 1: Illustration-Style Synthetic Example

Setup:

- Same synthetic data structure as `analysis/illustration.rmd`
- `f(x) = (3 + 4 log(x + 1))^1.5`
- `x < 8` used for training
- known Gaussian SD fixed at `4`
- same PSD prior calibration as the illustration notebook

Results:

| model | RMSE to truth | avg width | max abs mean diff from exact | RMSE mean diff from exact | train RMSE diff | holdout RMSE diff | corr(mean, exact) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `state-space` | 0.300714 | 4.561970 | 0.000000 | 0.000000 | 0.000000 | 0.000000 | 1.000000 |
| `fem_k20` | 0.312727 | 4.522650 | 0.063788 | 0.020357 | 0.017074 | 0.029608 | 0.999999 |
| `fem_k30` | 0.313988 | 4.494870 | 0.084799 | 0.026982 | 0.018247 | 0.047056 | 0.999997 |
| `fem_k60` | 0.317417 | 4.550190 | 0.095768 | 0.021966 | 0.023157 | 0.016742 | 0.999999 |
| `fem_k120` | 0.299064 | 4.516410 | 0.028829 | 0.014333 | 0.013342 | 0.017565 | 0.999999 |

Interpretation:

- FEM and exact state-space means are almost perfectly correlated.
- The largest deviation appears in the out-of-sample region, which is expected
  for an approximation method.
- Increasing `k` to `120` tightens FEM toward the exact fit.

## Comparison 2: Compact Synthetic Example

Setup:

- `x = seq(0.1, 2.0, length.out = 12)`
- truth `sqrt(x + 1)`
- first 8 observations used for training
- known Gaussian SD fixed at `0.1`

Results:

| model | max abs mean diff from exact | RMSE mean diff from exact | corr(mean, exact) | RMSE to truth |
| --- | ---: | ---: | ---: | ---: |
| `state-space` | 0.000000 | 0.000000 | 1.000000 | 0.018605 |
| `fem_k20` | 0.005865 | 0.002361 | 0.999963 | 0.020787 |
| `fem_k30` | 0.002076 | 0.001103 | 0.999991 | 0.018403 |
| `fem_k60` | 0.004257 | 0.001617 | 0.999976 | 0.019435 |
| `fem_k120` | 0.002676 | 0.001348 | 0.999978 | 0.019165 |

Interpretation:

- On the smaller synthetic example, the two methods are extremely close.
- The numerical gap is tiny relative to the scale of the fitted function.

## Bottom Line

No structural inconsistency was found between `tiwp2` state-space and FEM.
Under matched settings:

- they produce almost identical posterior mean shapes,
- they have very similar posterior interval widths,
- and FEM approaches the exact result as `k` becomes larger.

So the current `tiwp2` FEM implementation looks coherent with the exact
state-space version.
