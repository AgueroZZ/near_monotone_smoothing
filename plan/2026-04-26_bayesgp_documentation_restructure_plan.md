# BayesGP Documentation Restructure Plan

## Summary

Restructure the local BayesGP package documentation so `?f` is a concise entry point and each supported model has its own help topic. Update near-monotone defaults so `mgp` and `tiwp2` use FEM unless `computation = "state-space"` is requested.

## Implementation

- Change near-monotone smooth terms to default to `computation = "fem"`.
- Replace "legacy" wording with neutral wording for existing BayesGP FEM/O-spline functionality.
- Rewrite `?f` as an overview with shared arguments, common prior examples, supported models, and links to model-specific pages.
- Add roxygen help topics for `f_iid`, `f_iwp`, `f_sgp`, `f_mgp`, and `f_tiwp2`, including dot aliases such as `f.mgp`.
- Update `model_fit`, `supported_models`, README references, and tests to match the new default and documentation layout.
- Regenerate roxygen documentation and run targeted and full tests.

## Verification

- Tests should confirm default near-monotone computation is FEM.
- Documentation tests should confirm model-specific aliases exist and generated docs avoid "legacy FEM".
- Run targeted interface/usability tests, full `devtools::test(".")`, and `R CMD check --no-manual --ignore-vignettes --no-tests .`.
