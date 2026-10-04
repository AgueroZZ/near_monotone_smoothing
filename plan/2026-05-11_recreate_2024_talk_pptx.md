# Recreate 2024 Talk Deck as Editable PPTX

## Objective

Rebuild `talk/presentation2024.pdf` as a 16:9 editable PowerPoint deck that can be opened in Keynote and used as the base for a later 12-15 slide, 30-minute talk.

## Implementation Plan

- Generate `talk/near-monotone-2024-recreated.pptx` from a repeatable Node script using the bundled artifact-tool presentation runtime.
- Recreate the white Keynote-style visual system with editable title, body, and equation text where practical.
- Embed complex plots as raster assets, using crops from `talk/presentation2024.pdf` for faithful plot panels and existing `output/sim5_*` figures for simulation slides.
- Keep temporary cropped assets, previews, and QA manifests under `/private/tmp/codex-presentations/...` instead of adding them to the repo.

## Verification Plan

- Render all generated slides to PNG previews and a contact sheet.
- Verify the exported PPTX has 21 slides and a non-empty Office package.
- Compare the recreated contact sheet against the original PDF contact sheet for slide order, titles, formula placement, and plot layout.
- Record non-editable embedded assets in `log/`.
