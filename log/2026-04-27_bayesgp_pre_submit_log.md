# BayesGP Pre-Submit Log

Date: 2026-04-27

## Summary

Completed the pre-submit review and validation pass for the local BayesGP near-monotone usability branch before commit and push.

## Review Notes

- Confirmed the active repository is `BayesGP/` and the active branch is `bayesgp-near-monotone-usability`.
- Confirmed `origin` points to `https://github.com/Bayes-GP/BayesGP.git`.
- Confirmed the `origin` default branch is `master`.
- Reviewed the diff scope across R APIs, TMB C++, generated Rd documentation, README files, README figures, and tests.
- Confirmed the new untracked R files, Rd files, README figure, and test files are part of the near-monotone usability and validation update.
- Confirmed the deleted `tests/testthat/test-formula-parser.R` is superseded by `tests/testthat/test-formula-interface.R`.
- Fixed trailing whitespace in `README.md`.

## Validation

- Passed: `git diff --check`
- Passed: `Rscript -e 'devtools::document(".")'`
- Passed: `Rscript -e 'devtools::test(".", reporter = "summary")'`
- Passed: `R CMD build --no-build-vignettes BayesGP`
- Passed: `R CMD check --no-manual --ignore-vignettes BayesGP_0.1.2.tar.gz`

Final source-tarball check status: `OK`.

## Submission Notes

- Created local commit `12ad053` with message `Improve near-monotone usability and docs`.
- Pushed `bayesgp-near-monotone-usability` to `origin` and configured branch tracking.
- `gh` is not installed in this environment.
- GitHub connector PR creation was attempted but failed with `403 Resource not accessible by integration`.
- Manual PR creation URL: `https://github.com/Bayes-GP/BayesGP/pull/new/bayesgp-near-monotone-usability`.
