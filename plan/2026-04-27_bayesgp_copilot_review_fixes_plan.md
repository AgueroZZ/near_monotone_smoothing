# BayesGP Copilot Review Fixes Plan

Date: 2026-04-27

## Goal

Address the actionable Copilot review comments on PR #6 after the near-monotone usability branch was pushed.

## Planned Changes

- Update vignette calls so derivative predictions use the exported `deriv` argument.
- Update the sGP vignette to use the exported `prior_conversion_sgp()` function name.
- Fix the malformed inline CoxPH family example in the partial-likelihood vignette.
- Remove tracked local artifact files from the package repository.
- Keep the current README branch install command unchanged.

## Validation

- `git diff --check`
- Vignette code extraction and parse check for the changed vignette files
- `Rscript -e 'devtools::test(".", reporter = "summary")'`
- `R CMD build --no-build-vignettes BayesGP`
- `R CMD check --no-manual --ignore-vignettes BayesGP_0.1.2.tar.gz`
