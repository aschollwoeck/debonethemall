# Changelog

Human-readable, per milestone. Format loosely follows [Keep a Changelog](https://keepachangelog.com).

## [Unreleased]

### Changed
- **M2b · Restyle, slice 8 (necromantic-sigil skill tree)** — rebuilt the Hub's skill tree from a
  column-of-buttons into a custom-drawn **radiating sigil** (art-direction §10): a central glowing
  skull-core with **vein-branches** radiating to the route nodes along five spokes, framed by
  concentric sigil rings. Each node is a compact **rectangular card** showing its cost (or a green
  gem when owned); states read at a glance — **owned** (accent glow), **available** (amber),
  **locked** (dim behind its gate), **reachable-but-unaffordable** (amber dim) — and a branch's
  veins **light up** as it's unlocked. Hovering a card shows an info-card (name / status /
  description); clicking an available card buys it. Purchasing, routing, currency and the
  `SkillTree` data are unchanged. **Completes the M2b restyle** — the mixed-resolution look (fine
  pixel units on a smooth painted world, vector UI, sigil tree) is fully in place.
- **M2b · Restyle, slice 7 (vector HUD)** — restyled the in-run HUD from the carved bone/stone
  diegetic look to a clean **vector** treatment (art-direction §10): flat dark panels with a thin
  **necrotic hairline** border, near-square corners and minimal shadow, high contrast against the
  pixel units. Passive readouts (Bone Dust / Wave / Harvest) carry a faint neutral hairline;
  interactive elements the accent hairline — the **selected minion** and primary "Summon Wave" get
  an accent outline + soft glow. Phylactery life meter, upgrade popup and end screen reframed to
  match. Style-only — layout, logic and the Main-facing API are unchanged.
- **M2b · Restyle, slice 6 (enemies as fine pixel art)** — the three enemies and all their **debone
  stages** are now fine pixel art (art-direction §0/§6/§7), the only pixelated layer on the smooth
  world. The base `Enemy` blits the current stage's texture NEAREST-filtered over a soft (smooth)
  cast shadow, with a **white-flash overlay** when hit (via a new `PixelArt.white_mask`, +tests).
  **Skeleton Grunt** (marching skeleton → skull-off crawler with its skull grinning behind it →
  bone pile), **Skeletal Dog** (running hound → split halves), **Wraith** (translucent hooded
  shroud → tattered → fading wisp; floats, so it overrides shadow opacity + hover height). Debone
  thresholds / speed / rewards unchanged.
- **M2b · Restyle, slice 5 (minions as fine pixel art)** — the three minions are now authored as
  **fine pixel art** via the `PixelArt` pipeline (NEAREST-filtered, ~2× the old build's linear
  density) — the only pixelated layer on the smooth world (art-direction §0/§6). **Bone Archer**
  (bone-white skeleton with a skull, ribcage, back-quiver and a drawn bone bow), **Bone-Mill Golem**
  (hunched stone grinder with a bone-tooth maw and necrotic eyes/cracks), **Bound Wraith**
  (translucent hooded shroud, face-hollow, bound soul orb, binding chains). Their soft plot/shadow,
  range ring and tier pips stay smooth. Added a `PixelArt.line()` Bresenham helper (+ tests) for
  diagonals. The grind shockwave stays a smooth overlay.
- **M2b · Restyle, slice 4 (smooth phylactery)** — repainted the phylactery for the native-res
  world: a larger faceted crystal (seated in the socket) with a soft emissive aura and antialiased
  facet outline / cracks, on a smoother dais whose pixel rune-ticks became smooth accent rune-glyphs
  and a faint rune-etched ring, with the crystal's light catching the surrounding stone. Its
  life-driven behaviour is unchanged — necrotic green → blood-red and progressive fractures as life
  falls.
- **M2b · Restyle, slice 3 (lighting re-tune)** — re-tuned the additive lighting for the smooth
  native-res world: a soft moonlight pool under the backdrop's moon, a softer/wider phylactery
  bleed, warmer/larger brazier pools, and brighter road-rune glimmers. Per-act accent hook and
  vignette unchanged.
- **M2b · Restyle, slice 2 (smooth backdrop)** — repainted the graveyard backdrop smooth/painterly
  for the native-res renderer: gradient sky + a soft glowing moon, hazy crypt-spire silhouettes, a
  smoothly-lit stone road (no more pixel cobbles), soft painted gravestones / skull-piles /
  summoning-circle / braziers, and drifting mist. Replaces the pixel-designed `Backdrop`;
  light-source anchors preserved for the lighting pass (fog/mist still drawn here).
