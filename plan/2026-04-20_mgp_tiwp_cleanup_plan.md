# mGP / t-IWP Research Repo Cleanup and Canonicalization

## Goal

Keep the repository as a `workflowr` research project, make the active method story internally consistent, and move prototype/debug materials out of the main workflow.

## Scope

1. Fix verified math and code issues:
   - correct copied `PSD_tIWP2_compute()` usage so retained active analyses use predictive standard deviation
   - correct the FEM derivation in the method overview so the written formulas match `Compute_Prec()`
   - correct the `m''(x) / m'(x)` curvature relation typo in the PSD writeup
   - make the repository status explicit that `t-IWP2` FEM is not implemented
   - remove stale helper behavior such as undefined `ln()` usage and ambiguous partial matching around the curvature parameter

2. Establish a canonical code layer:
   - keep exact mGP, exact transformed t-IWP2, and mGP FEM as canonical implemented methods
   - centralize notebook-facing helpers in `code/06-model-helpers.R`
   - expose canonical PSD, fitting, sampling, transform, and evaluation helpers
   - keep backward compatibility for legacy `alpha=` call sites, while standardizing the explicit interface on `a=`

3. Tidy retained notebooks and documentation:
   - make active notebooks source canonical helpers instead of defining private fit/sample/PSD helpers
   - refresh `README.md`, `analysis/about.Rmd`, and the workflowr navigation
   - keep the site navbar focused on the canonical method pages

4. Archive non-canonical materials:
   - move prototype/debug analyses out of `analysis/`
   - archive superseded helper scripts and legacy generated documentation for those pages

5. Rebuild and verify:
   - restore the repository as a valid `workflowr` project
   - rebuild the canonical workflowr pages
   - run numeric regression checks for the canonical exact/FEM/PSD implementations

## Expected Deliverables

- corrected math writeups in `analysis/index.Rmd` and `analysis/PSD.rmd`
- canonical helper layer in `code/06-model-helpers.R`
- cleaned active workflowr tree and updated `docs/`
- archived prototype/debug materials under `archive/`
- update log recorded in `log/`
