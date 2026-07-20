# Changelog

Human-readable, per milestone. Format loosely follows [Keep a Changelog](https://keepachangelog.com).

## [Unreleased]

### Changed
- **M2 · Visual overhaul, slice 1 (backdrop & tileset)** — replaced the flat grey field + brown
  polyline with a layered `Backdrop`: a horizon strip (cold sky, sick moon, crypt-spire
  silhouettes) over a top-down dark graveyard field with drifting ground fog, and a cobbled
  path with glowing rune-stones. Draws behind gameplay (`z_index -10`). First step toward the
  `docs/art-direction.md` target; lighting and re-arted sprites follow in later slices.

### Added
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