- **M2b · Restyle, slice 1 (rendering foundation)** — switched the game from a fixed 480×270
  `viewport` stretch (uniform big pixels) to `canvas_items` stretch + **Linear** filter, so the
  world and UI now render **smooth at native resolution** while keeping the 480×270 logical
  coordinate space (no gameplay changes). Added the **`PixelArt`** pipeline
  (`scripts/util/pixel_art.gd`) — author pixel art into an `Image` → NEAREST-filtered upscaled
  `Sprite2D` — so units stay crisp pixels on the smooth world (art-direction §0, [ADR 0004]). Units
  and backdrop still use the old draw and look intermediate until later M2b slices re-art them.
- **M2 · Visual overhaul, slice 1 (backdrop & tileset)** — replaced the flat grey field + brown
  polyline with a layered `Backdrop`: a horizon strip (cold sky, sick moon, crypt-spire
  silhouettes) over a top-down dark graveyard field with drifting ground fog, and a cobbled
  path with glowing rune-stones. Draws behind gameplay (`z_index -10`). First step toward the
  `docs/art-direction.md` target; lighting and re-arted sprites follow in later slices.
- **M2 · Visual overhaul, slice 1b (atmosphere)** — kept the top-down camera (over a horizon
  composition) and enriched the field: varied ground (soft blotches, cracks, moss clumps,
  gravel) and a macabre set-dressing scatter — gravestones, dead trees, skull piles, staked
  skulls, a necrotic summoning circle, braziers, blood pools, loose bones, a broken fence —
  placed clear of the path and build slots. Their glow blooms in the lighting slice.
- **M2 · Visual overhaul, slice 2 (lighting & atmosphere)** — an additive `Lighting` pass draws
  glow pools over the world (phylactery, braziers, summoning circle, rune-stones) + drifting
  necrotic motes from a procedural glow texture, and a `Vignette` crushes the edges into
  oppressive dark. The lighting's `accent` is the **per-act signature glow** — green now, one
  value swaps a later act to witchfire purple. Turns the dark field into a lit, oppressive place.
- **M2 · Visual overhaul, slice 3 (phylactery)** — re-arted the phylactery from a flat diamond
  into a faceted crystal on a rune-etched stone dais (shaded facets, inner spark,
  gentle bob). It's life-driven: shifts necrotic green → blood-red and fractures (cracks
  revealed progressively) as its life falls.
- **M2 · Visual overhaul, slice 4 (minions)** — re-arted the three towers from stick-figures into
  shaded sprites, each grounded on a shared bone-ringed plot with a cast shadow: **Bone Archer**
  (skeletal archer drawing a bone bow, quiver on back), **Bone-Mill Golem** (hunched stone grinder
  with a bone-toothed maw and glowing necrotic cracks/eyes), **Bound Wraith** (chained hooded
  spectre with a dark face-hollow and soul orb). Upgrade-tier pips retained.
- **M2 · Visual overhaul, slice 5 (enemies)** — re-arted the three enemies and their **debone
  stages** into shaded sprites with cast shadows: **Skeleton Grunt** (marching skeleton →
  headless crawler with its popped-off skull grinning behind it → bone pile), **Skeletal Dog**
  (running hound → two sliding halves), **Wraith** (hooded ghost → tattered → fading wisp). The
  macabre debone slapstick (GDD §6, art-direction §7) now reads.
- **M2 · Visual overhaul, slice 6 (diegetic HUD)** — restyled the in-run HUD to be *made of the
  world* (art-direction §10): carved bone/stone plaques for the Bone Dust / Wave / Harvest
  readouts, a **green→red phylactery life meter**, carved-stone buttons with an accent glow when
  active, and gothic bone-framed panels for the upgrade popup and end screen. Public API
  unchanged. **Completes the M2 visual overhaul** — no placeholder programmer-art remains in a run.

### Added
- **M3 · Act I, slice 8 (act completion & integration)** — **completes M3**: beating The Master ends
  **Act I** with a distinct victory screen ("ACT I COMPLETE — The crypt is yours") and a one-time
  act-clear reward (a flat Grave Bones bonus on top of the ×1.5 harvest); the Hub reflects the win
  ("Act I — Complete. The Master is bones; Act II stirs..."). Per-level clears now show a fitting
  "Crypt cleared" instead of the old Act III placeholder line. Added `Levels.act1_complete()` and a
  validation test sweeping every map's wave data. A first **difficulty / no-soft-lock pass**: a
  headless auto-play confirmed every map (incl. the necromancer/boss summon loops) resolves and is
  winnable with no hang — fine-grained balance remains a playtest task (GDD).
