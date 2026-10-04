# 2026-04-25 Legacy IWP FitResult Print Fix

## Context

A fitted case-crossover model using legacy `model = "iwp", order = 2` completed
successfully, but printing the `FitResult` failed with:

```text
Error in data.frame(): arguments imply differing number of rows: 1, 0
```

The failure happened while building the compact smooth-term specification table
inside `print.FitResult()`. Legacy IWP objects fitted without an explicit `k`
had an empty `k` slot (`numeric(0)`), which could not be combined with the
length-one diagnostic columns.

## Changes

- Store the realized knot count in the legacy IWP `k` slot when constructing the
  S4 instance.
- Make `fit_result_smooth_terms()` robust to empty scalar slots so existing
  fitted objects can still print.
- Added a case-crossover regression test that fits legacy IWP with default knots
  and verifies `print(fit)` succeeds.

## Verification

- `Rscript --vanilla -e 'devtools::test("BayesGP", filter = "near-monotone-casecrossover")'`
- `Rscript --vanilla -e 'devtools::test("BayesGP")'`
- Reproduced the PM2.5-only case-crossover fit with `model = "iwp", order = 2`
  on `data/data_CD3518_sample_2.RData` and confirmed `print(fit_pm25_only)`
  succeeds.
