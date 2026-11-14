# EyeSaver

A Brave extension to enfore a simple dark mode on websites.

In OS dark mode, measure OKLab lightness `L` (0..1). Invert is `1 - L`. Backgrounds with `L > 0.65` and text with `L < 0.35` are inverted. Hue and chroma stay. Light mode is left alone.

Same `L` for the check and the flip, so 0.35 text becomes 0.65. Thresholds: `BG_L` / `FG_L` in `content.js`.

## Install

1. Open `brave://extensions`
2. Enable Developer mode
3. Load unpacked → this folder

Reload the card after edits. Developer Mode must stay on.
