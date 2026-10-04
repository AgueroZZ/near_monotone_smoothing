# BayesGP Copilot Review Fixes Log

Date: 2026-04-27

## Summary

Started the follow-up pass for Copilot PR #6 comments after the `bayesgp-near-monotone-usability` branch was pushed.

## Changes

- Replaced vignette derivative calls from `degree = 1` / `degree = 2` to `deriv = 1` / `deriv = 2`.
- Replaced `BayesGP::prior_conversion_sGP()` with exported `BayesGP::prior_conversion_sgp()`.
- Fixed the CoxPH vignette text to show `family = "coxph"`.
- Removed tracked local artifacts:
  - `R/.Rhistory`
  - `build/.Rapp.history`
  - `inst/.DS_Store`
  - `vignettes/.Rapp.history`

## Validation

- Passed: `git diff --check`
- Passed: `git diff --cached --check`
- Passed: vignette code extraction and parse check for:
  - `vignettes/BayesGP-covid_example.Rmd`
  - `vignettes/BayesGP-sGP.Rmd`
  - `vignettes/BayesGP-Partial_Likelihood.Rmd`
- Passed: `Rscript -e 'devtools::test(".", reporter = "summary")'`
- Passed: `R CMD build --no-build-vignettes BayesGP`
- Passed: `R CMD check --no-manual --ignore-vignettes BayesGP_0.1.2.tar.gz`

Final source-tarball check status: `OK`.
