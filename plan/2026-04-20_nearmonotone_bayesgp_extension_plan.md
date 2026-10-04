# NearMonotoneGP BayesGP Extension Plan

## Goal

Create a modular R package inside this repository that extends `BayesGP` with
near-monotone smoothing terms for `mgp` and `tiwp2`, while avoiding local TMB
compilation workflows in the research notebooks.

## Design

1. Create a standalone package directory `NearMonotoneGP/`.

2. Reuse the verified mathematical core from the existing repository:
   - exact mGP state-space precision construction
   - exact IWP2 state-space precision construction
   - mGP FEM basis and precision construction
   - Box-Cox style transforms already used for t-IWP2

3. Add a formula-facing wrapper compatible with the `BayesGP` style:
   - `f(x, model = "mgp", method = "state-space", ...)`
   - `f(x, model = "mgp", method = "fem", ...)`
   - `f(x, model = "tiwp2", method = "state-space", ...)`
   - `f(x, model = "tiwp2", method = "fem", ...)`

4. Route fitting through the `BayesGP` engine instead of the repo-local TMB
   wrapper:
   - build `iwp`-compatible instance objects directly
   - pass those instances into `BayesGP:::get_result_by_method()`
   - preserve BayesGP’s handling of Gaussian-family fitting, hyperparameter
     sampling, and boundary-slope priors

5. Keep the package modular:
   - formula interface
   - shared helpers
   - instance builders
   - posterior extraction
   - copied math core files for state-space and FEM

6. Add a smoke test covering the four requested combinations:
   - `mgp` state-space
   - `mgp` FEM
   - `tiwp2` state-space
   - `tiwp2` FEM

## Current Scope Boundaries

- Mixed formulas that combine native BayesGP random-effect models with
  `mgp`/`tiwp2` terms are not supported yet.
- Exact state-space prediction currently requires all requested evaluation
  points to be included in the fitting support grid.
