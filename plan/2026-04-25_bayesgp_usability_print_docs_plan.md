# Plan: BayesGP Usability Fit Output and Model-Specific Documentation

## Summary

Improve the local `BayesGP/` package usability around fitted-object display and model-specific formula documentation. This update removes the exported `model_arguments()` helper, makes `?f` the main model-specific parameter reference, and tailors fitted-object smooth-term output to the actual model types in the fit.

## Implementation Scope

- Replace the fixed `summary.FitResult()` smooth-term table with a model-aware table that drops irrelevant all-`NA` columns.
- Show `a` instead of user-facing `curvature` for near-monotone `mgp` and `tiwp2` terms.
- Keep internal metadata fields unchanged where they are used by prediction and sampling code.
- Remove `model_arguments()` from exports, docs, examples, and tests.
- Expand `f()` roxygen documentation with dedicated sections for `iid`, `iwp`, `sgp`, `mgp`, and `tiwp2`.
- Add `f_iid`, `f_iwp`, `f_sgp`, `f_mgp`, and `f_tiwp2` documentation aliases.
- Add focused tests for print/summary output across supported model families and for `model_arguments()` removal.

## Test Plan

- Run targeted tests for formula interface, exact IWP, and near-monotone Gaussian behavior.
- Run the full local `BayesGP` test suite.
- Regenerate roxygen documentation and confirm generated `NAMESPACE` and `.Rd` files are consistent.

## Assumptions

- This pass is limited to usability, documentation, and directly related stale naming issues.
- No broad numerical-method audit or model-math refactor is included.
- Existing local uncommitted work in `BayesGP/` must be preserved.
