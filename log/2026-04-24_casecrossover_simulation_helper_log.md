# Case-Crossover Simulation Helper Log

## Summary

Implemented `analysis/simulate_casecrossover_data.R`, an analysis helper for simulating `dailymort_pulm_nonsenior` from a case-crossover multinomial redistribution model.

## Changes

- Added `simulate_casecrossover_data()`.
- The helper loads `data/data_CD3518_sample_2.RData` by default, unless a data frame is supplied through `data`.
- The helper derives `strata` from `Date` with `format(Date, "%Y%b%A")`.
- The helper computes the linear predictor as:
  ```r
  eta = f_temp(HCtemp) + f_pm25(pm25Sample) + f_no2(no2Sample) + f_o3(o3Sample)
  ```
- The helper preserves the original per-stratum total case counts using `sum(..., na.rm = TRUE)`.
- Within each stratum, the helper draws simulated counts from `rmultinom()` using stabilized softmax probabilities.
- The returned dataset preserves all original rows and replaces `dailymort_pulm_nonsenior` with non-missing integer counts.

## Validation

- Verified that the helper output keeps the original row count.
- Verified that `strata` is present in the returned data.
- Verified that the simulated response has no missing values, is integer-valued, and is nonnegative.
- Verified that simulated per-stratum totals exactly match the original per-stratum totals.
- Verified that repeated calls with the same seed return identical simulated responses.
- Ran a small `BayesGP::model_fit(..., family = "cc", strata = "strata")` smoke test on a positive-case subset; the fit completed successfully.

## Notes

- This helper is intentionally kept in `analysis/` and is not exported from the `BayesGP` package.
- The implementation preserves and restores the caller's global RNG state when `seed` is supplied.

## 2026-04-24 Flexible Effects Revision

- Updated `simulate_casecrossover_data()` so `f_temp`, `f_pm25`, `f_no2`, and `f_o3` default to `NULL`.
- A `NULL` effect now contributes zero to the true linear predictor.
- This preserves the original four-function usage while allowing one-function simulations such as `simulate_casecrossover_data(f_pm25 = f_pm25_true, ...)`.
- Verified both the original positional four-function call and a PM2.5-only call preserve per-stratum totals and remain reproducible under a fixed seed.

## 2026-04-24 Explicit Stratum Totals Revision

- Added `stratum_total_cases` to `simulate_casecrossover_data()`.
- `stratum_total_cases = NULL` preserves the input response totals by stratum.
- A scalar `stratum_total_cases` value is recycled to all strata.
- A named numeric vector is matched by stratum name, which supports passing original observed counts or custom per-stratum counts.
- Added validation that supplied totals are finite, nonnegative whole numbers and that named vectors cover all strata.
- Verified default totals, scalar totals, named-vector totals, and fixed-seed reproducibility.
