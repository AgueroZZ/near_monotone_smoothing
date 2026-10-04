# Illustration Legacy Reproduction Plan

Date: 2026-04-21

## Goal

Confirm that the published `illustration.html` results can be reproduced through
the unified in-repo `BayesGP` package interface, and tighten any package gaps
that prevent a like-for-like comparison.

## Work Items

1. Inspect the published legacy `illustration.html` page and extract the exact
   model settings used there.
2. Compare the legacy workflow against the current `analysis/illustration.rmd`
   notebook to identify any settings drift or computation-method mismatch.
3. If needed, extend `BayesGP` so that the compact formula interface matches the
   legacy computation pathway.
4. Update `analysis/illustration.rmd` so the retained notebook mirrors the
   published experiment settings.
5. Add automated checks for any new package pathway introduced during the
   reproduction work.
6. Run the notebook and a direct legacy-vs-compact comparison script, then log
   the resulting agreement metrics.
