# Case-Crossover Simulation Helper Plan

## Summary

Add an analysis helper that simulates `dailymort_pulm_nonsenior` for the case-crossover model while reusing the original `Date`, `HCtemp`, `pm25Sample`, `no2Sample`, and `o3Sample` from `data/data_CD3518_sample_2.RData`.

The dataset does not store `strata` as a column, but it contains the required strata information through `Date`; the helper will generate:

```r
strata = format(Date, "%Y%b%A")
```

## Key Changes

- Create `analysis/simulate_casecrossover_data.R`.
- Add:
  ```r
  simulate_casecrossover_data <- function(
    f_temp, f_pm25, f_no2, f_o3,
    data = NULL,
    data_path = "data/data_CD3518_sample_2.RData",
    seed = NULL
  )
  ```
- If `data = NULL`, load `data_CD3518_sample_2` from `data_path`.
- Return the full original dataset with an added `strata` column and a newly simulated integer `dailymort_pulm_nonsenior`.
- Compute original per-stratum totals with:
  ```r
  sum(dailymort_pulm_nonsenior, na.rm = TRUE)
  ```
- Compute:
  ```r
  eta = f_temp(HCtemp) + f_pm25(pm25Sample) + f_no2(no2Sample) + f_o3(o3Sample)
  ```
- Within each stratum, redistribute the original total count using:
  ```r
  prob_i = exp(eta_i - max(eta_stratum)) / sum(exp(eta_stratum - max(eta_stratum)))
  ```
  and draw counts with `rmultinom()`.

## Validation

- Require columns: `Date`, `dailymort_pulm_nonsenior`, `HCtemp`, `pm25Sample`, `no2Sample`, `o3Sample`.
- Require each supplied effect function to return numeric values of length 1 or `nrow(data)`.
- Error if computed `eta` contains `NA`, `NaN`, or infinite values.
- Preserve all rows, including strata whose original total case count is zero.

## Test Plan

- Source the helper and run it with simple vectorized functions.
- Check output row count matches the input, and `strata` exists.
- Check simulated response is nonnegative integer with no `NA`.
- Check per-stratum simulated totals exactly equal original per-stratum totals.
- Check same `seed` gives identical simulated response.
- Optionally smoke-test compatibility with `BayesGP::model_fit(..., family = "cc", strata = "strata")` on the simulated positive-case subset.

## Project Notes

- Because this is a small analysis helper, do not export it from `BayesGP`.
- Add an implementation log at `log/2026-04-24_casecrossover_simulation_helper_log.md`.
- Save this plan at `plan/2026-04-24_casecrossover_simulation_helper_plan.md` before implementation.
