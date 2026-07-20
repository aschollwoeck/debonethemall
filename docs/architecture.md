# Architecture

The big-picture technical map. Read this first when picking up the project. Update it as
systems are added or reshaped.

---

## Stack
- **Engine:** Godot 4.7 (standard/GDScript build), GL Compatibility renderer.
- **Rendering (mixed resolution — [ADR 0004](./adr/0004-mixed-resolution-rendering.md)):** the
  world and UI render **smooth at native resolution** — `canvas_items` stretch, `keep` aspect,
  **Linear** filter — over a 480×270 logical coordinate base (all gameplay coords stay in that
  space). **Units** are the only pixelated layer: pixel art authored into `Image`s and shown
  **NEAREST-filtered, upscaled** via `PixelArt` (`scripts/util/pixel_art.gd`). Visuals are
  **code-drawn** (`_draw()` for the smooth world/UI; `PixelArt` images for units), no external art
  assets ([ADR 0001](./adr/0001-code-driven-visuals.md)).

## Project layout
```
scripts/
  util/     pixel_art.gd      — pixel-unit pipeline: author art into an Image → NEAREST sprite
  combat/   combat_types.gd   — CombatTypes autoload: damage/armor enums + counter matrix
  core/     game_state.gd      — GameState autoload: in-run Bone Dust economy
            meta_state.gd      — MetaState autoload: persistent cross-run save (Grave Bones + unlocks)
            phylactery.gd      — the objective enemies attack
            wave_manager.gd    — scripted wave spawning + enemy signal wiring
  enemies/  enemy.gd (base) + skeleton_grunt.gd, skeletal_dog.gd, wraith.gd
  minions/  minion.gd (base) + bone_archer.gd, bone_mill_golem.gd, bound_wraith.gd, projectile.gd
  meta/     skill_tree.gd      — SkillTree autoload: node data, purchase, run-modifier aggregation
            run_modifiers.gd   — RunModifiers value object (aggregated tree effects for a run)
  world/    backdrop.gd        — layered graveyard backdrop + cobbled path (draws behind gameplay)
            lighting.gd        — additive glow pass (phylactery/braziers/runes/motes); per-act accent
            vignette.gd        — heavy edge vignette over the world, under the HUD
  ui/       hud.gd             — code-built HUD (labels, buttons, end panel, upgrade popup)
  hub/      hub.gd             — Hub ("The Crypt") screen: skill-tree UI, purchasing, Begin Run
  main/     main.gd            — run orchestrator (world build, placement, win/lose)
scenes/     hub/hub.tscn       — entry scene (the Hub)
            main/main.tscn     — the run scene (thin: just the Main node + script)
tests/unit/                    — GUT tests
addons/gut/                    — vendored test framework
docs/                          — design + technical + player docs
```

## Autoload singletons (globals)
- **`CombatTypes`** — `Damage`/`Armor` enums, the `MATRIX`, and `resolve_damage()`. The one
  place the tactical rock-paper-scissors is defined. Tune balance here.
- **`GameState`** — in-run currency (Bone Dust) with a `bone_dust_changed` signal. Run-scoped;
  resets each run.
- **`MetaState`** — **persistent** cross-run state saved to `user://save.json`: Grave Bones
  currency + the unlocked skill-tree node set. Loaded on boot; autosaved via `save_game()` on
  run-end (`main._finish_run`) and on tree purchases (the Hub). Path-injectable
  `save_to()`/`load_from()` keep tests off the real save. `bank_harvest(base, cleared)` applies
  the success multiplier on a clear.
- **`SkillTree`** — data-driven meta skill tree (GDD §7/§10). Holds node definitions (`NODES`:
  id → name/desc/cost/prereqs/effect), gates purchases via `MetaState` (`can_purchase`/`purchase`), and
  aggregates unlocked nodes into a `RunModifiers` (unlocked minions + global buffs) that a run
  reads at start via `build_run_modifiers()`. Has no UI of its own — the Hub renders it.

## Scene flow & the meta loop
`hub.tscn` (entry) → **Begin Run** → `change_scene_to_file(main.tscn)` (a run) → win/lose →
**Return to Crypt** → back to `hub.tscn`. Autoloads (`MetaState`, `SkillTree`, …) persist across
these scene changes, so meta progress carries over.

The full loop is closed:
- **Run start:** `main.gd` reads `SkillTree.build_run_modifiers()` and applies buffs —
  +phylactery max life, +starting Bone Dust, ×minion-damage (applied per minion at placement) —
  and **gates placement**: `_populate_available_minions()` offers only the tree's
  `unlocked_minions` (resolving each id through the `MINION_REGISTRY` id→script map), so a fresh
  save can place only the Bone Archer.
