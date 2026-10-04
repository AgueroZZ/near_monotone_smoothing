# Remove Term Method Alias Log

Date: 2026-04-21

## Summary

Removed the term-level `method` alias from the local `BayesGP` fork and made
`computation` the only supported argument for choosing between exact
state-space and FEM smooth-term representations.

This change was carried through the package code, tests, documentation, and
retained analysis notebooks.

## Package Changes

Updated package code:

- `BayesGP/R/07_near_monotone_helpers.R`
- `BayesGP/R/08_near_monotone_instance_builders.R`
- `BayesGP/R/02_model_fit.R`
- `BayesGP/R/01_utility.R`

What changed:

- `resolve_computation_method()` now errors immediately if a smooth term is
  passed with `method = ...`.
- The error message explicitly tells users to use `computation` inside `f()`
  and reserves `model_fit(method = ...)` for the inference algorithm.
- Package documentation no longer mentions a legacy alias.

## Tests and Docs

Updated tests:

- `BayesGP/tests/testthat/test-formula-interface.R`
- `BayesGP/tests/testthat/test-near-monotone-gaussian.R`

Existing tests for exact `iwp` and case-crossover remained aligned with the new
interface.

Updated docs:

- `BayesGP/README.Rmd`
- regenerated `BayesGP/README.md`
- regenerated man pages, especially `f.Rd` and `model_fit.Rd`

## Analysis Updates

Updated retained analysis sources to use `computation = ...`:

- `analysis/illustration.rmd`
- `analysis/casecross.rmd`
- `analysis/simulation1.rmd`
- `analysis/simulation2.rmd`
- `analysis/illustration_reproduction_check.R`
- `analysis/tiwp2_method_consistency_check.R`
- `analysis/iwp_prior_covariance_convergence.rmd`

Rendered HTML refreshed for lightweight notebooks:

- `analysis/illustration.html`
- `analysis/iwp_prior_covariance_convergence.html`

`simulation1.rmd` and `simulation2.rmd` were updated at the source level but
not re-rendered in this pass, because they are substantially heavier runs.

## Verification

Verified successfully:

- `devtools::document("BayesGP")`
- `devtools::build_readme()` from the package root
- `testthat::test_local("BayesGP")` with `72` passing tests
- `R CMD INSTALL -l /tmp/Rlib BayesGP`
- reinstall to the user library at
  `/Users/ziangzhang/Library/R/arm64/4.5/library`

## Final Interface Rule

After this change:

- use `f(..., computation = "state-space")`
- use `f(..., computation = "fem")`

and do not use `method = ...` inside `f()`.
