# Art Direction

The durable visual reference — what *Debone Them All* looks like — the way the [`GDD.md`](./GDD.md)
is the reference for how it plays. When a visual choice is unclear, it should be answerable from
here. Grounded in the **v2 mockup** (the agreed target):
<https://claude.ai/code/artifact/37393ad4-be89-4e2c-b068-c09c19e5d73d>

> **Everything shipped so far uses placeholder programmer-art** (ADR 0001). This doc defines the
> target; the Visual Overhaul milestone ([`M2-visual-overhaul.md`](./M2-visual-overhaul.md))
> replaces the placeholders with it.

---

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

## 6. Sprites — bone-white weight
- **Three shades + a dark outline** per figure (shadow / mid / highlight / outline), read
  bone-white against the dark ground.
- **A soft cast shadow** under every unit — grounds it, adds depth.
- **Silhouette-first:** recognizable by shape alone at gameplay scale.
- **Scale:** chunky — figures ~16–20 px tall on the 480×270 base viewport (as in the mockup).
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
5. **The path** — cobbled cold stone, cracked flagstones, mortar, moss tufts, embedded glowing runes.
6. **Foreground** — your minions on bone-ringed plots; a dark near-silhouette lip for depth.

## 9. Macabre set dressing (the "crazy")
A shared kit, used sparingly so it stays unsettling: **skull pyramids, gibbet cages with slumped
skeletons, heads on pikes, one-eyed ravens, bloodmarks on stone, dead trees, broken fences.**
Dark humor through set design, not gags.

## 10. HUD — diegetic
No generic RTS chrome. The UI is *made of the world*:
- **Bone plaques** for resource readouts (Bone Dust, Grave Bones) with small glyphs.
- **Carved-stone buttons** (minion slots, Summon Wave) with a pressed 3D lip and accent glow when active.
- **A cracked-phylactery meter** for life — green→red as it fails.
- Monospace, tabular numerals for all counters; dark gothic panels with a thin lit top edge.

## 11. Technical approach (Godot)
How this gets built (for the overhaul):
- **Layered background** via parallax layers / stacked `CanvasLayer`s or a prerendered scene, drawn
  back-to-front per §8.
- **Sprites**: keep the code-driven `_draw()` approach for now (shaded, per §6) so we can iterate
  without an asset pipeline; graduate to `Sprite2D`/`AnimatedSprite2D` if/when we commission real art.
- **Lighting** *(implemented, slice 2)*: a code-driven additive pass — a soft radial glow
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
