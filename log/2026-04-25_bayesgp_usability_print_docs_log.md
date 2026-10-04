# Update Log: BayesGP Fit Output and Model-Specific Documentation

## Summary

Implemented a usability pass for the local `BayesGP/` package focused on fitted-object display and model-specific formula documentation.

## Changes

- Replaced the fixed `FitResult` smooth-term table with model-aware rows that drop irrelevant all-`NA` columns.
- Updated near-monotone user-facing output to show the curvature-control parameter as `a`, not `curvature`.
- Kept technical near-monotone flags out of default smooth-term output. `normalized_boundary`, FEM `boundary`, and `allow_zero_c` remain internal metadata but are not shown by `print()` / `summary()`.
- Added model-specific summary fields:
  - `iid`: level count.
  - native `iwp`: computation, order, basis size, domain, and reference.
  - exact state-space `iwp`: computation, order, basis size, support size, domain, and reference.
  - `sgp`: basis size, domain, reference, angular frequency, frequency, period, harmonics, and boundary flag.
  - `mgp` / `tiwp2`: computation, basis/support size, domain, reference, `a`, `c`, and near-monotone flags.
- Stored the native IWP FEM `region` on the fitted instance so summaries can report the domain.
- Removed the exported `model_arguments()` API and deleted its generated `.Rd` page.
- Expanded `?f` into the main model-specific parameter reference and added aliases:
  - `?f_iid`
  - `?f_iwp`
  - `?f_sgp`
  - `?f_mgp`
  - `?f_tiwp2`
- Removed `allow_zero_c` from the main `?f` parameter reference. The opt-in path still exists for legacy c-zero diagnostics, but it is not promoted as part of the normal user-facing interface.
- Fixed two stale documentation examples:
  - `compute_post_fun_iwp()` now uses the correct global coefficient dimension.
  - `local_poly_helper()` and `global_poly_helper()` examples now call the exported helper functions.
- Fixed `DESCRIPTION` package metadata enough for local `R CMD check` to pass the required Author/Maintainer gate and avoid malformed Title/Description notes.

## Verification

- `Rscript --vanilla -e 'devtools::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-fitresult-usability.R", reporter = "summary")'`
- `Rscript --vanilla -e 'devtools::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-formula-interface.R", reporter = "summary"); testthat::test_file("tests/testthat/test-exact-iwp-state-space.R", reporter = "summary"); testthat::test_file("tests/testthat/test-near-monotone-gaussian.R", reporter = "summary"); testthat::test_file("tests/testthat/test-fitresult-usability.R", reporter = "summary")'`
- `Rscript --vanilla -e 'devtools::test(".", reporter = "summary")'`
- `Rscript --vanilla -e 'devtools::test("BayesGP", reporter = "summary")'`
- `R CMD check --no-manual --ignore-vignettes --no-tests .`

## Remaining Check Hygiene

`R CMD check --no-manual --ignore-vignettes --no-tests .` completed with no errors after the stale examples were fixed. It still reports 7 warnings and 2 notes from existing package hygiene issues unrelated to this usability pass:

- compiled objects are present in `src/`.
- hidden/local files are present in the package tree.
- several imports are missing or unused in `DESCRIPTION` / `NAMESPACE`.
- `plot.FitResult()` and `summary.FitResult()` do not exactly match their S3 generic signatures.
- duplicate aliases exist for `smooth_samples` and `smooth_summary`.
- some exported objects and S4 methods remain undocumented.
- several existing Rd files have undocumented or mismatched arguments.
- existing vignettes are still stale and fail if vignettes are not ignored.
