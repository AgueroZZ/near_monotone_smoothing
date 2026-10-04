# Analysis Notebook Package Migration Plan

## Goal

Migrate the retained `analysis/` notebooks away from direct sourcing of
`code/06-model-helpers.R` and toward direct use of the in-repo
`NearMonotoneGP` package.

## Constraints

1. Several retained notebooks still depend on the old "known observation
   noise" fitting helpers.

2. The new `NearMonotoneGP::model_fit()` wrapper currently routes Gaussian fits
   through BayesGP's noise-estimation path, which would change the statistical
   setup of those notebooks if used as a drop-in replacement.

3. Because of that mismatch, the first migration step should preserve notebook
   behavior rather than force every notebook onto the new formula wrapper.

## Plan

1. Add a compatibility layer to `NearMonotoneGP/` that mirrors the canonical
   helper API previously sourced from `code/06-model-helpers.R`.

2. Bundle the required TMB source files inside the package and make
   `compile_tmb_model()` work from the package source tree without requiring
   an installed package.

3. Update retained notebooks to use:
   - `devtools::load_all("NearMonotoneGP", quiet = TRUE)`
   - package-exported helper functions
   instead of `source("code/06-model-helpers.R")`.

4. Keep BayesGP-native specialized usage explicit where needed:
   - for example `analysis/casecross.rmd` should call `BayesGP::model_fit()`
     directly to avoid ambiguity with the extension wrapper.

5. Verify by rendering representative notebooks covering:
   - PSD helper usage
   - exact known-noise fitting
   - simulation notebooks
   - case-crossover notebook
