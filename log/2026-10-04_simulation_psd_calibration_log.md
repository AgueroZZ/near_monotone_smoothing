# Simulation PSD Calibration Log

## Context

Both simulation pages set `true_psd = 2` in their setup, but Simulation B
overwrote it with the PSD of a unit-SD tIWP2 process (approximately 2.849752).
Consequently, rerunning the old source would generate B data under a different
PSD than the stated value of 2.

The shared fitting helper also accepted manually converted process-SD priors.
For tIWP2, this conversion used reference 0, whereas the fitted grids start at
0.1 (Simulation 1) and 0.2 (Simulation 2). Even with target PSD 2, this would
give PSD prior medians of approximately 2.148199 and 2.293063, respectively.
This fitting-prior issue affects A and B.

## Changes

- Remove the Simulation B overwrite of `true_psd` in both pages.
- Use `sd.prior = list(prior = "exp", param = list(u = prior_psd,
  alpha = 0.5), h = 5, x = 0)` in the shared fitting helpers.
- Pass target PSD 2 directly from all four full-run chunks, and remove
  obsolete process-SD conversion variables from parallel-worker exports.
- Clarify that the exponential PSD prior's median equals the true PSD.
- Add a cache-provenance note to both pages.
- Add `analysis/simulation_psd_calibration_check.R`, which executes the actual
  notebook generators and fitting/prediction helpers. Its PSD checks use
  independent square-root Green-function and transformed-IWP formulas.

## Validation

- `OPENBLAS_NUM_THREADS=1 Rscript analysis/simulation_psd_calibration_check.R`:
  passed all eight combinations (two pages, A/B, two fitted models).
- In all combinations, generated PSD and fitted prior PSD median equal 2
  within absolute tolerance `1e-10`; fitted references are 0.1 and 0.2.
- Predictions produced finite interpolation/extrapolation metrics.
- The disabled full-run chunks all pass PSD 2 to both fitted model priors
  and to the generating model, with 1000 requested replications.
- `workflowr::wflow_build()` for both simulation pages: passed, each in a
  fresh R session. The rendered pages contain the corrected median wording
  and the cache-provenance note. They have not been published.
- `git diff --check`: passed in both repositories after removing trailing
  spaces in the generated HTML locale listings.

## Cache status

The historical `.rda` files contain only four tables of summary metrics, with
no saved parameters, seed, source version, or simulated data. Therefore their
PSD settings cannot be established. Simulation 1 B has 995 retained rows;
the other three caches have 1000. This is separate from the PSD source fix.

Existing caches are retained pending the user's choice about a full rerun.
The separate coverage Monte Carlo error-bar issue was subsequently corrected;
see `2026-10-04_coverage_mcse_log.md`.
