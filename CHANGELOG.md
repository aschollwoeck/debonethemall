# Changelog

Human-readable, per milestone. Format loosely follows [Keep a Changelog](https://keepachangelog.com).

## [Unreleased]

### Added
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
