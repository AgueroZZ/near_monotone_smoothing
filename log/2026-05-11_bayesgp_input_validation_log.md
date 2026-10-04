# BayesGP Input Validation Log

Date: 2026-05-11
Package repo: `/Users/ziangzhang/Desktop/mspline/near_monotone_smoothing/BayesGP`
Package commit: `d730a8a66f9397720eb52efd376f51d9d42f8e97`

## Update

- Added early `model_fit()` input validation for columns referenced by the
  response, smooth terms, fixed effects, offsets, and family-specific arguments
  such as `size`, `cens`, `weight`, and `strata`.
- Numeric columns now fail before fitting when they contain `NA`, `NaN`, or
  non-finite values. Non-numeric columns fail when they contain `NA`.
- Error messages report the offending data column so users can clean the input
  directly instead of seeing an opaque downstream optimizer error.
- Documented the user-facing behavior in `NEWS.md`; kept `DESCRIPTION`
  concise.

## Validation

- `pkgload::load_all(".", export_all = TRUE); testthat::test_file("tests/testthat/test-formula-interface.R", reporter = "summary")`
- `devtools::test(".", reporter = "summary")`
- `git diff --check`
