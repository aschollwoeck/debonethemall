# ADR 0001 — Code-driven visuals for prototyping

**Status:** Accepted · **Date:** 2026-07 (M0)

## Context
We need to prototype gameplay before committing to pixel art. Hand-authoring `.tscn` scenes
with placeholder sprites is fragile and slow to iterate, and we have no art assets yet.

## Decision
Render enemies, minions, projectiles, and the phylactery in code via `_draw()`, and build the
world (path, slots, HUD) in `main.gd`/`hud.gd` rather than large `.tscn` files. Keep `.tscn`
files thin (just a root node + script).

## Consequences
- **+** Fast iteration, no art dependency, everything verifiable by running headless.
- **+** Fewer fragile hand-written scene files (a real source of M0 bugs — see the anchor-preset
  HUD bug).
- **−** Not how a finished Godot game is usually structured; visuals are placeholder-crude.
- **Migration path:** swapping in real pixel art = replacing `_draw()` bodies with
  `AnimatedSprite2D`/`Sprite2D`, without touching gameplay logic.

Revisit when we introduce real art (likely M2+).
