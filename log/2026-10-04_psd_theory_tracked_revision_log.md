# PSD Theory Tracked Revision Log

## Context

The user requested a review version of the existing PSD theory page, with
removed original material struck through and rewritten/added material
highlighted. No publication was requested.

The pre-edit source SHA-256 is
`a2178930f38a679d78c5b93aba6cb34e11fa6bc7a47e97d30094e091728a1ce4`.

## Changes

- Preserve original material in 13 deletion blocks; highlight the replacement
  blocks, four additions, and the revision legend (18 highlighted blocks).
  Revision display styles are scoped to this page.
- Restore the `sigma^2` factor in the Green-function variance formula.
- Make the curvature denominator and operator naming explicit and consistent.
- State fixed horizon, fixed parameters/transformation normalization, and
  a right-unbounded domain on which `x + c > 0`.
- Clarify that innovation PSD conditions on the exact current state; at the
  initial boundary the derivative also needs to be conditioned on or fixed.
- Keep the M-GP limit for all finite `a != 0`, adding the negative-curvature
  case and an integrable squared dominator to the appendix proof.
- Correct the mean-value intermediate-point interval and remove the erroneous
  identification of the step size with `g'`.
- State finite `a > 0` for the t-IWP2 zero limit, add its exact transformed-time
  PSD, and prove the limit without assuming `g'(0) = 1` or a domain starting at 0.
- Replace the claims of no function uncertainty/no deviation from the base
  model with a statement about local conditional innovations at fixed horizon.
- Add a normalized square-root example with fixed initial state, where local
  PSD tends to zero while accumulated variance tends to infinity.
- Correct the Green-function reference to Equation 8.38 in the author's
  textbook PDF (printed page 273, PDF page 280). Equation 8.36 describes the
  differential equation; Equation 8.38 gives the Green function.

## Validation

- Rejecting all 17 content revisions, and removing the review display/legend,
  exactly recovers the pre-edit source, including original whitespace.
- Numerical quadrature of independently derived Green functions agrees with
  squared package PSDs in 192 combinations of model, positive/negative
  curvature, starting location, horizon, and process SD. Maximum relative
  difference: approximately `1.406e-13`.
- Spot-checked the M-GP limit for eight positive/negative curvature values,
  the t-IWP2 zero limit for four positive values, and the square-root example's
  decreasing local versus increasing accumulated variance.
- `workflowr::wflow_build("analysis/PSD.rmd", view = FALSE)`: passed.
- Inspected the rendered HTML: all 13 deleted and 18 highlighted blocks are
  separately bounded, every changed display equation remains a math element,
  and no unparsed revision fences remain.
- `git diff --check`: passed after trimming generated HTML locale whitespace.

## Scope

Only the PSD theory source, its local rendered HTML, and its plan/log were
changed in this step. Earlier simulation/software fixes are retained.
No BayesGP implementation changes were made in this revision step.
The user subsequently requested commits and pushes without an additional
webpage rebuild; the tracked revision remains in the committed source and
the previously generated HTML.
