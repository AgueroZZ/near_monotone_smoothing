# BayesGP Core Near-Monotone Integration Plan

## Goal

Move the retained notebook workflows onto a single formula-driven interface in a
local `BayesGP` fork, instead of relying on the compatibility helper layer in
`NearMonotoneGP`.

## Motivation

The current `NearMonotoneGP` package provides a working extension wrapper, but
the retained notebooks still depend on helper functions for two reasons:

1. `mgp` and `tiwp2` are not native `BayesGP` random-effect models.
2. Gaussian models with known observation standard deviation are not handled as
   a first-class pathway in the `BayesGP` core likelihood.

Integrating both pieces into `BayesGP` directly gives a cleaner architecture:

- one formula entrypoint through `model_fit()`
- one term declaration entrypoint through `f(...)`
- one posterior sampling/prediction API through `predict()`
- no notebook-facing dependence on the helper-based exact-fit wrappers

## Plan

1. Create a local development fork of `BayesGP` inside the workspace and work
   from its `development` branch.

2. Add native near-monotone support to `BayesGP`:
   - define internal helpers for monotone transforms and near-monotone
     precision/design construction
   - add `mgp` and `tiwp2` S4 classes extending the `iwp` workflow
   - support both `"state-space"` and `"fem"` computation methods

3. Refactor the fitting pipeline so `model_fit()` can build mixed native and
   near-monotone terms within the same formula.

4. Add a first-class Gaussian known-SD pathway in the `BayesGP` likelihood:
   - allow fixed observation SD through `control.family`
   - avoid creating a Gaussian family variance hyperparameter when the SD is
     known
   - keep the existing prior-based SD pathway for the standard Gaussian model

5. Extend posterior prediction and summaries so `predict.FitResult()` works for
   `mgp` and `tiwp2`, including the exact-grid and FEM cases needed by the
   notebooks.

6. Port the near-monotone simulation and PSD helpers that are used in
   `analysis/`, so the notebooks can load `BayesGP` directly.

7. Update representative notebooks to use the unified formula interface and
   verify the workflow by rendering the retained analyses.
