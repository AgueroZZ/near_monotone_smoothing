## Summary

Aligned near-monotone mGP defaults and notebook usage so `normalized_boundary`
defaults to `TRUE` consistently.

## Changes

- Changed `NearMonotoneGP::fit_mgp_known_sd()` to default
  `normalized_boundary = TRUE` to match the formula-facing near-monotone
  interface.
- Updated the BayesGP README example to use the normalized boundary basis.
- Updated active analysis notebooks that still explicitly set
  `normalized_boundary = FALSE` for mGP examples to use `TRUE`.

## Rationale

The normalized boundary basis makes the boundary coefficient interpretable as a
local slope-like term at the left boundary, which is the preferred default for
the near-monotone interface.
