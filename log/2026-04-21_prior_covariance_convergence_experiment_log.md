# Prior Covariance Convergence Experiment Log

Date: 2026-04-21

## Summary

Added a new analysis notebook to check whether the FEM prior covariance for
`mgp` and `tiwp2` converges to the prior covariance implied by the exact
state-space construction across multiple choices of `(a, c)`.

New files:

- `analysis/prior_covariance_convergence.rmd`
- `analysis/prior_covariance_convergence.html`
- `output/prior_covariance_convergence_metrics.csv`

## What the Experiment Compares

The notebook compares the covariance of the stochastic process component only.
The boundary/global polynomial contribution is fixed at zero so that the exact
state-space covariance and the FEM covariance are defined on the same latent
object.

Exact covariance:

- `mgp`: invert `mGP_joint_prec(...)` and extract the function-value block
- `tiwp2`: transform to the normalized Box-Cox scale, invert
  `IWP_joint_prec(...)`, and extract the function-value block

FEM covariance:

- `mgp`: `B Q^{-1} B^T` from `Compute_Design(...)` and `Compute_Prec(...)`
- `tiwp2`: transformed-scale O-spline covariance from the native `iwp`
  O-spline basis and weights precision

## Important Nuance Found During the Check

For `tiwp2`, increasing `k` alone is the natural refinement path.

For `mgp`, increasing `k` alone is not a fair convergence experiment, because
`Compute_Prec()` itself uses numerical integration. With a fixed integration
step size, the covariance error can plateau or drift slightly even though the
approximation is already very accurate. A fair refinement path for `mgp` must
refine both:

- FEM basis size `k`
- integration step size `accuracy`

The notebook therefore uses:

- `tiwp2`: `k = 20, 40, 80, 160`
- `mgp`: the same `k`, together with `accuracy = 0.4 / k`

## Parameter Grid

The experiment covers:

- `a in {0.5, 1, 2, -1}`
- `c in {0.5, 1.5}`
- both `model = "mgp"` and `model = "tiwp2"`

## Results

The convergence pattern is clear.

For `mgp`, the relative Frobenius covariance error decreases steadily under
joint `(k, accuracy)` refinement. Representative examples:

- `a = -1, c = 0.5`: `0.0326 -> 0.0165 -> 0.00831 -> 0.00415`
- `a = 2, c = 1.5`: `0.00898 -> 0.00457 -> 0.00232 -> 0.00116`
- `a = 0.5, c = 0.5`: `0.00177 -> 0.000991 -> 0.000520 -> 0.000263`

For `tiwp2`, the relative Frobenius covariance error decreases rapidly with
`k`. Representative examples:

- `a = -1, c = 0.5`: `0.00109 -> 0.000258 -> 0.0000630 -> 0.0000156`
- `a = 2, c = 1.5`: `0.00110 -> 0.000261 -> 0.0000634 -> 0.0000157`
- `a = 0.5, c = 0.5`: `0.000864 -> 0.000205 -> 0.0000501 -> 0.0000124`

At the largest refinement level tested:

- worst `mgp` relative Frobenius error: `0.004152961`
- worst `tiwp2` relative Frobenius error: `1.597585e-05`

These results support the claim that the FEM prior covariance approaches the
exact state-space prior covariance across the tested prior settings.

## Verification

1. Rendered notebook:
   - `Rscript --vanilla -e 'rmarkdown::render("analysis/prior_covariance_convergence.rmd", quiet = TRUE)'`
   - Passed, with only the same existing Pandoc "unclosed Div" warnings seen in
     other workflowr notebooks.
2. Confirmed output artifacts:
   - `analysis/prior_covariance_convergence.html`
   - `output/prior_covariance_convergence_metrics.csv`
