# BayesGP Near-Monotone `c` Semantics Cleanup Log

## Summary

Implemented the near-monotone `c` cleanup for the local BayesGP package. User-facing `c` now remains an original-scale additive shift in the base model, while the internal reference-centered shift remains `initial_location + c`.

## Changes

- Changed omitted near-monotone `c` handling to choose a domain-aware default:
  - `c = 0` when the effective term domain is already strictly positive;
  - `c = -min(domain) + tiny_margin` when the domain touches or crosses zero.
- Enforced strict `x + c > 0` validation over the effective near-monotone domain.
- Removed the old `allow_zero_c` behavior by making that argument an explicit error.
- Preserved the existing shared boundary structure: one near-monotone boundary basis column shared across forward and reverse sides.
- Updated `f()` and `model_fit()` documentation to describe the original-scale `c`, automatic default behavior, and shared boundary interpretation.
- Added tests for automatic `c`, explicit `c = 0`, explicit `c = 10`, rejected `allow_zero_c`, and shared boundary basis size.

## Verification

- Passed `test-near-monotone-gaussian.R`.
- Passed `test-fitresult-usability.R`.
- Passed `test-formula-interface.R`.
- Passed `test-near-monotone-casecrossover.R`.
- Passed `test-psd-helpers.R`.
- Passed full `devtools::test(".")`.
- Ran `R CMD check --no-manual --ignore-vignettes --no-tests .`; it completed with status `7 WARNINGs, 2 NOTEs`, consistent with existing package hygiene/documentation issues rather than this change.
