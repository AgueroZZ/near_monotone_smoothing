# 2026-05-11 LaTeX Equation Keynote Rebuild

## Status

Complete.

## Notes

- Source reference: `talk/presentation2024.pdf`.
- Target file: `talk/presentation2024.key`.
- Backup file: `talk/presentation2024.key.backup-2026-05-11`.
- Equation renderer: `talk/render_equation_assets.mjs`.
- Deck builder/importer: `talk/rebuild_presentation2024_deck.mjs`.
- Strategy: keep non-math text editable, render math-heavy equations/propositions/corollaries from LaTeX as transparent PNG assets, and preserve plots as embedded images.

## Results

- Rebuilt the 21-slide deck and saved it to `talk/presentation2024.key`.
- Preserved the previous one-slide Keynote file as `talk/presentation2024.key.backup-2026-05-11`.
- Wrote an intermediate Keynote-compatible deck to `talk/presentation2024-latex-rebuild.pptx`.
- Generated 48 LaTeX-rendered transparent PNG equation assets under `outputs/019e1550-e5c6-7bf3-9d1f-f651906db94b/presentations/presentation2024-latex/equations/`.
- Updated the equation placement helper to size equation images from their PNG dimensions, so formulas stay left-aligned instead of being centered inside oversized image boxes.
- Replaced math-mode `\textbullet` usage with `\bullet` to avoid incorrect glyph rendering in the exported deck.

## Verification

- LaTeX equation compilation completed for all 48 equation assets.
- `unzip -t talk/presentation2024-latex-rebuild.pptx` reported no compressed-data errors.
- Keynote imported the PPTX and returned 21 slides.
- Keynote exported `outputs/019e1550-e5c6-7bf3-9d1f-f651906db94b/presentations/presentation2024-latex/qa/presentation2024-keynote-export.pdf`; ImageMagick identified pages 0-20 for both the source PDF and exported PDF.
- Rendered contact sheet: `outputs/019e1550-e5c6-7bf3-9d1f-f651906db94b/presentations/presentation2024-latex/qa/keynote-export-contact.png`.
- Full-size spot checks were rendered for formula-heavy slides 3, 13, and 16 after fixing title overlap, incorrect bullet glyphs, and image-box centering.

## Non-editable Assets

- Displayed equations, proposition statements, and corollary formulas are LaTeX-rendered PNG assets; edit the LaTeX IDs in `talk/render_equation_assets.mjs` and regenerate the deck.
- Plot panels are embedded image assets, including crops from `talk/presentation2024.pdf` on slides 2, 5, 7, 9, 10, and 17.
- Simulation panels from `output/sim5_*` are embedded on slides 18 and 19.

## Automation Notes

- Running the deck builder inside the sandbox generates the PPTX and previews, but the internal Keynote import step can fail with `Can't get application "Keynote" (-1728)`.
- The same generated AppleScript succeeds when run through approved external `/usr/bin/osascript` GUI automation; that path was used for the final import and validation export.
