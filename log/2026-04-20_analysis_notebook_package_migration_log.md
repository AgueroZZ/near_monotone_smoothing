# Update Log: Analysis Notebook Package Migration

## Summary

Migrated the retained workflowr notebooks away from direct `source()` usage of
`code/06-model-helpers.R` and onto the in-repo `NearMonotoneGP` package loaded
from source with `devtools::load_all("NearMonotoneGP", quiet = TRUE)`.

## Package Changes

- Added compatibility helpers to `NearMonotoneGP` for the old notebook-facing
  API:
  - `compile_tmb_model()`
  - `fit_iwp_known_sd()`
  - `fit_tiwp_known_sd()`
  - `fit_mgp_known_sd()`
  - `fit_mgp_fem_known_sd()`
  - `sample_exact_known_sd_fit()`
  - `sample_mgp_fem_known_sd_fit()`
  - `summarize_function_samples()`
  - interval-evaluation helpers
- Added `NearMonotoneGP/R/sampling_math.R` so sampling utilities such as
  `mGP_sim()` and `sim_IWp_Var()` are available through the package.
- Bundled TMB sources into:
  - `NearMonotoneGP/inst/tmb/fitGP_known_sd.cpp`
  - `NearMonotoneGP/inst/tmb/fitGP_cc.cpp`
- Updated `compile_tmb_model()` to locate bundled TMB sources and compile them
  into a writable temporary build directory.
- Updated package metadata to import the required compatibility dependencies:
  `TMB`, `numDeriv`, and `LaplacesDemon`.

## Notebook Changes

Updated the following notebooks to load the package from source instead of
directly sourcing `code/06-model-helpers.R`:

- `analysis/PSD.rmd`
- `analysis/illustration.rmd`
- `analysis/mGP_vs_tIWP2.rmd`
- `analysis/simulation1.rmd`
- `analysis/simulation2.rmd`
- `analysis/casecross.rmd`

Additional notebook-specific adjustments:

- `analysis/casecross.rmd` now calls `BayesGP::model_fit()` explicitly to avoid
  ambiguity with `NearMonotoneGP::model_fit()`.
- `analysis/illustration.rmd` text was updated to refer to the package-based
  notebook entrypoint rather than `code/06-model-helpers.R`.

## Documentation Changes

- Updated `README.md` to note that the retained notebooks now load
  `NearMonotoneGP`.
- Updated `code/README.md` to describe `code/06-model-helpers.R` as a mirrored
  legacy helper layer rather than the direct notebook entrypoint.
- Updated `NearMonotoneGP/README.md` to document the compatibility helper set.

## Verification

- `Rscript --vanilla -e 'devtools::load_all("NearMonotoneGP", quiet = TRUE); source("NearMonotoneGP/inst/examples/smoke_test.R")'`
  - passed
- `Rscript --vanilla -e 'devtools::load_all("NearMonotoneGP", quiet = TRUE); set.seed(1); x <- seq(0.1, 1.1, length.out = 11); f_true <- sqrt(x + 1); y <- f_true + rnorm(length(x), sd = 0.1); data_sim <- data.frame(x = x, y = y); data_train <- data_sim[1:7, , drop = FALSE]; fit <- fit_mgp_known_sd(data_sim = data_sim, data_train = data_train, u = 1, a = 2, c = 1, sig_noise = 0.1, subset_mode = "prefix"); draws <- sample_exact_known_sd_fit(fit, M = 20); cat(dim(draws), "\\n")'`
  - passed
- `R CMD INSTALL -l /tmp/Rlib NearMonotoneGP`
  - passed
- `rmarkdown::render("analysis/PSD.rmd")`
  - passed
- `rmarkdown::render("analysis/illustration.rmd")`
  - passed
- `rmarkdown::render("analysis/simulation1.rmd")`
  - passed
- `rmarkdown::render("analysis/simulation2.rmd")`
  - passed
- `rmarkdown::render("analysis/mGP_vs_tIWP2.rmd")`
  - passed
- `rmarkdown::render("analysis/casecross.rmd")`
  - passed