- **M3 · Act I, slice 7 (The Master — Act I boss)** — the end-of-act setpiece (GDD §6): your cruel
  necromancer, a ~2× crowned necromancer-lord with three **HP-threshold phases** (reusing the
  debone-stage tech): he **summons the dead** throughout, escalates to raising **Armored Knights**
  at the second phase, and in his final phase **strikes the phylactery directly** across the field.
  Carries his own **necrotic aura** (his light source) with a raise/strike pulse. BONE armor; a
  near-fatal leak if he reaches the phylactery in person. Fine pixel art per phase (commanding lord
  → enraged, torn, aflame → unravelling husk pouring green). Added as the boss map's final wave
  (he summons his own adds); clearing him plays the story turn — you break your chains. Tests for
  the boss stats, the summon cadence, and the final-phase phylactery strike.
- **M3 · Act I, slice 6 (the five crypt maps)** — replaced the placeholder single-path/scaled-wave
  levels with **five distinct hand-authored maps**, each its own path, build slots and wave
  composition: **The Crypt Approach** (zigzag), **The Ossuary** (big Z), **The Flooded Vault**
  (inward spiral), **The Reliquary** (top-entry wind), **The Master's Gate** (comb), and the boss
  **gauntlet** (border → central arena). The roster is introduced gradually so each map teaches a
  counter — grunts/dogs (L1–2) → **Skeleton Mage** (L3) → **Armored Knight** + first **Wraiths**
  (L4) → **Raised Necromancer** + full roster (L5) → pre-boss gauntlet. Wraith/Knight waves land
  once the player has had a chance to farm the sigil for Bound Wraith / the Golem (GDD §10). Wave
  sizes are a first pass (tuned in slice 8); the Master boss enemy arrives in slice 7.
- **M3 · Act I, slice 5 (Raised Necromancer miniboss)** — an Act I **miniboss** (GDD §6): elite and
  slow, it periodically **raises a fresh skeleton into the wave** (a green raise-pulse ripples from
  the ground) — so unless you burst it down the wave never ends ("kill it fast or drown"),
  pressuring low single-target DPS. BONE armor (the Golem's Blunt is the fast answer). Fine pixel
  art (crowned robed summoner with raised glowing hands → cracked, guttering husk). Enemies gained a
  `reinforcement_requested` signal; the WaveManager spawns and **tracks** raised reinforcements (only
  while a wave is active), so the wave can't clear until they're dealt with. Seeded into Act I's
  later waves (placeholder until slice 6). **Completes the Act I enemy roster.** Tests for the
  miniboss stats, the raise cadence, and the WaveManager's active-only reinforcement spawning.
- **M3 · Act I, slice 4 (Armored Knight)** — a tanky enemy (GDD §6) with a **mechanical debone**:
  its **plate shatters off** at the first HP threshold — armor **HEAVY → BONE** and its **speed
  jumps** (a slow tank becomes a fast exposed skeleton) — then it collapses to a bone pile. HEAVY
  resists Pierce and Holy, so crack the plate with the Golem's Blunt (or Fire), then finish the
  quick runner; reaching the phylactery in plate hurts more (double leak). Fine pixel art per stage
  (iron knight w/ red visor & shield → lunging bare skeleton shedding shards → bone heap under a
  dented helm). Introduced into Act I's later waves alongside the mage (placeholder until slice 6).
  A generic `_append` wave helper replaces the mage-only one. Tests for the armor-strip transition,
  the Pierce-resist, and the speed jump.
- **M3 · Act I, slice 3 (Skeleton Mage)** — a new enemy (GDD §6): a **ranged caster** (BONE armor)
  that, instead of marching to leak, **halts once within range of the phylactery and lobs necrotic
  bolts at it** on a cadence — so it threatens from afar and must be killed before it sets up
  (weak to the Golem's Blunt, resists the Archer's Pierce). Fine pixel art with its signature
  fire-death stages (robed caster with a glowing staff → flailing, engulfed in flame → ash pile),
  plus a necrotic charge-flare while casting. Enemies now carry a `target_phylactery` reference
  (set by the WaveManager) for ranged attackers; the mage is introduced into Act I's later waves
  (placeholder comps until slice 6). Tests for its armor and the halt-and-cast vs. advance mechanic.
- **M3 · Act I, slice 2 (dialogue cards)** — between-level story (docs/M3-act-one.md): a flat
  vector **`DialogueCard`** overlay plays a sequence of beats — the Master's cruel taunts
  (bloodmark) vs. your slave's simmering inner voice (necrotic) — dimming the scene and advancing
  on click / Continue. Each `Level` now carries `intro`/`outro` beats (written in one place in the
  `Levels` registry, escalating slave→overlord across Act I toward the turn on the boss); the run
  plays a level's intro on entry and its outro on a clear (before the end screen). Tests for the
  card sequencing and that levels carry beats.
- **M3 · Act I, slice 1 (level framework)** — made maps data-driven ahead of Act I content
  (docs/M3-act-one.md). A new **`Level`** holds a map's path / build slots / wave schedule; a
  **`Levels`** registry lists Act I's ordered maps (Level 1 is the real prototype map; Levels 2–5
  and the boss are placeholders — same path, escalating waves — filled in later slices). `main.gd`
  and `WaveManager` now **consume a level** (via a `RunContext` hand-off) instead of hardcoding it.
  **`MetaState`** tracks cleared levels (persisted); the Hub replaces "Begin Run" with an **Act I
  level bar** — cleared (accent) / next-to-play (amber) / locked (dim) chips you click to descend,
  clearing one unlocks the next and cleared maps stay replayable for farming. Tests for the
  registry, unlock gating, and progress save/load.
