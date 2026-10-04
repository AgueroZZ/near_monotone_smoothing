# 2026-05-11 Recreate 2024 Talk PPTX

## Status

Complete.

## Notes

- Source deck: `talk/presentation2024.pdf`, a 21-slide 16:9 PDF exported from Keynote.
- Target deliverable: `talk/near-monotone-2024-recreated.pptx`.
- Build source: `talk/recreate_2024_deck.mjs`.
- Strategy: editable text/equations for the main slide content, raster embedded assets for complex plots and simulation result panels.

## Output

- Generated PPTX: `talk/near-monotone-2024-recreated.pptx` (885,987 bytes).
- Slide count: 21.
- Embedded media count: 10.
- Editable text runs in the PPTX package: 132.
- Temporary build workspace: `/private/tmp/codex-presentations/019e1550-e5c6-7bf3-9d1f-f651906db94b/near-monotone-2024-recreate`.

## Non-editable Embedded Assets

- Cropped plot panels from `talk/presentation2024.pdf` are embedded on slides 2, 5, 7, 9, 10, and 17.
- Simulation result panels on slides 18 and 19 use `output/sim5_coverage_rate_caseA.png`, `output/sim5_interval_width_caseA.png`, and converted PNG assets from the Scenario B PDF outputs.

## Verification

- `node --check talk/recreate_2024_deck.mjs`: passed.
- `node talk/recreate_2024_deck.mjs`: generated PPTX and slide previews.
- `unzip -t talk/near-monotone-2024-recreated.pptx`: passed with no package errors.
- PPTX package inspection: 21 slide XML files, 10 media files, 132 text runs.
- Rendered recreated slide previews and contact sheet at `/private/tmp/codex-presentations/019e1550-e5c6-7bf3-9d1f-f651906db94b/near-monotone-2024-recreate/preview/contact-sheet.png`.
- Rendered original-vs-recreated contact sheet at `/private/tmp/codex-presentations/019e1550-e5c6-7bf3-9d1f-f651906db94b/near-monotone-2024-recreate/preview/original-vs-recreated-contact.png`.
- `/usr/bin/qlmanage -t` produced a valid macOS Quick Look thumbnail for the PPTX.
