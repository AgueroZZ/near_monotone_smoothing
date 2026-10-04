# Update Log: 2026-04-20

## Summary

This update canonicalized the active mGP / t-IWP workflow, fixed the verified math and code issues, archived prototype/debug materials, restored workflowr project metadata, and rebuilt the published method pages.

## Code Changes

- Added `code/06-model-helpers.R` as the shared notebook-facing helper layer for:
  - Box-Cox transforms and derivatives
  - mGP and t-IWP PSD calibration
  - exact fitting helpers for IWP2, t-IWP2, and mGP
  - mGP FEM fitting and posterior sampling helpers
  - t-IWP simulation on transformed grids
  - interval evaluation helpers for supporting simulation notebooks
- Added `code/07-regression-checks.R` for canonical numeric regression checks.
- Updated `code/01-state-space.R` to:
  - resolve curvature through explicit `a`/`alpha` handling
  - fix `boundary_compute()` to use `log()`
  - remove unnecessary precision rounding
  - return sparse matrices without deprecated `dgTMatrix` coercions
- Updated `code/02-FEM.R`, `code/03-sampling.R`, and `code/05-sampling-adjoint.R` to use the explicit curvature-resolution path and cleaner sparse-matrix interfaces.

## Notebook and Documentation Changes

- Fixed the FEM derivation in `analysis/index.Rmd` so the written matrix construction matches the implemented operator.
- Fixed the curvature relation typo in `analysis/PSD.rmd`.
- Updated `analysis/illustration.rmd` to use the canonical helper layer and corrected the FEM plotting object.
- Updated `analysis/simulation1.rmd` and `analysis/simulation2.rmd` to remove private PSD/fit/sample implementations and use canonical exact helpers.
- Updated `analysis/casecross.rmd` to use the shared TMB compile helper.
- Refreshed `README.md`, `analysis/about.Rmd`, `analysis/_site.yml`, and `code/README.md`.

## Archive Changes

Archived prototype/debug materials out of the active workflowr tree:

- `analysis/FEM_arbitrary_ref.rmd`
- `analysis/sampling.rmd`
- `analysis/simulation3.rmd`
- `analysis/simulation4.rmd`
- `analysis/simulation5.rmd`
- `analysis/state_space_debug.rmd`
- `code/fit_FEM_ref.R`
- `code/fit_FEM_ref_new.R`
- `FEM_arbitrary_ref.r`
- `check_psd_tiwp2.R`

Legacy generated documentation for archived pages was moved to:

- `archive/docs_legacy_2026-04-20/`

## Workflowr / Site

- Added `near_monotone_smoothing.Rproj` so the repository is again detectable as a workflowr project.
- Rebuilt the canonical published pages:
  - `docs/index.html`
  - `docs/PSD.html`
  - `docs/illustration.html`
  - `docs/mGP_vs_tIWP2.html`
  - `docs/about.html`
  - `docs/license.html`
- Removed archived-page HTML outputs and their figure assets from the active `docs/` tree by moving them to `archive/docs_legacy_2026-04-20/`.

## Local Website Portal

- Upgraded the active site navigation in `analysis/_site.yml` to include:
  - `Methods`
  - `Supporting`
  - `Project`
- Added a portal-style home section to `analysis/index.Rmd` with quick links to:
  - overview
  - PSD
  - comparison page
  - illustration
  - simulation 1
  - simulation 2
  - case-crossover
  - about page
- Published supporting pages to the active `docs/` tree:
  - `docs/simulation1.html`
  - `docs/simulation2.html`
  - `docs/casecross.html`
- Added local site utility scripts:
  - `scripts/build_site.R`
  - `scripts/serve_docs.sh`
- Updated `README.md` with local build and serve instructions.

## Verification

- `Rscript --vanilla code/07-regression-checks.R`
  - passed
- `workflowr::wflow_build()` for canonical pages
  - passed after restoring the missing `.Rproj` metadata
- `rmarkdown::render("analysis/simulation1.rmd")`
  - passed as a supporting-analysis smoke test
- `rmarkdown::render("analysis/simulation2.rmd")`
  - passed as a supporting-analysis smoke test
- `rmarkdown::render("analysis/casecross.rmd")`
  - passed as a supporting-analysis smoke test
- `Rscript --vanilla scripts/build_site.R`
  - passed using `rmarkdown::render_site()` from `analysis/`

## Notes

- `t-IWP2` FEM remains explicitly unimplemented in this repository.
- `analysis/simulation1.rmd`, `analysis/simulation2.rmd`, and `analysis/casecross.rmd` remain as supporting source analyses, but only the canonical method pages are currently published in `docs/`.
- The supporting notebook renders still emit Pandoc div-balance warnings in the intermediate markdown, but the notebooks render successfully.
