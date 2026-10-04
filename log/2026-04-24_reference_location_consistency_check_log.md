# Reference Location Consistency Check Log

Date: 2026-04-24

## Updates

- Added `analysis/reference_location_consistency_check.R`.
- The script checks `mgp` and `tiwp2` under both `initial_location = "left"`
  and `initial_location = "middle"`.
- The script compares FEM prior covariance against exact state-space covariance
  over `k = 20, 40, 80, 160`.
- The script also fits a deterministic Gaussian probe dataset and compares FEM
  posterior prediction summaries against the state-space reference.
- Metrics are written to:
  - `output/reference_location_prior_covariance_metrics.csv`
  - `output/reference_location_posterior_consistency_metrics.csv`
- Added missing Gaussian prior normalizing constants in the TMB template:
  - latent random-effect weights,
  - smooth boundary coefficients,
  - fixed-effect coefficients.
- Reintroduced `lognormconst` comparison in the validation script after fixing
  the latent-dimension-dependent normalization offset.
- Added a testthat regression check requiring state-space and FEM
  `lognormconst` values to agree for `mgp` and `tiwp2` under left and middle
  references on a small Gaussian probe dataset.
- Synchronized `BayesGP/src/BayesGP.cpp` and `BayesGP/inst/extsrc/BayesGP.cpp`
  so the packaged custom-template source has the same Gaussian likelihood and
  prior-normalization behavior as the compiled source.
- Updated `f()` so it no longer injects `"middle"` as a universal
  `initial_location` default. Model builders now receive an omitted
  `initial_location` when users do not specify one, allowing near-monotone
  terms to use their documented `"left"` default while legacy FEM IWP keeps its
  `"middle"` default.
- Updated model-argument helper descriptions for `initial_location`, `c`, and
  custom-template normalization behavior.
- Regenerated roxygen documentation for `f()`, `model_fit()`,
  `predict.FitResult()`, `supported_models()`, `model_arguments()`, and
  `custom_template()`.
- Reinstalled the package and smoke-tested installed helper behavior.
- Added `analysis/c_zero_shift_check.R` to verify that public near-monotone
  model paths reject `c = 0` at the reference location, and that small positive
  `c` values still give FEM prior covariance convergence to the state-space
  reference.
- Added a testthat regression check for the `c = 0` validation path.
- Added experimental `allow_zero_c = TRUE` support for `model = "mgp"` with
  left reference, `normalized_boundary = FALSE`, and `(a - 1) / a > 0`.
- Updated the mGP FEM precision integration grid so the `c = 0` opt-in path
  avoids evaluating the singular endpoint exactly.
- Kept `c = 0` disabled for `tiwp2` because the currently normalized Box-Cox
  transform degenerates at `c + ref_location = 0`.
- Changed the omitted-`c` default for `model = "mgp"` to `1e-6`, matching the
  numerically stable `c -> 0+` behavior. Kept the omitted-`c` default for
  `model = "tiwp2"` at `1` because its normalized Box-Cox transform does not
  have the same nondegenerate `c -> 0+` limit.

## Notes

- The check uses `a = 2`, which is covered by the current exact reverse
  state-space implementation for non-left `mgp` references.
- The shift `c` is chosen as `reference + 1.25`, so the transformed argument is
  equivalent to the original-scale `x + 1.25` in both left and middle-reference
  configurations.
