# Original-Scale Near-Monotone `c` Plan

## Goal

Make `c` in `mgp` and `tiwp2` terms a user-facing original-scale shift. Users should write a base model such as `m(x) = sqrt(x + c)` directly, while the package handles the internal centered coordinate induced by `initial_location`.

## Implementation Steps

1. Interpret formula-level `c` as the original-scale shift `c_user`.
2. After resolving `initial_location = x0`, compute the internal process shift as `c_internal = x0 + c_user`.
3. Use `c_internal` for state-space precision, FEM precision, Box-Cox transforms on centered coordinates, and normalized boundary basis evaluation.
4. Keep metadata for both user-facing and internal values so summaries can display `c_user` while diagnostics can inspect `c_internal`.
5. Treat `sd.prior$x` as an original-scale input and convert it to the centered coordinate only inside PSD prior conversion.
6. Update documentation and helper tables to describe original-scale semantics.
7. Add tests checking that normalized boundary coefficients correspond to `f(x0)` and `f'(x0)` under multiple reference locations.
8. Re-run focused consistency checks and the package test suite.
