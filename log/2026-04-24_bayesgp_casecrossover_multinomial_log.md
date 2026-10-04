# BayesGP Case-Crossover Multinomial Likelihood Log

## Summary

Updated `BayesGP` case-crossover likelihood construction so `family = "cc"`
treats each stratum as one grouped multinomial observation.

## Changes

- Replaced the previous case-day/control-day representation in
  `BayesGP/R/02_model_fit.R` with per-stratum row membership and total-count
  data passed to TMB.
- Updated `BayesGP/src/BayesGP.cpp` and `BayesGP/inst/extsrc/BayesGP.cpp` so the
  case-crossover log likelihood is:
  ```text
  sum_s { sum_{i in s} y_i eta_i - N_s log(sum_{i in s} exp(eta_i)) }
  ```
  up to the multinomial coefficient, which is constant in the fitted parameters.
- Added validation that case-crossover counts are finite, nonnegative whole
  numbers.
- Added tests for positive multinomial counts within a stratum.

## Notes

- This corrects the interpretation that a row with a positive count is a case
  row and a row with a zero count is a control row.
- Under the grouped multinomial likelihood, multiple rows in the same stratum
  may have positive simulated or observed counts.

## Validation

- Reinstalled `BayesGP` from source to `/tmp/bayesgp_lib` after changing the C++
  template.
- Ran `BayesGP/tests/testthat/test-near-monotone-casecrossover.R`; all 7
  assertions passed.
- Ran `devtools::test("BayesGP")`; all 150 assertions passed.
- Re-rendered `analysis/casecross_simulation_demo.rmd` successfully with the
  grouped multinomial likelihood.
