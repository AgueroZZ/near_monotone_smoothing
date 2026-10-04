# 2026-04-25 tIWP2 Model Dispatch Fix

## Context

The PM2.5-only case-crossover demo used `model = "iwp2"` with near-monotone
arguments (`a`, `c`, `normalized_boundary`, and `initial_location`). The formula
interface supports native IWP2 as `model = "iwp", order = 2` and transformed
IWP2 as `model = "tiwp2"`. Because unknown smooth-term model names were not
validated before dispatch, `model = "iwp2"` was silently skipped and later
failed with the misleading message that the model had no hyper-parameters.

## Changes

- Updated `analysis/casecross_simulation_demo.rmd` to use `model = "tiwp2"` for
  the PM2.5-only transformed-IWP2 fit.
- Added internal smooth-term model validation before random-effect dispatch in
  `model_fit()`.
- Added a specific error for `model = "iwp2"` that points users to either
  `model = "tiwp2"` or `model = "iwp", order = 2`.
- Added regression tests for the clearer `iwp2` error and for tIWP2 FEM terms
  under the grouped multinomial case-crossover likelihood.

## Verification

- `Rscript --vanilla -e 'devtools::test("BayesGP", filter = "formula-interface|near-monotone-casecrossover")'`
- `Rscript --vanilla -e 'devtools::test("BayesGP")'`
- Ran the PM2.5-only demo fit on `data/data_CD3518_sample_2.RData` with
  `model = "tiwp2"` and confirmed `predict()` returns a summary data frame.
