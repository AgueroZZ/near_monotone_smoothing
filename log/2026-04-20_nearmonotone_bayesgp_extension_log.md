# Update Log: NearMonotoneGP BayesGP Extension

## Summary

Added a new package directory `NearMonotoneGP/` that wraps `BayesGP` with
near-monotone `mgp` and `tiwp2` smooth terms, supporting both exact
state-space and FEM computation paths.

## What Was Added

- Package scaffold:
  - `NearMonotoneGP/DESCRIPTION`
  - `NearMonotoneGP/NAMESPACE`
  - `NearMonotoneGP/README.md`

- Formula interface:
  - `NearMonotoneGP/R/formula_interface.R`
  - supports `f(..., model = "mgp")` and `f(..., model = "tiwp2")`

- Shared helpers:
  - prior normalization
  - boundary basis construction
  - exact observation-matrix construction
  - fixed-effect design handling

- BayesGP bridge:
  - `NearMonotoneGP/R/model_fit.R`
  - constructs `iwp`-compatible smooth instances and delegates fitting to
    `BayesGP:::get_result_by_method()`

- Near-monotone instance builders:
  - `NearMonotoneGP/R/instance_builders.R`
  - `mgp` exact state-space
  - `mgp` FEM
  - `tiwp2` exact state-space
  - `tiwp2` FEM with equally spaced transformed-scale knots

- Posterior helpers:
  - `NearMonotoneGP/R/posterior.R`
  - `smooth_samples()`
  - `smooth_summary()`

- Math core copied into the package:
  - `NearMonotoneGP/R/state_space_math.R`
  - `NearMonotoneGP/R/fem_math.R`

## Implementation Notes

- The package no longer tries to subclass BayesGP’s internal `iwp` class,
  because that class is not exported and caused installation failures.
- Instead, the package builds actual `iwp` instances and stores the extra
  `mgp` / `tiwp2` metadata alongside the fitted object.
- FEM helpers were patched to use explicit `Matrix` operations so they work
  consistently inside a package namespace instead of depending on notebook
  session state.

## Current Limitations

- Formulas mixing native BayesGP random-effect models with `mgp` / `tiwp2`
  terms are not yet supported.
- Exact state-space posterior evaluation currently works only on support points
  provided during fitting.
- No man pages were generated yet; the package currently relies on source-level
  documentation and the README.

## Verification

- `Rscript --vanilla -e 'devtools::load_all("NearMonotoneGP", quiet = TRUE); source("NearMonotoneGP/inst/examples/smoke_test.R")'`
  - passed
- `R CMD INSTALL -l /tmp/Rlib NearMonotoneGP`
  - passed
