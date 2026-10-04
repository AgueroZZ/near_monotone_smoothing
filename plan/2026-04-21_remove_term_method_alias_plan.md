# Remove Term Method Alias Plan

Date: 2026-04-21

## Goal

Remove the term-level `method` alias from `f()` usage entirely, make
`computation` the only supported argument for selecting state-space versus FEM
representations, and update the package plus the retained analysis notebooks to
match that interface.

## Work Items

1. Remove package-side acceptance of term-level `method` and replace it with a
   direct error that points users to `computation`.
2. Update tests, roxygen docs, and the README so that all package-facing
   examples use `computation = ...`.
3. Update the retained `analysis/` notebooks and helper scripts so their
   smooth-term calls use `computation = ...` consistently.
4. Rebuild package documentation, run package verification, refresh selected
   lightweight rendered notebooks, and reinstall the package locally.
