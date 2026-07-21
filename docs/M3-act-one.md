# M3 — Act I: "The Slave"

> **Goal:** turn the single-map sandbox into **Act I of the villain-origin arc** — a linear run of
> **5 crypt maps → a boss**, defended by an expanded enemy roster, framed by **dialogue-card** story
> beats that escalate the slave→overlord voice. Built entirely in the restyled look ([M2b](./M2b-restyle.md)).
>
> Reference: [`GDD.md`](./GDD.md) §6 (enemies/bosses), §9 (Act I — The Slave), §10 (progression).

---

## The fantasy (Act I)
You are a lowly reanimated **slave** bound to a cruel necromancer, defending **his** crypt just to
survive. Waves of crypt-dwellers, grave-robbers and holy **inquisitors** raid the tomb; you learn
the trade in chains. The **Master** taunts you between breaches. By the act's end you turn on him.
**Tone:** grim, oppressed, darkly comic — the humor grins under the dread.

## Scope decisions (locked with the user, 2026-07)
- **Structure:** **5 maps → boss** (full-size Act I), played linearly; cleared maps are replayable
  to farm Grave Bones (GDD §10 cross-farming).
- **Story delivery:** **dialogue cards between levels** — a flat vector card (speaker + line +
  Continue) shown entering/after a map. The Master's voice + the slave's inner voice, escalating.
- **New enemies:** **Skeleton Mage** (ranged support; bursts into flames → ash on death) +
  **Armored Knight** (armor shatters off → becomes a fast grunt → debones) + **Raised Necromancer**
  (miniboss; resurrects fallen enemies mid-lane — "kill fast or drown").
- **Act I boss:** **The Master** — end-of-act setpiece; HP-threshold **phase changes** (reuses the
  debone-stage tech): sheds his guard, summons adds, and can strike the phylactery directly.

## Out of scope (later milestones)
- Acts II & III, their factions/currencies/bosses (M4+).
- Audio, final balance polish (a dedicated tuning pass), commissioned art (units stay code-drawn).
- Branching level maps / a world-map screen — Act I is **linear** (a level list/continue is enough).

---

## The core change — a level framework
Today `main.gd` hardcodes one `_path` + `_slots`, and `WaveManager` hardcodes one 5-wave array.
M3 makes this **data-driven**:
- A **`Level`** definition: `id`, display `name`, `path` (PackedVector2Array), build `slots`,
  `waves` (the group schedule now living in WaveManager), a backdrop/theme hint, and its story beats.
- A **`Levels` registry** (autoload or resource list) holding Act I's 5 maps + the boss level, in order.
- `main.gd` + `WaveManager` **consume a `Level`** (passed in on scene entry) instead of hardcoding.
- **`MetaState`** tracks Act I progress (highest level cleared) so the Hub can offer **Continue**
  (next uncleared) and **replay** of cleared maps for farming.
- The Hub's "Begin Run" becomes **Descend** into the current level (a small level list shows
  progress); the run's end screen routes back to the Hub, advancing progress on a clear.

Everything keeps working as we go: the current map becomes **Act I · Level 1**, driven by data.

## In scope — built in slices (each its own PR, self-reviewed + screenshot) — **all done**
1. **Level framework** *(done)* — `Level` data + `Levels` registry; refactor `main.gd`/`WaveManager` to
   consume a level; `MetaState` Act I progress; Hub level list + Continue/replay routing. Current
   map becomes Level 1. No new content yet — pure enabling refactor, tests for progress logic.
2. **Story: dialogue cards** *(done)* — a between-level dialogue-card UI (speaker, line, Continue), a
   data-driven per-level beat list, shown entering a level and on the act's key turns. The Master +
   slave voices; escalation hooks.
3. **Skeleton Mage** *(done)* — ranged enemy (lobs at the phylactery / debuffs from afar), fire-death
   stages (flails → bursts into flames → ash). Fine pixel art; slots into the counter matrix.
4. **Armored Knight** *(done)* — tanky; **armor-strip** stage (plate shatters off → speeds up as a fast
   grunt → debones). Fine pixel art; mechanical stage change (speed/armor).
5. **Raised Necromancer (miniboss)** *(done)* — mid-wave elite that periodically **resurrects** a fallen
   enemy on the path; pressures low burst DPS. Fine pixel art; resurrect mechanic + cadence.
6. **The 5 crypt maps** *(done)* — 5 distinct paths + escalating wave compositions across the full roster
   (grunt/dog/wraith/mage/knight + miniboss), themed crypt set-dressing. Introduces enemies
   gradually. (May land as sub-slices 6a–6e.)
7. **Act I boss — The Master** *(done)* — a 2–3× setpiece with HP-threshold **phases** (guard-shed → summon
   adds → direct phylactery strikes), his own light source, and the story payoff (you turn on him).
8. **Act completion & integration** *(done)* — act-clear flow + reward, story resolution card, currency/loop
   integration (Grave Bones from the new roster), and a first difficulty pass across the 5 maps.

## Success criteria — met (M3 complete, 2026-07)
- [x] Act I plays start→finish: 5 maps in order, dialogue cards between them, ending on the boss.
- [x] All 5 enemy types (grunt/dog/wraith + Mage/Knight), the Raised Necromancer miniboss, and the
      boss read clearly in the restyled look, each with its signature debone/phase reaction.
- [x] Levels/waves are data-driven; adding/reordering a map is data, not code.
- [x] Act progress persists (Continue resumes; cleared maps replay for farming); the meta loop
      (Grave Bones → sigil) is fed by Act I.
- [x] Full test suite green; no regression; every visual screenshot-verified.

## Technical notes
- **Level data:** a `Resource`/`RefCounted` `Level` (or a plain Dictionary registry to start),
  passed to the run scene via a small hand-off (autoload `RunContext` or scene instance property).
- **WaveManager:** move the `_waves` literal into the `Level`; keep the group schedule format
  (`{script, count, interval, delay}`); add support for a **miniboss group** and **boss**.
- **Enemies:** new enemies extend `Enemy` and author pixel art via `_author_stage()` (M2b pipeline);
  add their armor/damage rows to the counter matrix (`CombatTypes`); mechanical stage effects fire
  in `_on_stage_changed()`.
- **Story:** a `CanvasLayer` dialogue-card overlay (vector style — [`art-direction.md`](./art-direction.md) §10 / GDD §11), fed a list of beats; pauses
  the run or shows between scenes. Keep copy in data, not code.
- **Screenshot-verify** every visual slice; new mechanics get unit tests (progress, resurrect,
  armor-strip stage, boss phase transitions).

## Build order & PRs
Framework (slice 1) first, then story, then the roster (mage → knight → miniboss), then the 5 maps,
then the boss, then act completion. Feature branch + PR per slice; the three review agents +
a screenshot each; doc reviewers when docs are touched.

---

**Status: complete (2026-07).** All 8 slices shipped (PRs #28–#35), each screenshot-verified and
self-reviewed. Act I plays start→finish: five data-driven crypt maps → The Master, an expanded
roster (Skeleton Mage / Armored Knight / Raised Necromancer miniboss + the boss) each with a
signature reaction, between-level dialogue escalating slave→overlord, persistent level progress
with replay-to-farm, and an act-complete flow. A headless auto-play confirmed no soft-locks and
that every map is winnable; **fine-grained balance is a deferred playtest pass**. Next: M4 — Act II
(The Rebellion), built on this framework.*
