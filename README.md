# Smoothing with M-GP

A [workflowr][] research project for near-monotone smoothing with curvature-aware Gaussian priors.

This repository studies and compares three related constructions:

- `mGP`: the curvature-aware Gaussian prior defined by
  `L_alpha f = sigma xi`
- `t-IWP2`: a transformed IWP2 prior used as an exact comparison model
- `mGP FEM`: a finite-element approximation to the mGP prior

The canonical project layout is:

- `analysis/`: retained workflowr source pages
- `archive/`: archived prototype/debug analyses and superseded helper scripts
- `code/`: shared R/TMB implementations used by the retained analyses
- `BayesGP/`: local development fork where near-monotone support is now integrated into the core package
- `NearMonotoneGP/`: transitional extension package retained as a compatibility/reference layer
- `docs/`: rendered workflowr site
- `data/`: raw data inputs
- `output/`: cached simulation outputs and derived figures
- `plan/` and `log/`: collaboration artifacts for major repo updates

Current method status:

- Exact mGP state-space implementation: implemented and checked
- Exact t-IWP2 transformed-grid implementation: implemented and checked
- mGP FEM approximation: implemented and checked
- t-IWP2 FEM approximation: implemented and checked

The active workflowr navigation is focused on the canonical method pages (`index`, `PSD`, `illustration`, `mGP_vs_tIWP2`) plus project metadata pages. Debug and prototype analyses are archived out of the active workflowr source tree.

The active notebooks now load the in-repo `BayesGP` fork via
`devtools::load_all("BayesGP", quiet = TRUE)` and use the unified formula
interface:

- `model_fit(...)`
- `f(..., model = "mgp" | "tiwp2", method = "state-space" | "fem")`
- `predict(..., only.samples = TRUE)`

## Local Website

Build the local project website with:

```bash
Rscript scripts/build_site.R
```

Serve the rendered site from `docs/` with:

```bash
bash scripts/serve_docs.sh 8000
```

Then open `http://127.0.0.1:8000`.

[workflowr]: https://github.com/workflowr/workflowr
