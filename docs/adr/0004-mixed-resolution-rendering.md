# ADR 0004 — Mixed-resolution rendering (smooth world, pixel units)

**Status:** Accepted · **Date:** 2026-07 (M2b restyle)

## Context
M2 shipped a single low-resolution look: a fixed 480×270 `viewport` stretch with global Nearest
filtering, so *everything* was uniform big pixels. Playtesting rejected it. The agreed target
(art-direction §0) is **mixed resolution**: fine pixel-art **units** on **smooth** painted
backgrounds and a clean vector UI.

## Decision
Split rendering into two resolutions:
- **World & UI — smooth at native res.** `project.godot` uses `stretch/mode = canvas_items` +
  `aspect = keep` and `default_texture_filter = Linear`. The 480×270 base is kept purely as a
  **logical coordinate system** (so existing `_draw()`/HUD/gameplay coordinates are unchanged),
  but content is rasterized at the window's real resolution — smooth, no big pixels.
- **Units — pixel art, NEAREST.** Minions/enemies/projectiles are authored as pixel art into an
  `Image` and displayed via `PixelArt.sprite()` (`scripts/util/pixel_art.gd`) as a
  `Sprite2D` with `texture_filter = NEAREST`, upscaled by an integer factor. Only this layer is
  pixelated.

## Consequences
- **+** The smooth-world half came almost for free — a stretch-mode + filter change, no coordinate
  re-basing. Units keep crisp handcrafted pixels against the soft world (the intended contrast).
- **+** Menus / the sigil skill tree can be ornate without fighting a pixel grid.
- **−** Units must go through the `PixelArt` pipeline (can't just `_draw()`, which now renders
  smooth); their re-art is M2b slices 5–6.
- **−** Intermediate states during M2b look mixed (old pixel-designed backdrop under a smooth
  filter) until each slice repaints/re-arts its layer.
- Supersedes M2's rendering approach; M2's *design* (composition, palette, lighting, props, tone)
  carries. Does not reverse [ADR 0001](./0001-code-driven-visuals.md) — visuals stay code-driven.
