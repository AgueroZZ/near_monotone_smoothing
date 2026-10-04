# Near-Monotone `sd.prior` PSD Specification Plan

Date: 2026-04-21

## Goal

Allow near-monotone terms in the local `BayesGP` fork to accept PSD-scale prior
specifications directly inside `sd.prior`, analogous to the existing
step-based `iwp` and `sgp` interfaces.

Target behavior:

```r
sd.prior = list(
  prior = "exp",
  param = list(u = 0.01, alpha = 0.5),
  h = 5,
  x = 0
)
```

for `model = "mgp"` and `model = "tiwp2"`, with automatic conversion of the
PSD-scale `u` value to the internal `sigma` prior scale during fitting.

## Problems to Fix

1. Near-monotone terms currently require manual PSD adjustment outside
   `model_fit()`, even though `iwp` and `sgp` already support step-based prior
   conversion inside `sd.prior`.
2. `mgp` and `tiwp2` PSD priors depend on both a step size and an evaluation
   location, so the current manual workflow is repetitive and easy to get wrong.
3. `prior_conversion_mgp()` still returns `prob` rather than the package-wide
   `alpha` field used by the exponential PC prior interface.

## Planned Changes

1. Add a near-monotone `sd.prior` conversion helper that:
   - accepts `h` or `step`
   - requires scalar `x`
   - dispatches by `model = "mgp"` or `model = "tiwp2"`
   - stores the original PSD prior in `psd.prior`
   - rewrites `sd.prior$param` onto the internal `sigma` scale
2. Update `prior_conversion_mgp()` to return the standard `list(u, alpha)`
   structure.
3. Add a `prior_conversion_tiwp2()` helper for symmetry with `mgp`.
4. Update active analysis files that currently compute the near-monotone prior
   scaling manually right before calling `model_fit()`.
5. Add regression tests for:
   - PSD-scale `sd.prior` conversion for `mgp`
   - PSD-scale `sd.prior` conversion for `tiwp2`
   - missing-`x` validation when `h` / `step` is supplied

## Verification

1. Run the focused near-monotone test files.
2. Run a small `casecross`-style smoke fit using the new `sd.prior`
   specification.
3. Reinstall the updated `BayesGP` package into the user library so Positron
   sees the new behavior immediately.
