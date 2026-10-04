# Case-Crossover Simulation Demo Log

## Summary

Added `analysis/casecross_simulation_demo.rmd`, a compact R Markdown example that uses `simulate_casecrossover_data()` to generate a toy case-crossover dataset and fit four smooth effects with `BayesGP`.

## Changes

- The demo defines simple true functions for `HCtemp`, `pm25Sample`, `no2Sample`, and `o3Sample`.
- The demo simulates the full CD3518 sample response while preserving per-stratum case totals.
- The demo keeps a small positive-case stratum subset for a fast toy `family = "cc"` fit.
- The demo fits four `model = "mgp"` FEM smooth terms with `BayesGP::model_fit()`.
- The demo extracts posterior draws and summaries for each function with `predict(fit, variable = ..., only.samples = ...)`.
- The demo centers posterior draws at the left endpoint of each plotting grid before comparing with centered true functions.

## Notes

- The example is designed to show the workflow and is not intended as a recovery-quality simulation study.
- Rendered `analysis/casecross_simulation_demo.rmd` successfully with `rmarkdown::render()`.
- The render produced `analysis/casecross_simulation_demo.html` and `analysis/figure/casecross_simulation_demo.rmd/posterior-plots-1.png`.

## 2026-04-24 Revision

- Increased the true effect contrasts:
  - `f_temp` contrast is about 4.69.
  - `f_pm25` contrast is about 2.71.
  - `f_no2` contrast is about 2.17.
  - `f_o3` contrast is about 6.49.
- Added an intercept-like toy baseline by setting the input response to one case per stratum before simulation.
- Verified that the simulated full dataset has 1,491 strata, 1,491 total cases, and exactly one simulated case in every stratum.
- Expanded the fit subset from 6 strata and 6 cases to 80 evenly spaced strata and 80 cases.
- Added a note explaining that a standard intercept is not identifiable in the conditional case-crossover likelihood because it cancels inside each stratum-specific softmax.
- Re-rendered `analysis/casecross_simulation_demo.rmd` successfully after the revision.

## 2026-04-24 Full-Strata Revision

- Updated the demo fit to use all simulated strata instead of an 80-stratum subset.
- The fitted dataset now has 5,970 rows, 1,491 strata, and 1,491 simulated cases.
- Re-rendered `analysis/casecross_simulation_demo.rmd` successfully after switching to all strata.

## 2026-04-24 PM2.5-Only Diagnostic

- Added a PM2.5-only simulation that calls `simulate_casecrossover_data(f_pm25 = f_pm25_true, ...)` and leaves the other effects as `NULL`.
- Added a matching one-term `BayesGP::model_fit()` case-crossover model with only the PM2.5 smooth term.
- Added a PM2.5-only posterior plot at `analysis/figure/casecross_simulation_demo.rmd/pm25-only-posterior-1.png`.
- Re-rendered `analysis/casecross_simulation_demo.rmd` successfully after adding the diagnostic section.

## 2026-04-24 Explicit Stratum Totals Demo

- Replaced the manual first-row-per-stratum response editing with `stratum_total_cases`.
- Added a scalar-count example using `stratum_total_cases = 1L`.
- Added a named original-count example using `stratum_total_cases = original_stratum_counts`.
- The main full-strata fit now uses named counts equal to `rows_per_stratum - 1`, giving 4,479 simulated cases while preserving at least one control row in every stratum.
- Re-rendered `analysis/casecross_simulation_demo.rmd` successfully after the change.

## 2026-04-24 Grouped Multinomial Correction

- Corrected the demo after clarifying that each stratum is a grouped multinomial observation, not a one-case case/control construction.
- The main simulation now uses `stratum_total_cases = 5L` for every stratum and allows counts to be distributed across multiple rows in the same stratum.
- The scalar-count example now uses `stratum_total_cases = 3L`.
- Removed the outdated explanation about retaining a control row per stratum.
- Re-rendered `analysis/casecross_simulation_demo.rmd` successfully after the correction; the full and PM2.5-only fits both use 5,970 rows, 1,491 strata, and 7,455 total simulated cases.
