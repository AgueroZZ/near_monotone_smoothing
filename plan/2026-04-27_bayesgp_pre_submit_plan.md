# BayesGP Pre-Submit Plan

Date: 2026-04-27

## Goal

Prepare the local `bayesgp-near-monotone-usability` branch for submission to `Bayes-GP/BayesGP` by reviewing the local diff, fixing hygiene issues, validating the package, and publishing a clean commit.

## Scope

- Review the changed R package API, generated documentation, README, C++ TMB template, and test files.
- Confirm the new near-monotone, exact IWP, model info, and post-fit helper files are intentional.
- Confirm `tests/testthat/test-formula-parser.R` is superseded by `tests/testthat/test-formula-interface.R`.
- Fix pre-submit hygiene issues before staging.
- Run package validation from a source tarball before committing.

## Validation

- `git diff --check`
- `Rscript -e 'devtools::document(".")'`
- `Rscript -e 'devtools::test(".", reporter = "summary")'`
- `R CMD build --no-build-vignettes BayesGP`
- `R CMD check --no-manual --ignore-vignettes BayesGP_0.1.2.tar.gz`

## Submission

- Stage only intentional BayesGP package changes.
- Commit with message `Improve near-monotone usability and docs`.
- Push `bayesgp-near-monotone-usability` to `origin`.
- Open a draft PR against the remote default branch, `master`, if GitHub tooling is available.