- **M1 · Branching upgrades & difficulty pass** — each minion now upgrades along one of two
  branches (Archer: Volley/Piercer · Golem: Wider Grind/Bone Crusher · Wraith: Reaper/Warden),
  chosen via a HUD popup; a second tier deepens the branch. Minion attacks flow through
  `_fire(target_list)` to support multi-target (Volley). Enemy HP raised as a first-pass
  difficulty bump so counters matter (final balance is a playtest task). Tests for branch
  progression, per-tier costs, and branch-locking.
- **M1 · Bound Wraith, Wraith enemy & unlock gating** — a third minion (**Bound Wraith**,
  Necrotic) and enemy (**Wraith**, Ethereal) whose armor resists all physical, so it *demands*
  Necrotic (matrix tweaked: Pierce vs Ethereal → 0.5, so all physical is ×0.5). Minion-unlock **gating** is now
  enforced — a run offers only the minions the tree has unlocked (start: Bone Archer only),
  via a `MINION_REGISTRY` and a dynamic HUD. Wraiths appear in later waves. Tests for the
  Ethereal counter rule and new minion/enemy stats.
- **M1 · Run loop closed** — runs now harvest Grave Bones from kills (HUD readout), banked to
  `MetaState` on run-end (kept on loss, ×1.5 on a clear) with autosave, and the skill tree's
  `RunModifiers` (phylactery life, starting Bone Dust, minion damage) apply at run start. The
  end screen shows the banked harvest and routes back to the Crypt. Unit tests for harvest
  accrual; loop verified via headless playthrough.
- **M1 · Hub ("The Crypt")** — new entry scene with a container-based skill-tree UI (buy nodes
  → spend Grave Bones → autosave) and **Begin Run**. Scene routing Hub → run → Hub (the run's
  end screen now offers **Return to Crypt** instead of an in-place retry).
- **M1 · Skill tree** — data-driven `SkillTree` autoload: 10 node definitions (minion unlocks +
  global buffs) with costs/prereqs, purchase gating via `MetaState`, and `RunModifiers`
  aggregation applied at run start. Unit tests cover data integrity, purchase gating, and
  effect aggregation.
- **M1 · MetaState** — persistent `MetaState` autoload: Grave Bones currency, unlocked-node
  set, and save/load to `user://save.json` (with a success multiplier on run clears). Unit
  tests cover currency ops, harvest banking, unlocks, and save/load round-trips.
- **Engineering foundation:** GUT test framework (`addons/gut/`), first unit tests for the
  counter matrix and economy, `./run_tests.sh` runner.
- **Docs:** development workflow, architecture overview, player-facing mechanics reference,
  Architecture Decision Records (ADRs), this changelog.
- **M1 spec** — `docs/M1-core-systems.md` (the persistent meta loop).

## [M0] — Prototype ("prove it's fun")

### Added
- Godot 4 project: pixel-perfect 2D config, `CombatTypes` + `GameState` autoloads.
- Fixed-path tower defense with a phylactery objective.
- Two minions — **Bone Archer** (Pierce, single-target bolts) and **Bone-Mill Golem**
  (Blunt, AoE grind).
- Two enemies — **Skeleton Grunt** (Bone) and **Skeletal Dog** (Unarmored) — with
  HP-threshold **debone** stages.
- Damage-type × armor-type **counter matrix**.
- Bone Dust economy, click-to-place/upgrade build slots, 5-wave sequence, win/lose, HUD.

### Fixed
- HUD controls were invisible due to mixing anchor presets with manual `.position`; switched
  to absolute positioning for the fixed 480×270 viewport.
