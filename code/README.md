# Code

Shared R and TMB code used by the retained workflowr analyses lives here.

The retained notebooks now load the in-repo `BayesGP` fork rather than
sourcing `code/06-model-helpers.R` directly. The files in `code/` remain the
canonical math and reference layer that was used to build the integrated
near-monotone support in `BayesGP/`.

Canonical files:

- `01-state-space.R`: exact mGP state-space and covariance utilities
- `02-FEM.R`: mGP finite-element approximation utilities
- `03-sampling.R`: exact and FEM sampling helpers
- `04-state-space-adjoint.R` / `05-sampling-adjoint.R`: reverse-process utilities used by the retained mGP vs t-IWP comparison page
- `06-model-helpers.R`: legacy notebook helper layer superseded by the unified `BayesGP` formula interface
- `07-regression-checks.R`: numeric regression checks for the canonical implementations
- `fitGP_known_sd.cpp`: canonical TMB model for Gaussian data with known observation noise
- `fitGP_cc.cpp`: TMB model used by the retained case-crossover analysis
