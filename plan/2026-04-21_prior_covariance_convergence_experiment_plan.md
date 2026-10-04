# Prior Covariance Convergence Experiment Plan

Date: 2026-04-21

## Goal

Add an experiment that checks whether the FEM approximations for `mgp` and
`tiwp2` recover the prior covariance implied by the exact state-space
construction under multiple choices of the prior parameters `(a, c)`.

## Work Items

1. Identify how to construct the exact state-space prior covariance directly for
   both `mgp` and `tiwp2`.
2. Identify how to construct the corresponding FEM covariance directly from the
   design matrix and precision matrix for both models.
3. Build a reproducible analysis notebook that varies `(a, c)` and FEM
   refinement levels.
4. Render the notebook, inspect the resulting error trends, and save the
   summary metrics.
5. Record any implementation nuance required for a fair convergence check.
