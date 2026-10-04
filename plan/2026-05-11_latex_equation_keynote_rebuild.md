# LaTeX Equation Rebuild for `presentation2024.key`

## Objective

Rebuild the 2024 near-monotone talk into `talk/presentation2024.key`, using `talk/presentation2024.pdf` as the authoritative visual/content reference and replacing Unicode math text with LaTeX-rendered equation assets.

## Implementation Plan

- Preserve the current `talk/presentation2024.key` as `talk/presentation2024.key.backup-2026-05-11` before overwrite.
- Generate transparent PNG equation assets from stable LaTeX IDs using `talk/render_equation_assets.mjs`.
- Build a 21-slide intermediate PPTX with editable non-math text and high-quality equation images using `talk/rebuild_presentation2024_deck.mjs`.
- Import the PPTX through Keynote and save the result over `talk/presentation2024.key` when Keynote automation succeeds.

## Verification Plan

- Compile all LaTeX equation assets and fail on compile/render errors.
- Render all generated slides to PNG previews and a contact sheet.
- Validate the PPTX Office package and slide count.
- Verify the resulting Keynote file opens and contains 21 slides; if Keynote automation fails, keep the PPTX as the fallback artifact and document the exact failure in `log/`.

## Completion Summary

- Completed the full 21-slide rebuild into `talk/presentation2024.key`.
- Used LaTeX-rendered transparent PNG assets for math-heavy content and editable text boxes for non-math text.
- Kept plot panels as embedded images.
- Verified the PPTX package, Keynote import slide count, Keynote PDF export slide count, and formula-heavy slide previews.
