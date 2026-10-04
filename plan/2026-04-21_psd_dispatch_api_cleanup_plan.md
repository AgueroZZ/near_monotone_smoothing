# PSD Dispatch API Cleanup Plan

Date: 2026-04-21

## Goal

Replace the current model-specific `PSD_compute()` behavior in the local
`BayesGP` fork with a general dispatcher API:

- `PSD_compute(model, h, x = NULL, sd = 1, ...)`

and align the active notebooks and package-facing helpers with that unified
entry point.

## Problems to Fix

1. `PSD_compute()` currently computes only the exact `mgp` predictive standard
   deviation factor, even though its name reads like a generic package-level
   helper.
2. `tiwp2` uses separate names (`PSD_tIWP2_compute()` and
   `compute_tiwp_psd_boxcox()`), while `iwp` and `sgp` expose only prior
   conversion helpers.
3. The user-facing API is therefore fragmented, and the current naming is easy
   to misread when moving between models.
4. `BayesGP` currently does not export these PSD helpers through
   `NAMESPACE`, so `library(BayesGP)` does not expose them cleanly.

## Planned Changes

1. Add explicit model-specific PSD backends in `BayesGP`:
   - `PSD_compute_mgp()`
   - `PSD_compute_tiwp2()`
   - `PSD_compute_iwp()`
   - `PSD_compute_sgp()`
2. Redefine `PSD_compute()` as the general dispatcher:
   - `PSD_compute(model, h, x = NULL, sd = 1, ...)`
   - dispatch by `model`
   - validate model-specific required arguments
3. Update `prior_conversion_mgp()` to use the new `mgp` backend explicitly.
4. Export the new PSD helpers from `BayesGP` and update the manual Rd page.
5. Replace active notebook and support-script calls that currently use:
   - `PSD_compute(...)` as if it were `mgp`-specific
   - `PSD_tIWP2_compute(...)`
   with the unified dispatcher form.
6. Keep the transitional `NearMonotoneGP` compatibility layer aligned with the
   same PSD helper names so the repository does not drift into two conflicting
   APIs.

## Verification

1. Add regression tests covering the dispatcher and the model-specific PSD
   helpers.
2. Re-run focused `BayesGP` tests that touch near-monotone helpers.
3. Re-run a small notebook-relevant smoke check for the updated PSD calls.
4. Reinstall the local `BayesGP` package into the user R library so Positron
   sees the updated API immediately.
