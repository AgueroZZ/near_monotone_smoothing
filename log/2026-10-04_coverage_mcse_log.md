# Coverage Monte Carlo Standard Error Log

## Context

Each cached replication contains a coverage proportion across evaluation
locations. The simulation pages used a Bernoulli standard-error formula for
the mean of these proportions, rather than their empirical variability.

## Changes

- Replace all 48 coverage error calculations in Simulation 1/2, A/B,
  interpolation/prediction, both models, and all three interval levels with
  `sd(coverage) / sqrt(n())`.
- Rename coverage error fields and plotting variables as MCSEs.
- Retain the mean +/- 3 MCSE error-bar convention and state it in subtitles.
- Explain that table parentheses show coverage MCSEs and replication SDs
  for RMSE and mean relative error.

## Validation

- Evaluated the actual table and coverage-plot chunks against all four caches.
  All 48 coverage means, empirical MCSEs, and plotted bounds passed checks.
- Coverage means and RMSE/relative-error means and SDs match the original
  cached metrics.
- Replication counts are read from each table, including 995 for Simulation
  1 B and 1000 for the other caches.
- Example: Simulation 1 A, mGP, interpolation, 95% coverage remains 0.94477;
  its MCSE is now 0.002847640 rather than 0.007223548.
- Both workflowr page builds passed in fresh R sessions; all eight coverage
  images were regenerated. Checked the rendered table definitions and a
  representative plot's MCSE subtitle and error bars.
- SHA-256 checks confirm all four simulation caches and `analysis/PSD.rmd`
  were unchanged by this update.
- `git diff --check`: passed after trimming generated HTML locale whitespace.

## Scope

This correction uses the existing caches. No simulation regeneration or
BayesGP implementation changes are needed for the error-bar update.
The PSD theory page is left for the later discussion requested by the user.
The local pages were rebuilt during validation. The user subsequently
requested commits and pushes without rebuilding the webpages again.
