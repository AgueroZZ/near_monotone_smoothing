# Near-Monotone Reference Location Plan

## Goal

Extend the compact BayesGP near-monotone formula interface so users can place
the reference location away from the left boundary when fitting `mgp` or
`tiwp2` terms.

## Background

The archived arbitrary-reference FEM code splits the process at the reference
location:

- positive side: `x - ref_location`
- negative side: `ref_location - x`
- positive FEM precision: `Compute_Prec()`
- negative FEM precision: `Compute_Prec_rev()`
- combined random basis: `cbind(B_pos, B_neg)`
- combined precision: `Matrix::bdiag(P_pos, P_neg)`

This matches the design described in the previous analysis notes for
constraints when `x != 0`.

## Implementation Scope

1. Support `initial_location = "middle"`, `"right"`, or a numeric value for
   near-monotone FEM terms.
2. Keep the default `initial_location = "left"` unchanged.
3. Implement two-sided FEM basis and precision construction for both:
   - `model = "mgp"`
   - `model = "tiwp2"`
4. Support non-left reference locations for exact state-space `tiwp2` by
   splitting transformed positive and negative supports into independent IWP2
   blocks.
5. Support non-left reference locations for exact state-space `mgp` where the
   reverse precision formulas are stable and validated (`a` equal to 1, 2, or
   -1). Other curvatures should fail clearly and point users to FEM.
6. Preserve the current shifted-coordinate interpretation of `c`: all domain
   points must satisfy `x - initial_location + c > 0`.

## Validation

- Add regression tests for:
  - `mgp` FEM with `initial_location = "middle"`
  - `tiwp2` FEM with `initial_location = "middle"`
  - exact state-space `tiwp2` with `initial_location = "middle"`
  - exact state-space `mgp` with `initial_location = "middle"` and `a = 2`
  - exact state-space `mgp` with a non-left reference and unsupported reverse
    curvature producing a clear FEM-path error
- Run the targeted near-monotone Gaussian test file.
