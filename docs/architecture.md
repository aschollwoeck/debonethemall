# Architecture

The big-picture technical map. Read this first when picking up the project. Update it as
systems are added or reshaped.

---

## Stack
- **Engine:** Godot 4.7 (standard/GDScript build), GL Compatibility renderer.
- **Rendering:** pixel-perfect 2D — base viewport 480×270, `viewport` stretch + `keep` aspect,
  Nearest texture filter. Visuals are currently **code-drawn** (`_draw()`), no art assets yet
  (see [ADR 0001](./adr/0001-code-driven-visuals.md)).

## Project layout
```
scripts/
  combat/   combat_types.gd   — CombatTypes autoload: damage/armor enums + counter matrix
  core/     game_state.gd      — GameState autoload: in-run Bone Dust economy
            phylactery.gd      — the objective enemies attack
            wave_manager.gd    — scripted wave spawning + enemy signal wiring
  enemies/  enemy.gd (base) + skeleton_grunt.gd, skeletal_dog.gd
  minions/  minion.gd (base) + bone_archer.gd, bone_mill_golem.gd, projectile.gd
  ui/       hud.gd             — code-built HUD (labels, buttons, end panel)
  main/     main.gd            — M0 orchestrator (world build, placement, win/lose)
scenes/     main/main.tscn     — entry scene (thin: just the Main node + script)
tests/unit/                    — GUT tests
addons/gut/                    — vendored test framework
docs/                          — design + technical + player docs
```

## Autoload singletons (globals)
- **`CombatTypes`** — `Damage`/`Armor` enums, the `MATRIX`, and `resolve_damage()`. The one
  place the tactical rock-paper-scissors is defined. Tune balance here.
- **`GameState`** — in-run currency (Bone Dust) with a `bone_dust_changed` signal. Run-scoped;
  resets each run. (Persistent meta state arrives in M1 as a separate `MetaState`.)

## Core patterns
- **Code-driven world:** `main.gd` builds the path, phylactery, build slots, wave manager, and
  HUD in `_ready()` rather than composing a big `.tscn`. Keeps scenes un-fragile and lets us
  verify by running.
- **`_draw()` visuals:** enemies/minions/phylactery render themselves in code. Swapping in real
  pixel art later means replacing `_draw()` bodies (or moving to `AnimatedSprite2D`), not
  rewiring logic.
- **Signals up, calls down:** enemies emit `died` / `reached_end`; the wave manager wires those
  to the economy and the phylactery. The HUD emits intent signals (`minion_selected`,
  `start_wave_pressed`); `main.gd` acts on them.
- **Group-based targeting:** enemies join the `enemies` group; minions scan it by distance and
  pick the target furthest along the path (`Enemy.get_progress()`).

## Combat flow (one hit)
`Minion._attack()` → `Projectile` (or AoE) → `Enemy.take_damage(base, type)` →
`CombatTypes.resolve_damage(base, type, armor)` → HP drop → `_update_stage()` crosses a debone
threshold (visual/behaviour change) → death (`died` → Bone Dust) or leak (`reached_end` →
phylactery damage).

## Testing entry points
- `./run_tests.sh` runs GUT headless over `tests/unit/`.
- Pure-logic autoloads (`CombatTypes`, `GameState`) are directly unit-testable; see
  `tests/unit/`.

---

*Milestone context: M0 (prototype) is complete. M1 adds `MetaState`, a Hub scene, a skill tree,
save/load, branching upgrades, and a 3rd minion/enemy — see [`M1-core-systems.md`](./M1-core-systems.md).*
