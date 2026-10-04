# IWP Prior Covariance Convergence Plan

Date: 2026-04-21

## Goal

Verify that the newly added exact order-2 `iwp` state-space construction in the
local `BayesGP` fork is coherent with the package's native O-spline
approximation, by checking whether the O-spline prior covariance converges to
the exact state-space prior covariance as `k` increases.

## Work Items

1. Reuse the same low-level covariance definitions that back the two
   implementations:
   - exact state-space via `IWP_joint_prec()` plus the exact observation matrix,
   - native O-spline via `local_poly()` and `compute_weights_precision()`.
2. Compare the two prior covariances on representative irregular evaluation
   grids under the left-boundary anchoring currently required by the exact
   state-space implementation.
3. Record the experiment in a reproducible notebook under `analysis/`.
4. Add a lightweight regression test that checks the approximation error is
   small for a refined O-spline representation and decreases relative to a
   coarse one.
