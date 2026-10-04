# Term Computation and State-Space Stability Plan

Date: 2026-04-21

## Goal

Clean up the smooth-term API so that term-level computation choices are
expressed through a single argument, and add earlier, more informative failure
checks for exact state-space smoothers when the support grid becomes too dense
or nearly singular.

## Work Items

1. Make `computation` the canonical term-level argument inside `f()`, while
   preserving `method` as a backward-compatible alias for existing notebooks
   and scripts.
2. Update tests and package-facing documentation to prefer
   `computation = "state-space"` / `computation = "fem"` for smooth terms.
3. Add exact state-space grid diagnostics that:
   - detect nearly overlapping support locations,
   - detect ill-conditioned precision matrices early,
   - return actionable error messages suggesting a sparser grid or switching to
     FEM.
4. Add regression tests that check the new exact-state-space error handling is
   triggered before optimization begins.
