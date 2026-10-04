# tIWP2 Method Consistency Check Plan

Date: 2026-04-21

## Goal

Check whether the `tiwp2` implementations with `method = "state-space"` and
`method = "fem"` produce numerically consistent results under matched model
settings.

## Work Items

1. Inspect the current `tiwp2` FEM and state-space implementations to confirm
   what is being compared.
2. Run a direct comparison on the illustration-style synthetic example used in
   the retained notebooks.
3. Run a second compact synthetic example to guard against conclusions that are
   specific to one dataset.
4. Save a reproducible comparison script and summarize the findings in the log.
