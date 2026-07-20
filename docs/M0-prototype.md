# M0 — Prototype Scope ("Prove It's Fun")

> **Goal:** the smallest playable slice that proves the **core loop is fun** — placing
> raised minions on a fixed path, watching skeletons **debone** in satisfying stages, and
> feeling that **which minion counters which enemy actually matters**. Everything not needed
> to test that is out of scope.
>
> Parent vision: [`GDD.md`](./GDD.md). This doc is the buildable spec for the first milestone.

---

## The one question M0 must answer

> *Is deboning enemies satisfying, and does tower-vs-enemy choice create interesting
> decisions on a fixed path?*

If yes → the concept has legs and we build M1 (systems + meta tree). If no → we learn cheaply
and adjust before investing in content.

---

## In scope

### 1. One map, one fixed path
- A single hand-authored map with **one fixed enemy path** (spawn → phylactery).
- Valid **build tiles** beside the path where minions can be placed.
- Programmer art is fine (tiles = colored blocks). No pixel-art polish yet.

### 2. The phylactery (objective)
- A single **phylactery object** at the path's end with a **life meter**.
- Enemies that reach it deal damage to it. Life hits 0 → **run ends → simple lose screen**.
  (No meta tree / rebirth flow yet — just "you lost, retry.")

### 3. Two minions (enough to prove the counter system)
Deliberately two, chosen so the **counter matrix is felt immediately**:

| Minion | Damage type | Role | Counters |
|---|---|---|---|
| **Bone Archer** | Pierce | Cheap, fast, single-target | Great vs. soft/unarmored; **weak vs. bone** |
| **Bone-Mill Golem** | Blunt | Slow, short range, AoE | **Strong vs. bone**; mediocre vs. soft |

- Each has a **stat block** (damage, type, rate, range, cost) per Combat Model (GDD §8).
- **One upgrade tier each** (prove the in-run upgrade beat) — no full branch trees yet.
- Place/upgrade with **in-run currency only** (working name **Bone Dust**).

### 4. Two enemies (to make the counter matter)
| Enemy | Armor type | Debone stages (HP thresholds) | Point |
|---|---|---|---|
| **Skeleton grunt** | Bone | intact → skull-off crawler → collapse | Punishes an archers-only build; wants Blunt |
| **Skeletal dog** | Unarmored (soft, fast) | intact → split halves sliding → gone | Punishes a golem-only build; wants Pierce |

- **HP-threshold debone stages (GDD §6)** implemented — even as crude sprite/shape swaps.
  This *is* the satisfaction we're testing, so it must feel good, not necessarily look good.

### 5. Waves & economy
- A **fixed, hand-scripted sequence of ~5 waves**, escalating, mixing grunts and dogs so the
  player must field **both** minion types to survive.
- Kills grant **Bone Dust**; spend between/among waves on placement + the one upgrade.
- **Survive all waves → simple win screen.** That's the M0 "success."

### 6. Minimal HUD
- Bone Dust counter, phylactery life, current/next wave, a start-wave button, minion
  place/upgrade UI. Function over form.

---

## Explicitly OUT of scope for M0
Parked for M1+ so we don't over-build before proving fun:
- Meta skill tree, multiple/act-gated currencies, rebirth-on-death flow, success multiplier.
- Route commitment / tower unlocking (all M0 minions available from the start).
- Branching upgrade paths (only one flat upgrade tier per minion).
- Bosses / minibosses / phase-shifts.
- Story, dialogue, protagonist voice.
- Multiple acts / maps.
- Save/load, audio, real pixel art, menus beyond win/lose.

---

## Success criteria (how we judge M0)
- [ ] The core loop runs end to end: place → wave → debone → earn → upgrade → survive/lose.
- [ ] **Deboning reads as satisfying** in playtest (even with placeholder art).
- [ ] **An archers-only or golem-only build visibly struggles** — the counter matters.
- [ ] A mixed, well-placed build clears all 5 waves; a careless one loses the phylactery.
- [ ] It's fun enough that we *want* to keep playing / keep building.

---

## Build task outline (rough order)
1. [x] **Godot 4 project setup** — structure, pixel-perfect 2D, `.gitignore`, autoloads.
2. [x] **Map + path** — waypoint path + build-slot placement (code-driven in `main.gd`).
3. [x] **Enemy system** — `enemy.gd` base: HP, armor type, path movement, leak → phylactery.
4. [x] **Debone stages** — HP-threshold state machine; grunt (3 stages) & dog (2 stages).
5. [x] **Minion system** — `minion.gd` base + Bone Archer (Pierce bolt) & Bone-Mill Golem (Blunt AoE).
6. [x] **Counter math** — `combat_types.gd` damage×armor matrix applied on every hit.
7. [x] **Economy + placement UI** — Bone Dust (`game_state.gd`), click-to-place/upgrade slots.
8. [x] **Wave manager** — `wave_manager.gd`, scripted 5-wave sequence with spawn scheduling.
9. [x] **Win/lose + HUD** — `hud.gd`: life/wave/currency readouts, end panel + "Rise Again".
10. [ ] **Playtest pass** — tune numbers until the success criteria are met. ← *next, needs you*

> **Status:** all systems implemented and verified (clean boot + headless run through all 5
> waves, no errors; visuals confirmed via screenshot). Ready for a hands-on playtest.

---

*When M0's success criteria are met, promote learnings back into `GDD.md` and scope M1.*
