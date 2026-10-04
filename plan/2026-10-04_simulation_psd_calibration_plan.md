# Simulation PSD Calibration Plan

## Goal

Make Simulation 1 and Simulation 2 use the stated true PSD and prior median,
both equal to 2 at original-scale `x = 0` and horizon `h = 5`.

## Implementation plan

- Remove the Simulation B assignment that overwrites the target PSD with the
  PSD of a unit-SD tIWP2 process.
- Specify the fitting prior through BayesGP's original-scale PSD interface,
  allowing its conversion to account for each fitted reference location.
- Clarify that the exponential PSD prior has median 2 (`alpha = 0.5`).
- Inspect cache provenance before replacing any existing simulation results.
  Historical caches contain summary metrics only, so their parameters cannot
  be established from the saved objects.

## Validation targets

- Execute the notebook's actual generators and fitting helpers for A and B,
  with both observation grids.
- Verify the generators' process SD gives PSD 2 and each fitted prior gives
  PSD median 2 after reference-location conversion.
- Check the arguments in all four disabled full-run chunks.
- Run a small end-to-end prediction/metric check and `git diff --check`.

## Cache decision

The existing caches are retained while the user chooses whether to regenerate
the full simulation study. This includes A and B, because both use the same
fitting-prior calibration.
