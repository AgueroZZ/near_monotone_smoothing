# Term Computation and State-Space Stability Log

Date: 2026-04-21

## Summary

Cleaned up the smooth-term API and added earlier failure checks for exact
state-space smoothers in the local `BayesGP` fork.

Two practical changes were made:

1. `computation` is now the canonical term-level argument inside `f()`.
2. Exact state-space smoothers now fail early, with actionable error messages,
   when the support grid is nearly singular because it is too dense or contains
   near-duplicates.

## API Change

The package-facing interface now prefers:

- `f(..., computation = "state-space")`
- `f(..., computation = "fem")`

The old `method = ...` argument inside `f()` is still accepted as a
backward-compatible alias, so existing notebooks and scripts do not break
immediately. The motivation for preferring `computation` is to avoid ambiguity
with `model_fit(method = ...)`, where `method` controls the inference
algorithm (`aghq`, `MCMC`, `nlminb`, and so on).

Updated files include:

- `BayesGP/R/01_utility.R`
- `BayesGP/R/02_model_fit.R`
- `BayesGP/R/03_post_fit.R`
- `BayesGP/README.Rmd`

and the regenerated help pages.

## Exact State-Space Stability Guards

New support-grid diagnostics were added in:

- `BayesGP/R/07_near_monotone_helpers.R`

and used by:

- `BayesGP/R/08_near_monotone_instance_builders.R`
- `BayesGP/R/10_exact_iwp_state_space.R`

The exact builder now checks:

- non-finite support locations,
- nearly overlapping support points,
- and ill-conditioned precision matrices via `rcond`.

If the precision is too close to singular, the package now stops before
optimization and returns an error message that explicitly suggests:

- using a sparser `grid`,
- removing nearly duplicated locations,
- or switching to `computation = "fem"`.

This addresses the previous failure mode where users could instead see a later
and much less informative optimizer error such as:

- `Error in optim(): initial value in 'vmmin' is not finite`

## Regression Tests

Updated and expanded tests:

- `BayesGP/tests/testthat/test-formula-interface.R`
- `BayesGP/tests/testthat/test-exact-iwp-state-space.R`
- `BayesGP/tests/testthat/test-near-monotone-gaussian.R`
- `BayesGP/tests/testthat/test-near-monotone-casecrossover.R`

New behavior covered by tests:

- `computation` works as the canonical term-level argument,
- the legacy `method` alias still parses through `f()`,
- and both exact `iwp` and exact `mgp` now error early on nearly singular
  support grids.

## Verification

Verified successfully:

- `devtools::document("BayesGP")`
- `devtools::build_readme()` from the package root
- `testthat::test_local("BayesGP")` with `73` passing tests
- `R CMD INSTALL -l /tmp/Rlib BayesGP`
- reinstall to the user library at
  `/Users/ziangzhang/Library/R/arm64/4.5/library`
