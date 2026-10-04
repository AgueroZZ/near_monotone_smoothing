# IWP Prior Covariance Convergence Log

Date: 2026-04-21

## Summary

Checked whether the exact order-2 `iwp` state-space construction added in the
local `BayesGP` fork is coherent with the package's original O-spline
approximation at the prior covariance level.

The conclusion is yes. Under matched left-boundary anchoring, the native
O-spline covariance converges cleanly to the exact state-space covariance as
`k` increases.

## Implementation Notes

Two reproducible artifacts were added:

- `analysis/iwp_prior_covariance_convergence.rmd`
- `BayesGP/tests/testthat/test-iwp-state-space-prior-covariance.R`

The notebook compares

- exact covariance from `IWP_joint_prec()` plus the exact observation matrix,
- against native O-spline covariance from `local_poly()` and
  `compute_weights_precision()`.

The comparison is done on the stochastic process component only, with the
boundary/global polynomial term fixed at zero. Because both paths scale in
`sd^2`, the check is carried out at unit scale.

## Numerical Results

Two irregular evaluation grids were used:

- `balanced irregular`
- `boundary clustered`

Relative Frobenius errors across refinement levels:

| grid case | `k = 10` | `k = 20` | `k = 40` | `k = 80` | `k = 160` | `k = 320` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| balanced irregular | 4.77e-03 | 1.08e-03 | 2.58e-04 | 6.28e-05 | 1.55e-05 | 3.85e-06 |
| boundary clustered | 4.33e-03 | 9.69e-04 | 2.30e-04 | 5.62e-05 | 1.39e-05 | 3.45e-06 |

Largest-k maximum relative entrywise errors:

- balanced irregular: `2.46e-06`
- boundary clustered: `2.46e-06`

These results show the expected convergence pattern and do not suggest any
structural mismatch between the new exact state-space path and the native
O-spline approximation.

## Important Nuance

The exact state-space `iwp` path currently enforces left-boundary anchoring.
So this verification was carried out under matched left-boundary anchoring for
both constructions. That is the correct apples-to-apples comparison for the
current implementation.
