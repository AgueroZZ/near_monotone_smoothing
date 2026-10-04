# BayesGP Documentation Restructure Log

## Summary

Restructured the local BayesGP documentation around `f()` and changed near-monotone `mgp` / `tiwp2` terms to default to FEM computation.

## Changes

- Changed near-monotone smooth-term default computation from state-space to FEM.
- Rewrote `?f` as a concise overview with shared arguments, common prior syntax, supported models, and links to model-specific help topics.
- Added model-specific help topics:
  - `?f_iid` / `?f.iid`
  - `?f_iwp` / `?f.iwp`
  - `?f_sgp` / `?f.sgp`
  - `?f_mgp` / `?f.mgp`
  - `?f_tiwp2` / `?f.tiwp2`
- Replaced documentation language that described BayesGP FEM/O-spline functionality as legacy.
- Updated `?model_fit`, `?supported_models`, README references, and prediction docs to match the new wording.
- Added documentation smoke tests for model-specific aliases, removed `model_arguments`, and absence of legacy FEM wording.
- Added tests confirming `mgp` and `tiwp2` default to FEM.

## Verification

- Passed targeted documentation, formula-interface, FitResult usability, near-monotone Gaussian, and near-monotone case-crossover tests.
- Passed full `devtools::test(".")`.
- Ran `R CMD check --no-manual --ignore-vignettes --no-tests .`; it completed with status `7 WARNINGs, 2 NOTEs`, matching the existing package hygiene/documentation warnings.
