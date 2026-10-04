# Reference Location Consistency Check Plan

Date: 2026-04-24

## Goal

Verify that the near-monotone `mgp` and `tiwp2` implementations agree between
`computation = "state-space"` and `computation = "fem"` for both the legacy
left-reference case and the new middle-reference case.

## Checks

1. Compare the stochastic-process prior covariance from FEM against the exact
   state-space covariance for `mgp` and `tiwp2`.
2. Check that the FEM covariance error decreases as `k` increases.
3. Fit a deterministic Gaussian probe dataset and compare FEM posterior
   prediction summaries against the state-space reference.
4. Compare the normalized log marginal likelihood between the two computation
   paths after including proper Gaussian prior normalizing constants.
5. Save machine-readable metrics under `output/`.

## Acceptance Criteria

- Final prior covariance relative Frobenius and max errors are below `0.01`.
- Prior covariance error decreases from the coarsest to the finest FEM grid.
- Posterior mean relative RMSE is below `0.02`.
- Posterior mean max absolute difference is below `0.05`.
- Absolute log marginal likelihood difference is below `0.05`.
- Posterior interval-width relative RMSE is below `0.08`.
