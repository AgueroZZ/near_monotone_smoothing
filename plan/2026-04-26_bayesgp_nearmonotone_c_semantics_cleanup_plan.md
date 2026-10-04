# BayesGP Near-Monotone `c` Semantics Cleanup Plan

## Summary

Clarify and implement near-monotone `c` as an original-scale additive shift in the base model. Keep the current reference-centered two-sided construction: the smooth is centered at `initial_location`, and the internal mGP/tIWP2 shift is `initial_location + c`.

## Implementation

- Resolve omitted `c` from the effective near-monotone domain:
  - use `region` / `range` for FEM when supplied;
  - otherwise use observed values plus any state-space `grid`;
  - use `c = 0` when the domain lower endpoint is strictly positive;
  - otherwise use `c = -lower_endpoint + tiny_margin`.
- Preserve explicit `c` as the user-supplied original-scale additive shift.
- Enforce strict positivity of `x + c` over the effective domain and remove the old `allow_zero_c` behavior.
- Keep one shared near-monotone boundary basis for both forward and reverse sides.
- Update user-facing documentation and tests to describe the new default and validation behavior.

## Verification

- Add tests for automatic defaults on positive, zero-based, and negative domains.
- Add tests for explicit `c = 0`, explicit `c = 10`, and rejected `allow_zero_c`.
- Confirm shared boundary design remains one column for near-monotone terms.
- Run targeted near-monotone/usability tests, regenerate roxygen docs, then run the full local BayesGP tests.
