# Debone Them All

A dark-fantasy, funny, pixel-art **tower defense**. You start as a reanimated slave bound to
a cruel necromancer, break your chains, and rise to overlord — **deboning** endless skeletons
along the way. Your towers are undead minions you raise; your currency is harvested bones.

- **Engine:** Godot 4 (standard / GDScript build — *not* the .NET build)
- **Platform:** Desktop (Windows / macOS / Linux)
- **Status:** M0 prototype scaffold

## Docs
- [`docs/GDD.md`](docs/GDD.md) — full game design document (the vision).
- [`docs/M0-prototype.md`](docs/M0-prototype.md) — the current milestone's buildable spec.

## Running it
1. Install **Godot 4** (standard build) from <https://godotengine.org>.
2. Open Godot, click **Import**, and select this folder's `project.godot`.
3. Press **F5** (or the ▶ play button) to run.

## Project layout
```
scenes/    Godot scenes (.tscn) — main, enemies, minions, map
scripts/   GDScript — combat/ (types & counter matrix), core/ (game state), main/
assets/    Art, audio (placeholder for now)
docs/      Design docs
```
