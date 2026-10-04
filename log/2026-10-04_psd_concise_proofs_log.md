# PSD notation and concise proofs (2026-10-04)

- Unified the transformation symbol as `m` throughout `analysis/PSD.rmd`.
- Replaced the two-lemma proof of Corollary 1 with uniform convergence of the Green-function kernel on the fixed triangular integration domain. The proof covers every fixed finite nonzero `a`.
- Replaced the proof of Corollary 2 with the transformed IWP2 state argument and shrinking transformed prediction interval.
- Updated the interpretation to describe conditional deviations from the continuation determined by the current function value and slope over a fixed interval.
- Retained the corollary statements, operator notation, domain conditions, and PSD computation examples.
- Validation: focused workflowr build completed successfully; both appendix proofs were inspected in the local browser and equations rendered correctly. Source checks confirmed consistent `m` notation and removal of the lemma structure.
- Publication uses an explicit source commit and focused workflowr rebuild because automatic publication did not select the lowercase `.rmd` page.
