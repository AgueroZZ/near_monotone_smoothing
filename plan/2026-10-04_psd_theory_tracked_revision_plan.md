# PSD Theory Tracked Revision Plan

## Goal

Correct the PSD theory page while preserving removed original content with
strikethrough and highlighting every rewritten or added passage for review.

## Implementation plan

- Restore the process-variance factor in the Green-function PSD formula.
- State the fixed-horizon, fixed-parameter, and transformation-domain conditions.
- Retain the M-GP limit for every finite nonzero curvature and prove both signs.
- Restrict the t-IWP2 zero limit to positive curvature and distinguish local
  conditional innovations from accumulated function uncertainty.
- Add the exact transformed-IWP PSD formula and a square-root counterexample.
- Record related notation and reference corrections as tracked edits.
- Render the existing PSD page locally, using page-scoped revision styles.

## Validation targets

- Reject all tracked revisions and recover the exact pre-edit source.
- Check numerical Green-function integrals against the package PSD helpers
  and spot-check both limits and the accumulated-uncertainty counterexample.
- Check every tracked block and its mathematics in the rendered HTML.
- Run `git diff --check`; retain all earlier simulation/software changes.
