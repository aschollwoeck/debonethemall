# Art Direction

The durable visual reference — what *Debone Them All* looks like — the way the [`GDD.md`](./GDD.md)
is the reference for how it plays. When a visual choice is unclear, it should be answerable from
here. Grounded in the **v2 mockup** (the agreed target):
<https://claude.ai/code/artifact/37393ad4-be89-4e2c-b068-c09c19e5d73d>

> **Direction revised (2026-07) → mixed resolution.** M2 shipped a single low-res, big-pixel
> look; playtesting rejected it. The new target (mockup:
> <https://claude.ai/code/artifact/49367d6d-6c9d-4228-b08b-8248a68a216c>) is **finer-pixel-art
> units on smooth, painted backgrounds, with a clean vector UI** and a **necromantic-sigil skill
> tree**. The **Restyle** milestone ([`M2b-restyle.md`](./M2b-restyle.md)) rebuilds the rendering
> to this. The M2 work below (composition, palette, lighting logic, props, tone) carries; the
> *rendering approach* is superseded by §0.

---

## 0. Rendering — mixed resolution (the defining choice)
Two layers, deliberately different resolutions:
- **Units are pixel art** — minions, enemies, projectiles. Drawn at a *fine* pixel grid
  (~30–48 px tall, roughly 4× the density of the old build), crisp (nearest-filtered), with real
  per-unit detail. This is where the handcrafted grit lives.
- **Everything else is smooth** — backgrounds, lighting, the phylactery, fog, and the whole UI
  are rendered at native/high resolution with **no visible pixels** (soft gradients, glows,
  painted silhouettes). Menus and the skill tree can be as ornate as we like — they aren't
  fighting a pixel grid.

The contrast (crisp creatures on a soft world) *is* the look. The game no longer renders as one
uniform 480×270 pixel grid — the 480×270 base is now just a logical coordinate space, rasterized
smooth at native resolution — and units are the only pixelated layer.

## 1. One-line vision
**Crazy-dark pixel fantasy, Terraria-detailed.** Oppressive black, swallowed by one eerie light,
strewn with macabre absurdity. Grim first; the humor grins underneath.

## 2. Tone
- **Dark, not cute.** The comedy is *macabre* — pyramids of grinning skulls, a corpse swinging in
  a gibbet, heads on pikes. Absurd cruelty played straight.
- **Grim-with-a-grin.** Skeletons debone with slapstick (a skull pops loose, keeps grinning), but
  the world around them is genuinely bleak.
- **Reference:** Terraria — for *detail density, layered depth, and dynamic colored lighting*, not
  its side-scroll format.

## 3. Palette
Near-black cold ground; **one eerie glow** carries every scene. The accent is per-act (see §4).

| Token | Hex | Use |
|---|---|---|
| **Void** | `#070510` | deepest ground, vignette |
| **Crypt** | `#1a1528` | panels, mid-dark masses |
| **Cold Stone** | `#3b3946` | path, stone, structures |
| **Bone** | `#ece3cb` | sprite highlights, display type |
| **Necrotic** | `#63e39a` | **default accent** — glow, phylactery, runes |
| **Witchfire** | `#b370ff` | **alt accent** — later acts (see §4) |
| **Torch Ember** | `#e8a24a` | warm secondary light (torches, dust) |
| **Bloodmark** | `#c8434a` | danger / low-life / gore accents |

Neutrals are violet-biased, never pure grey. Bone is warm; the darks are cold — the contrast is
the mood.

## 4. The eerie glow (accent) is per-act
Each act re-tints its signature light while bone/stone/enemies stay neutral, so the same world
reads as a new place:
- **Act I–II — Necrotic green** (`#63e39a`) — the necromancer's default.
- **Later acts — Witchfire purple** (`#b370ff`) — e.g. the holy-land invasion.
- Implemented as a single accent variable driving phylactery, runes, minion/enemy glows, and the
  additive lighting pass (in the mockup, the live toggle demonstrates it).

## 5. Lighting — darkness is the material
The single biggest lever from "blocks on grey" to "a place":
- **Every scene has one light source** — the phylactery, a guttering torch, a sick moon.
- **Colored light pools** on the ground and **blooms** around glowing things (additive pass).
- **Heavy vignette** crushes the edges; the dark is oppressive on purpose.
- Torches **flicker**; the phylactery **pulses**; embers rise; necrotic motes drift.

## 6. Sprites — fine pixel art, bone-white weight
- **Pixel art** (nearest-filtered), the only pixelated layer — see §0.
- **Fine grid:** ~30–48 px tall per figure (≈4× the old build's density), so there's room for real
  detail — a proper skull with sockets, a ribcage, a bone bow — not just a suggestive silhouette.
- **Shaded:** multiple bone shades + a dark outline, read bone-white against the smooth dark world.
- **A soft cast shadow** under every unit — grounds the crisp sprite on the soft ground.
- **Silhouette-first** still holds at gameplay scale, now with detail on top.
- **Debone stages** (HP-threshold, GDD §6) are macabre slapstick: intact → a part pops off (skull
  still grinning) → collapse to a bone pile. Each enemy debones in its own way.

## 7. Enemy visual language
So every enemy (existing and future) stays consistent:
- **Silhouette-first, bone-white on dark**, same 3-shade + outline rule as minions.
- **Faction reads by palette/material,** not just shape:
  - *Undead* (skeletons, dogs) — bone-white, cracked, cold.
  - *Ethereal* (wraiths) — translucent, glowing in the act accent, no hard outline.
  - *Holy army* (later acts) — bright metal + gold + radiant white, the tonal opposite of the
    undead; unsettling *because* it's clean.
- **Debone/death is characterful** and matches the enemy's identity (grunt loses its skull; dog
  splits; wraith fades; armored knight sheds plate first).
- **Bosses** are the same language at 2–3× scale with an extra light source of their own.

*Current roster to re-art in the overhaul:* Skeleton Grunt (Bone), Skeletal Dog (Unarmored),
Wraith (Ethereal). New enemies are designed with their content (M3+).

## 8. Depth by layers
Back → front, with parallax and haze:
1. **Sky** — cold gradient, a sick moon, faint stars.
2. **Far silhouettes** — crypt spires / broken cathedrals, near-black with a thin moonlit rim.
3. **Fog band** — a drifting translucent haze that separates far from mid.
4. **Mid set-dressing** — tilted gravestones, dead trees, broken iron fence, the macabre props.
5. **The road** — a smoothly-lit cold-stone band with rune glimmers (the glimmer from the lighting pass).
6. **Foreground** — your minions on bone-ringed plots; a dark near-silhouette lip for depth.

## 9. Macabre set dressing (the "crazy")
A shared kit, used sparingly so it stays unsettling: **skull pyramids, gibbet cages with slumped
skeletons, heads on pikes, one-eyed ravens, bloodmarks on stone, dead trees, broken fences.**
Dark humor through set design, not gags.

## 10. HUD & menus — vector, smooth *(restyle target)*
Smooth (no pixels), clean **vector** treatment — flat dark panels with a **thin necrotic hairline
border**, minimal texture, high contrast against the pixel units:
- Resource readouts (Bone Dust, Wave, Harvest) in flat panels, colour-coded values.
- Minion slots + Summon Wave as flat buttons; the selected minion gets an accent outline/glow.
- **A phylactery life meter** — green→red as it fails.
- Upgrade popup and end screen as flat gothic panels.

### The skill tree — a necromantic sigil
The Hub's tree is a **radiating sigil**: a central glowing skull-core with **vein-branches**
curving outward to nodes along each route. Node states read at a glance — **owned** (accent glow),
**available** (amber pulse), **locked** (dim behind a gate). Concentric sigil rings frame it.
Smooth-rendered; connecting veins light up as a branch is unlocked. Replaces the column-of-buttons
Hub. (Thematically the GDD's "necromantic sigil / growing spine", GDD §10.)

## 11. Technical approach (Godot)
How this gets built (mixed resolution, §0). The Restyle milestone
([`M2b-restyle.md`](./M2b-restyle.md)) implements this; the notes below describe the *target*
pipeline (the sub-bullets tagged "implemented" describe the superseded M2 build kept for reference):
- **Resolution:** `canvas_items` stretch rasterizes the 480×270 logical base smooth at native
  resolution; default texture filter **Linear** so backgrounds and UI have no visible pixels.
- **Smooth world** (background, phylactery, lighting, fog): code-drawn at native res with soft
  gradients/glows/silhouettes — smooth by virtue of the higher resolution.
- **Pixel units**: each unit is drawn as pixel art into a small `Image`/`ImageTexture` (~30–48 px)
  and displayed **nearest-filtered, upscaled** (a `Sprite2D` with `texture_filter = NEAREST`, or a
  per-unit nearest draw), so only the units are pixelated. This is the one pipeline piece M2 lacked.
- **Vector UI + sigil tree** (§10): flat Control panels with a thin hairline; the skill tree is a
  code-drawn smooth sigil graph.
- **Layered background** via parallax layers / stacked `CanvasLayer`s or a prerendered scene, drawn
  back-to-front per §8.
- **Lighting** *(implemented, slice 2 — carries over, re-tuned for native res)*: a code-driven additive pass — a soft radial glow
  texture drawn per light source through an additive `CanvasItemMaterial` (`world/lighting.gd`,
  `z 5`), plus a dark radial `Vignette` overlay (`world/vignette.gd`, `z 8`), both under the HUD
  CanvasLayer. The **act accent** is one exported `Color` tinting the necrotic lights (braziers
  stay amber). (Chose this over `Light2D`/`CanvasModulate` for precise, predictable control.)
- **Atmosphere**: cheap animated shaders/particles for fog drift, embers, motes, pulse.
- **HUD**: container-based Control UI (per `architecture.md`) styled to §10.

## 12. Anti-goals
- Not cute / chibi / bright-cartoon. Not flat-shaded blobs. Not generic grey-box UI.
- Not so dark it's unreadable — the glow must always reveal the gameplay-critical shapes.
- Not gore for shock — macabre, stylized, PG-grim.

---

*Living doc. The mockup is the north star; update this as we learn what reads in-engine.*
