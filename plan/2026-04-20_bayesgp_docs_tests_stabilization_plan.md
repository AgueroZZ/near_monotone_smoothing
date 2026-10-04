# BayesGP Docs and Tests Stabilization Plan

## Goal

Stabilize the new near-monotone integration in the local `BayesGP` fork by
adding package-facing documentation and regression tests.

## Plan

1. Fix the package test harness so `testthat` runs against the local `BayesGP`
   fork rather than an unrelated package target.

2. Add regression tests covering:
   - formula parsing for `f(..., model = "mgp" | "tiwp2")`
   - Gaussian known-SD fits for exact and FEM near-monotone terms
   - posterior extraction through `predict(..., only.samples = TRUE)`
   - native `mgp` FEM usage inside the case-crossover family

3. Update the main user-facing docs:
   - `BayesGP/README.Rmd` and `BayesGP/README.md`
   - manual pages for `f`, `model_fit`, and `predict.FitResult`
   - a grouped manual page for near-monotone utilities

4. Re-run package verification after the docs/tests changes.
