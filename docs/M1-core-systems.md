# M1 — Core Systems ("The Meta Loop")

> **Goal:** turn the M0 prototype into a game with a **persistent roguelite loop**. Prove that
> harvesting currency → spending it on a skill tree → returning stronger makes you want another
> run. Content stays minimal; the *systems* are the deliverable.
>
> Parent vision: [`GDD.md`](./GDD.md). Prior milestone: [`M0-prototype.md`](./M0-prototype.md).

---

## The one question M1 must answer

> *Does the meta loop feel rewarding — do I fail a run, spend my Grave Bones, and immediately
> want to try again because I'm now stronger?*

Decided direction (from scoping):
- **Content:** systems **+ one new unlockable minion and one new enemy** that demands it.
- **Run structure:** **finite but hard.** Early runs fail; the skill tree is how you eventually
  clear the map. Every run banks currency (kept 100% on death), so failure still progresses you.

---

## In scope

### 1. Run / meta separation + Hub screen
- A **Hub screen** ("The Crypt") is the new entry point: shows the skill tree and a **Begin Run**
  button. Runs launch from here.
- Ending a run (**death or victory**) returns to the Hub — implementing the "reborn to the skill
  tree" loop (GDD §5), replacing M0's in-place retry.
- Scene restructure: Hub becomes the main scene; the current gameplay becomes the **run scene**,
  loaded/unloaded per run.

### 2. Persistent meta currency
- **Grave Bones** — the first meta currency (GDD §10; the multi-currency/cross-arc system is
  deferred). Harvested from kills during a run.
- **Kept 100% on death.** A **successful clear** applies a **success multiplier** to that run's
  harvest (GDD §5). Harvest naturally scales with how far you got (more kills = more bones), so
  partial runs still pay out.
- Distinct from the in-run **Bone Dust** (which still resets each run).

### 3. Save / load
- `user://save.json` persisting: Grave Bones balance, unlocked tree nodes, (basic) settings.
- **Autosave** on run end and on tree purchase. Load on boot.

### 4. Meta skill tree v1
- A small but **real** tree (~8–12 nodes) with prerequisites, driven by node **data** (id, cost,
  effect, prereqs) so it's easy to extend later.
- Two node kinds:
  - **Minion unlocks** — *route commitment* (GDD §7): you **start with only the Bone Archer**.
    The Golem, the Bound Wraith, and their branch-upgrade access are **tree unlocks**. Escalating
    costs mean early runs can afford only part of the roster → you specialize.
  - **Global buffs** — e.g. +phylactery max life, +starting Bone Dust, +% minion damage.
- Effects are **applied at run start** by reading the saved tree state.
- Basic tree UI (nodes, costs, locked/affordable/owned states, click-to-buy).

### 5. In-run branching upgrades
- Replace M0's single flat upgrade with a **2-branch choice** per minion (GDD §7). First upgrade
  picks a branch; a second tier deepens it.
  - **Bone Archer** → *Volley* (fires multiple bolts) **vs** *Piercer* (bolt pierces enemies in a line).
  - **Bone-Mill Golem** → *Wider Grind* (larger AoE radius) **vs** *Bone Crusher* (heavy single-pulse damage).
  - **Bound Wraith** → *Hex* (adds a slow/debuff) **vs** *Soul Siphon* (bonus Grave Bones on kills).
- Placement UI upgraded to show branch choices on a selected minion.

### 6. New content — giving the tree teeth
- **Bound Wraith** (new minion) — **Necrotic** damage type. A bound spirit flinging necrotic
  bolts; the answer to ethereal foes. Unlocked via the tree.
- **Wraith** (new enemy) — **Ethereal** armor: physical attacks pass through it (resists Pierce,
  Blunt, Fire); only **Necrotic/Holy** bites. Forces the player to unlock the Bound Wraith — a
  concrete "the tree gave me the tool I needed" moment.
- **Counter-matrix tweak (GDD §8):** lower Pierce/Fire vs Ethereal to 0.5 so the Wraith clearly
  *demands* Necrotic rather than merely preferring it.

---

## Explicitly OUT of scope for M1
- Acts / story / multiple maps (still one map). Protagonist voice.
- Bosses & minibosses.
- The *multiple* act-gated currencies + cross-arc farming (only Grave Bones for now).
- Full minion/enemy rosters beyond the three each.
- Real pixel art, audio, menus beyond Hub + run HUD.
- Respec, prestige/incremental depth.

---

## Success criteria
- [ ] Full loop runs: Hub → run → (die or clear) → back to Hub with Grave Bones banked → spend on tree → next run visibly stronger.
- [ ] Save/load survives quitting and relaunching the game.
- [ ] A fresh save (Archer only) **cannot** clear the map; unlocking the Golem and Bound Wraith via the tree makes it winnable — **the tree is felt as necessary**.
- [ ] The Wraith enemy forces unlocking Necrotic; an all-physical build visibly stalls on it.
- [ ] Branch choices produce **different-feeling** builds within a run.
- [ ] It's compelling enough to want "one more run."

---

## Build task outline (rough order)
1. **Meta data layer** — `MetaState` autoload: Grave Bones, unlocked-node set; save/load to `user://save.json`.
2. **Skill-tree data** — node definitions (id, cost, effect, prereqs) + effect application at run start.
3. **Hub scene** — tree UI, currency display, Begin Run; scene routing Hub ↔ run.
4. **Run-end flow** — win/lose → tally harvest (+ success multiplier) → bank → return to Hub.
5. **Tower unlock gating** — run reads unlocked minions; HUD only offers unlocked ones.
6. **Bound Wraith minion + Wraith enemy** — new scripts; matrix tweak for Ethereal.
7. **Branching upgrades** — per-minion 2-branch upgrade data + placement UI.
8. **Harder finite waves** — retune the 5(+?) waves so a fresh save fails and a grown tree clears.
9. **Playtest + balance** — tune currency rates, node costs, and difficulty to the success criteria.

---

## Key open questions for M1
- [ ] Grave Bones earn rate vs. node costs (how many runs to unlock the roster?).
- [ ] Exact tree shape/prereqs and node list.
- [ ] Success-multiplier value (flat vs. scaling with life remaining) — first real test of GDD §5's open TODO.
- [ ] Branch upgrade costs (in-run Bone Dust) and tier depth (1 or 2 tiers per branch).
- [ ] Does the Hub also let you inspect enemy/minion stats (a "codex")? Nice-to-have.

---

*When M1's success criteria are met, promote learnings into `GDD.md` and scope M2 (Act I content).*
