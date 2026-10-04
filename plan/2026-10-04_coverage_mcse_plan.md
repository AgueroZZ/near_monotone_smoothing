# Coverage Monte Carlo Standard Error Plan

## Goal

Use the empirical variability of replication-level coverage proportions to
compute the Monte Carlo standard error of their mean in both simulation pages.

## Implementation plan

- Replace the Bernoulli formula with `sd(coverage) / sqrt(n())` in every
  A/B, interpolation/prediction, model, and interval-level summary.
- Name coverage errors as MCSEs and retain the existing mean +/- 3 MCSE plots.
- Clarify that table parentheses show coverage MCSEs and error-metric SDs.
- Rebuild both pages locally using the existing caches.

## Validation targets

- Evaluate all actual summary and coverage-plot chunks against cached data.
- Check corrected errors and unchanged means/error-metric summaries.
- Confirm both workflowr page builds and `git diff --check` pass.
