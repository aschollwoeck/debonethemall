# M2b — Art Restyle ("Fine pixels, smooth world")

> **Goal:** rebuild the rendering to the revised direction — **finer-pixel-art units on smooth,
> painted backgrounds, a clean vector UI, and a necromantic-sigil skill tree**. M2 shipped a
> single low-res big-pixel look that playtesting rejected; this replaces the *rendering approach*
> while keeping M2's design work (composition, palette, lighting logic, props, tone).
>
> Reference: [`art-direction.md`](./art-direction.md) §0/§6/§10 + the mockup
> (<https://claude.ai/code/artifact/49367d6d-6c9d-4228-b08b-8248a68a216c>).

---

## The one question M2b must answer
> *Do the crisp pixel units read as handcrafted against a smooth, atmospheric world — and does the
> UI/sigil feel clean and ornate rather than blocky?*

Locked with the user: pixel density **as in the mockup**; **Vector** UI (flat, thin necrotic
hairline); sigil layout **as in the mockup**; background smoothness **as in the mockup**.

---

## The core change
Today everything renders in a fixed **480×270** viewport with global **nearest** filtering → one
uniform big-pixel look. M2b splits that into two layers (art-direction §0):
- **Native/high resolution** with **Linear** (smooth) default filtering — backgrounds, lighting,
  phylactery, fog, and all UI become smooth.
- **Pixel units** — minions/enemies/projectiles drawn as pixel art at a fine grid and shown
  **nearest-filtered, upscaled**, so they stay crisp pixels on the smooth world.

Because coordinates change (480×270 → native), the existing `_draw()` world/HUD code is re-based,
not reused verbatim.

## In scope — built in slices (each its own PR)
1. **Rendering foundation** — switch `project.godot` to native resolution + Linear filter; a
   reusable **pixel-unit pipeline** (draw pixel art → `ImageTexture` → nearest-filtered `Sprite2D`,
   or a nearest per-unit draw helper); confirm the world still lays out (path, slots, waypoints
   rescaled). Gameplay/logic unchanged.
2. **Smooth backdrop** — repaint the graveyard at native res: soft gradient sky + glowing moon,
   blurred spire silhouettes, misty ground, a smooth-lit road with rune glimmers, painted
   gravestones/props (the macabre kit, smooth). Replaces the pixel `Backdrop`.
3. **Lighting & atmosphere** — re-tune the additive glow + vignette for native res (carries from
   M2 slice 2; keep the per-act accent hook). Fog/embers/motes smooth.
4. **Phylactery** — smooth faceted crystal + big glow (per mockup), life-driven green→red + cracks.
5. **Minions (pixel)** — finer pixel-art Bone Archer / Bone-Mill Golem / Bound Wraith via the new
   pipeline, on soft plots with cast shadows; keep tier pips + range indicator.
6. **Enemies (pixel)** — finer pixel-art Skeleton Grunt / Skeletal Dog / Wraith + their debone
   stages (incl. the skull-pop gag), via the pipeline.
7. **Vector HUD** — restyle the in-run HUD to the flat vector treatment (thin necrotic hairline,
   flat panels), smooth. Preserve `hud.gd` public API.
8. **Sigil skill tree** — rebuild the Hub's tree as the radiating necromantic sigil (central
   skull-core, vein-branches, node states, connecting veins that light on unlock). Smooth-rendered.

## Explicitly OUT of scope
- New gameplay, minions, enemies, maps, story, balance (that's M3 / a tuning pass).
- Commissioned external pixel-art assets — units stay **code-drawn** into images (art-direction §11).
- Audio.

## Success criteria
- [ ] Units are crisp fine-pixel art; everything else (bg, phylactery, lighting, UI, sigil) is smooth — no big-pixel blockiness anywhere but the units.
- [ ] Vector UI + the sigil tree match the mockup's feel; sigil node states read at a glance.
- [ ] Per-act accent hook still works (green → witchfire purple with one value).
- [ ] Runs smoothly at native res; full test suite green; no gameplay/logic regression.
- [ ] Side-by-side, the running game reads like the restyle mockup.

## Technical notes (Godot)
- **Resolution/filter:** `project.godot` → higher base (e.g. 1280×720) or native window size,
  `stretch/mode = canvas_items` + `aspect = expand/keep`, `default_texture_filter = Linear`.
- **Pixel-unit helper:** render a unit's pixel art once into an `Image` → `ImageTexture`, set the
  displaying node's `texture_filter = TEXTURE_FILTER_NEAREST`, scale up. Cache per unit type.
- **Smooth code-draw:** at native res, `_draw()` gradients/arcs are smooth; use `draw_*` with
  antialiasing where useful. Backdrop can prerender static layers to a texture for perf.
- Verify **every slice with a screenshot** — the pixel/smooth split is entirely visual.

## Build order & PRs
Foundation first (slice 1), then world → phylactery → units → UI → sigil. Feature branch + PR per
slice, self-reviewed by the agents + a screenshot each. Doc reviewers run when docs are touched.

---

*When M2b's criteria are met, the game matches the restyle mockup. Next: M3 (Act I content), built
in this style.*
