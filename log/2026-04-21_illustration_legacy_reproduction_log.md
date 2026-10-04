# Illustration Legacy Reproduction Log

Date: 2026-04-21

## Summary

Checked the published legacy illustration page at
`https://aguerozz.github.io/summary_M_GP/illustration.html` against the current
in-repo `BayesGP` workflow.

Two concrete mismatches were found before the fix:

1. The retained `analysis/illustration.rmd` notebook was fitting the `iwp`
   baseline through the native BayesGP spline basis pathway, while the legacy
   page used the exact augmented state-space formulation.
2. The notebook had drifted from the published FEM setting by using `k = 60`
   instead of the legacy `k = 30`.

Both issues were addressed.

## Package Changes

1. Added exact `iwp` state-space support for `f(..., model = "iwp", method =
   "state-space", order = 2)` in:
   - `BayesGP/R/10_exact_iwp_state_space.R`
   - `BayesGP/R/02_model_fit.R`
   - `BayesGP/R/03_post_fit.R`
   - `BayesGP/R/07_near_monotone_helpers.R`
2. Added tests for the new exact `iwp` pathway in:
   - `BayesGP/tests/testthat/test-exact-iwp-state-space.R`
3. Updated docs to mention the new exact `iwp` option:
   - `BayesGP/R/01_utility.R`
   - `BayesGP/R/02_model_fit.R`
   - `BayesGP/R/03_post_fit.R`
   - `BayesGP/man/f.Rd`
   - `BayesGP/man/model_fit.Rd`
   - `BayesGP/man/predict.FitResult.Rd`

## Notebook and Analysis Changes

1. Updated `analysis/illustration.rmd` so the compact interface now matches the
   published experiment more closely:
   - `iwp` now uses `method = "state-space"` with `grid = data_sim$x`
   - `mGP FEM` now uses `k = 30`
2. Added `analysis/illustration_reproduction_check.R` to compare legacy helper
   fits against the compact `BayesGP` interface under the same simulation
   settings.

## Legacy-vs-Compact Comparison

The comparison script was run after the package update. Posterior summaries from
the compact interface were numerically close to the legacy workflow:

| model | max abs posterior mean diff | legacy RMSE | compact RMSE | legacy avg width | compact avg width |
| --- | ---: | ---: | ---: | ---: | ---: |
| `iwp_state_space` | 0.105809 | 0.571610 | 0.569870 | 6.159494 | 6.144506 |
| `tiwp2_state_space` | 0.060826 | 0.312093 | 0.312365 | 4.536511 | 4.490118 |
| `mgp_state_space` | 0.055621 | 0.321566 | 0.327042 | 4.912832 | 4.900474 |
| `mgp_fem_k30` | 0.055362 | 0.333613 | 0.335775 | 4.807709 | 5.001412 |

Interpretation:

- No evidence of a legacy bug was found in the published illustration setup.
- The compact package interface now reproduces the same experiment design.
- Remaining numerical gaps are small relative to the response scale and are
  consistent with posterior-sampling variability plus the changed internal
  parameterization used by the unified package pathway.

## Verification

1. `Rscript --vanilla -e 'testthat::test_local("BayesGP")'`
   - Passed: `65` tests, `0` failures.
2. `Rscript --vanilla -e 'rmarkdown::render("analysis/illustration.rmd", quiet = TRUE)'`
   - Passed.
   - Existing Pandoc "unclosed Div" warnings remain, but no new functional
     errors were introduced.
3. `Rscript --vanilla analysis/illustration_reproduction_check.R`
   - Passed and printed the comparison table above.
4. `R CMD INSTALL -l /tmp/Rlib BayesGP`
   - Passed.
