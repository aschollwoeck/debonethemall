# M2 — Visual Overhaul ("Make it look like the game")

> **Goal:** replace the placeholder programmer-art with the agreed **crazy-dark** aesthetic, so
> the real game reads like the mockup. Systems don't change; the *look* does.
>
> Reference: [`art-direction.md`](./art-direction.md) + the target mockup
> (<https://claude.ai/code/artifact/37393ad4-be89-4e2c-b068-c09c19e5d73d>).

---

## Why now
Every milestone so far ran on deliberate placeholder shapes (ADR 0001). The direction is locked
(crazy-dark, necrotic-green default / witchfire-purple later acts, chunky shaded sprites, diegetic
HUD). Building more content on blocks is demoralizing and means re-arting later — so we make the
one map we have look *right* before Act I content (M3) is built in the new style from the start.

## The one question M2 must answer
> *Does the running game read like the mockup — atmospheric, lit, macabre — while still playing
> exactly as it does now at 60 fps?*

---

## In scope — built in slices (each its own PR)
1. **Background & tileset** — layered graveyard per art-direction §8: cold sky + sick moon, far
   crypt-spire silhouettes, drifting fog band, gravestones/dead-trees/fence, and a cobbled
   cold-stone path (cracked flagstones, mortar, moss, embedded runes) replacing the flat polyline.
2. **Lighting & atmosphere pass** — additive glow + heavy vignette; the **act accent** as one
   exported color; torch flicker, phylactery pulse, embers, drifting motes. This is the slice that
   does most of the "it's a place" work.
3. **Phylactery** — the faceted necrotic crystal on a dais, casting a light pool (replaces the
   plain diamond).
4. **Minions** — re-art Bone Archer, Bone-Mill Golem, Bound Wraith to §6 (3 shades + outline, cast
   shadow, silhouette-first), on bone-ringed plots. Keep the tier pips and range indicator.
5. **Enemies** — re-art the **3 existing** enemies (Skeleton Grunt, Skeletal Dog, Wraith) to §7,
   with characterful **debone stages**. (New enemies are M3.)
6. **Diegetic HUD** — bone plaques, carved-stone buttons, cracked-phylactery life meter, gothic
   panels (art-direction §10), replacing the current flat HUD.
7. **Macabre set dressing** — the shared prop kit (skull piles, gibbet, pikes, raven, bloodmarks),
   placed tastefully around the map.

## Explicitly OUT of scope
- New enemies, minions, maps, story, bosses — that's **M3 (Act I content)**, built in this style.
- Audio, music, SFX.
- Real commissioned pixel-art assets — we stay code-driven (`_draw()`) for now; graduating to
  `Sprite2D`/`AnimatedSprite2D` is a later call (art-direction §11).
- Balance (M1 first-pass difficulty stands until a dedicated tuning pass).

## Success criteria
- [ ] The running game visibly matches the mockup's mood — layered depth, one eerie light source, oppressive dark, macabre props.
- [ ] Necrotic-green default with a working **act-accent** hook (a later act can switch to witchfire purple with one value).
- [ ] All three minions and three enemies read by **silhouette**; debone stages are legible and characterful.
- [ ] The HUD is diegetic and still fully functional (all M0/M1 controls work).
- [ ] Runs at 60 fps; no gameplay/logic regression (full test suite green).
- [ ] Placeholder `_draw()` shapes are gone from the shipped visuals.

## Technical notes (Godot)
- Prefer a **prerendered/layered background** (parallax layers or stacked draws) over redrawing
  everything per frame; animate only the cheap dynamic layer (fog, embers, glow).
- **Lighting:** `Light2D` + additive glow sprites + a vignette overlay; the act accent is one
  exported `Color`. Consider a `CanvasModulate` for global grade.
- **Sprites:** shaded `_draw()` (ramp of 3 shades + outline) per minion/enemy; a reusable shadow
  helper; debone stages swap the shape as today, just detailed.
- Verify each slice with a **screenshot** (headless render), not just tests — visuals can't be
  unit-tested (this is exactly where the M0 HUD bug hid).

## Build order & PRs
Follow the slice order above; each is a feature branch + PR, self-reviewed by the agents (the
`code-reviewer` for correctness/perf, plus a screenshot on every slice). The doc reviewers run when
`art-direction.md` / `mechanics.md` / `CHANGELOG.md` are touched.

---

*When M2's success criteria are met, promote learnings into `art-direction.md` and scope M3 (Act I
content) — built in the new style from the first sprite.*
