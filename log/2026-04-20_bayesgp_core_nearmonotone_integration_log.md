# Update Log: BayesGP Core Near-Monotone Integration

## Summary

Started a new integration track that moves near-monotone model support from the
extension-wrapper layer into a local `BayesGP` fork.

## Initial Actions

- Cloned `BayesGP` into the workspace at `BayesGP/`.
- Switched the local fork to the upstream `development` branch.
- Inspected the current `BayesGP` architecture:
  - `R/02_model_fit.R` contains the full formula parsing, random-effect
    instance construction, and TMB data assembly pipeline.
  - `R/03_post_fit.R` contains posterior summaries and `predict.FitResult()`.
  - `src/BayesGP.cpp` currently treats Gaussian observation SD as a dedicated
    family hyperparameter and does not yet support a fixed known-SD mode.
- Confirmed that the retained notebooks still require:
  - native `mgp` / `tiwp2` formula support
  - posterior function draws through the fitted object
  - a known-SD Gaussian path for the exact/FEM comparisons

## Decision

Proceed with core integration inside `BayesGP` rather than expanding the
compatibility API further. The notebook migration target is a unified workflow
based on:

- `model_fit(...)`
- `f(..., model = "mgp" | "tiwp2", method = "state-space" | "fem")`
- `predict(..., only.samples = TRUE)`

with Gaussian known-SD handled in `control.family`.

## Implementation

- Added a local `BayesGP` development fork on the upstream `development`
  branch.
- Moved the near-monotone math layer into the fork:
  - `BayesGP/R/04_near_monotone_state_space.R`
  - `BayesGP/R/05_near_monotone_fem.R`
  - `BayesGP/R/06_near_monotone_sampling.R`
  - `BayesGP/R/07_near_monotone_helpers.R`
  - `BayesGP/R/08_near_monotone_instance_builders.R`
  - `BayesGP/R/09_near_monotone_post.R`
- Extended `BayesGP::f()` to accept the near-monotone computation argument
  explicitly through `method` / `computation`.
- Updated `BayesGP::model_fit()` so formula terms with
  `model = "mgp"` or `model = "tiwp2"` are built natively into the same
  fitting pipeline as the existing BayesGP random effects.
- Added Gaussian known-SD support in the core likelihood:
  - `control.family = list(sd = value)` fixes the observation SD
  - the family variance hyperparameter is omitted when the SD is fixed
  - `BayesGP/src/BayesGP.cpp` now reads `gaussian_sd_known` and
    `gaussian_sd_value`
- Added posterior evaluation support for near-monotone terms via:
  - `predict.FitResult()`
  - `smooth_samples()`
  - `smooth_summary()`
- Exported near-monotone simulation/PSD helpers through `BayesGP`, including:
  - `PSD_compute()`
  - `PSD_tIWP2_compute()`
  - `prior_conversion_mgp()`
  - `mGP_sim()`
  - `sim_IWp_Var()`
  - `simulate_tiwp_boxcox()`
  - FEM helpers and interval-evaluation helpers

## Notebook Migration

- Updated `analysis/illustration.rmd` to use native BayesGP formulas for:
  - exact `iwp`
  - exact `tiwp2`
  - exact `mgp`
  - FEM `mgp`
- Updated `analysis/simulation1.rmd` and `analysis/simulation2.rmd` to:
  - load `BayesGP` directly
  - fit `mgp` and `tiwp2` through `model_fit(...)`
  - obtain posterior function draws through `predict(..., only.samples = TRUE)`
  - load `BayesGP` in parallel workers instead of `NearMonotoneGP`
- Updated `analysis/casecross.rmd` to replace the customized FEM random effect
  with the native `mgp` FEM term using `normalized_boundary = FALSE`.
- Updated `analysis/PSD.rmd` and `analysis/mGP_vs_tIWP2.rmd` to load
  `BayesGP` directly for near-monotone utilities.

## Verification

- `Rscript --vanilla -e 'devtools::load_all("BayesGP", quiet = TRUE)'`
  - passed
- `Rscript --vanilla -e 'devtools::load_all("BayesGP", quiet = TRUE); ...'`
  - passed for `mgp` exact/FEM and `tiwp2` exact/FEM smoke fits with
    `control.family = list(sd = 0.1)`
- `R CMD INSTALL -l /tmp/Rlib BayesGP`
  - passed
- `rmarkdown::render("analysis/illustration.rmd")`
  - passed
- `rmarkdown::render("analysis/casecross.rmd")`
  - passed
- `rmarkdown::render("analysis/PSD.rmd")`
  - passed
- `rmarkdown::render("analysis/mGP_vs_tIWP2.rmd")`
  - passed
- `rmarkdown::render("analysis/simulation1.rmd")`
  - passed
- `rmarkdown::render("analysis/simulation2.rmd")`
  - passed
