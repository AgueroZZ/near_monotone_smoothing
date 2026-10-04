# BayesGP near-monotone class and PSD density plan

## Goal

Make near-monotone smooth terms expose their statistical model identity and fix
PSD density calculations for transformed-scale models.

## Implementation plan

- Add first-class S4 classes for `mgp` and `tiwp2` with the shared matrix fields
  required by the TMB fitting path.
- Construct near-monotone instances as `mgp` or `tiwp2`, not as native `iwp`.
- Replace internal class checks with semantic helpers so native IWP behavior,
  boundary-design handling, and near-monotone dispatch remain separate.
- Extend `var_density()` and `var_plot()` with an original-scale `x` argument.
- Dispatch near-monotone PSD corrections through `PSD_compute()` using
  `near_mono_meta`, defaulting `x` to the fitted PSD prior location.
- Add regression tests for class identity, plotting, and PSD density scaling.
- Bump the package version to `0.1.3`, update `NEWS.md`, regenerate
  documentation, and validate with targeted tests plus package checks.

## Validation targets

- `testthat::test_file("tests/testthat/test-near-monotone-gaussian.R")`
- `testthat::test_file("tests/testthat/test-fitresult-usability.R")`
- `devtools::test(".", reporter = "summary")`
- `R CMD build --no-build-vignettes BayesGP`
- `R CMD check --no-manual --ignore-vignettes BayesGP_0.1.3.tar.gz`