- **During the run:** each kill adds to `WaveManager`'s Grave Bones harvest (`harvest_changed`
  → HUD readout), alongside the in-run Bone Dust reward.
- **Run end (win or lose):** `_finish_run()` banks the harvest via `MetaState.bank_harvest()`
  (×1.5 on a clear), autosaves, and shows the banked total on the end screen.

## Minion upgrades (branching)
Each `Minion` upgrades along one of two branches (GDD §7): the first upgrade picks branch `"a"`
or `"b"` (tier 1), a second deepens it (tier 2), and the choice locks. Subclasses declare their
branches in `_branches()` (names + per-tier costs) and mutate the stat block in `_apply_branch()`;
the base class handles `upgrade_options()`, `cost_of()`, and `apply_upgrade_choice()`. Clicking a
placed minion opens the HUD branch popup (`hud.show_upgrades` → `upgrade_chosen`); `main` spends
Bone Dust and re-opens for the next tier. Attacks flow through `_fire(target_list)` so a minion
can hit multiple enemies (e.g. the Archer's *Volley* raises `targets`).

*Balance:* enemy HP was raised as a first-pass difficulty bump so the counter matrix bites;
final tuning is a playtest task.

## Visuals (M2 overhaul — complete)
Replaced the placeholder art with the crypt aesthetic (docs/art-direction.md). The
**`Backdrop`** node (`world/backdrop.gd`, `z_index = -10`) draws the atmospheric world behind
gameplay — a horizon strip (sky, sick moon, crypt spires) over a top-down dark graveyard field
(varied ground + macabre set-dressing: gravestones, skull piles, a summoning circle, braziers,
…) with drifting ground fog, plus the cobbled path with glowing rune-stones (given the enemy
path via `setup()`). Props are placed clear of the path and build slots. `main._draw()` now draws
only the build-slot markers.

The **`Lighting`** node (`world/lighting.gd`, `z 5`, additive `CanvasItemMaterial`) draws soft
glow pools over the world — phylactery, braziers, summoning circle, rune-stones — plus drifting
necrotic motes, from a procedurally-generated glow texture; its `accent` color is the **per-act
signature glow** (green default, one value → witchfire purple later). The **`Vignette`** node
(`world/vignette.gd`, `z 8`) crushes the edges to dark. Both sit under the HUD `CanvasLayer`.

The re-arted sprites (phylactery, minions, enemies + debone stages) and the **diegetic HUD**
(`ui/hud.gd` — carved bone/stone plaques, a green→red life meter, gothic panels) are in. **M2 is
complete**: no placeholder programmer-art remains in a run.

## Core patterns
- **Container UI vs. absolute UI:** the **Hub** uses Godot container nodes (`MarginContainer` /
  `VBox` / `HBox`) for auto-layout — robust against the anchor-preset-plus-manual-`.position` bug
  that once made HUD controls invisible. The in-run **HUD** uses absolute positions (safe only
  because the run viewport is a fixed 480×270). Prefer containers for any non-trivial layout.
- **Code-driven world:** `main.gd` builds the backdrop, path, phylactery, build slots, wave
  manager, and HUD in `_ready()` rather than composing a big `.tscn`. Keeps scenes un-fragile
  and lets us verify by running.
- **`_draw()` visuals:** enemies/minions/phylactery render themselves in code. Swapping in real
  pixel art later means replacing `_draw()` bodies (or moving to `AnimatedSprite2D`), not
  rewiring logic.
- **Signals up, calls down:** enemies emit `died` / `reached_end`; the wave manager wires those
  to the economy and the phylactery. The HUD emits intent signals (`minion_selected`,
  `start_wave_pressed`); `main.gd` acts on them.
- **Group-based targeting:** enemies join the `enemies` group; minions scan it by distance and
  pick the target furthest along the path (`Enemy.get_progress()`).

## Combat flow (one hit)
`Minion._fire(target_list)` → `Projectile` (or AoE) → `Enemy.take_damage(base, type)` →
`CombatTypes.resolve_damage(base, type, armor)` → HP drop → `_update_stage()` crosses a debone
threshold (visual/behaviour change) → death (`died` → Bone Dust + Grave Bones harvest) or leak
(`reached_end` → phylactery damage).

## Testing entry points
- `./run_tests.sh` runs GUT headless over `tests/unit/`.
- Pure-logic autoloads (`CombatTypes`, `GameState`, `MetaState`, `SkillTree`) are directly
  unit-testable; see `tests/unit/`.

---

*Milestone context: M0 (prototype) is complete. M1 adds `MetaState`, a Hub scene, a skill tree,
save/load, branching upgrades, and a 3rd minion/enemy — see [`M1-core-systems.md`](./M1-core-systems.md).*
