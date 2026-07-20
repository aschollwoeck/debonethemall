# Debone Them All — Game Design Document

> **Status:** Draft v0.1 — living document. Sections marked **TODO** are open questions for review.

---

## 1. Elevator Pitch

A pixel-art tower defense set in a crazy, funny, dark-fantasy world. You begin as a
lowly reanimated **slave** bound to a cruel necromancer, defending your master's crypt
just to survive. You break your chains, turn on the necromancers who made you, and march
on the "holy" land to take it all. Along the way you **debone** endless skeletons and
their kin in gleefully violent, comedic ways.

Your towers are not machines — they are **undead minions you raise**. You don't build
defenses; you raise an army that happens to stand still.

**One-liner:** *Rise from slave to overlord, one pile of bones at a time.*

---

## 2. Design Pillars

1. **Deboning is satisfying and funny.** Every enemy has a signature damage/death reaction.
   Combat readability and comedy come from *how things fall apart*.
2. **Fixed-path tactical puzzle.** Enemies follow set tracks; positioning and timing your
   raised minions is the core strategy.
3. **You grow into the villain.** Mechanical power and narrative power rise together —
   from a cowering servant to a gloating overlord.
4. **Everything is diegetic.** Towers are raised undead. Currency is harvested bones/souls.
   The economy *is* the theme.
5. **Dark, crazy, comedic tone.** Grim world, but it never takes itself too seriously.

---

## 3. Platform & Tech

- **Target platform:** Desktop — Windows, macOS, Linux.
- **Engine:** **Godot 4** (2D). Chosen for native desktop export, strong pixel-art
  workflow (TileMap, AnimatedSprite2D, pixel snapping), scene/node modularity that scales
  to content-heavy games, GDScript iteration speed, and no licensing/royalties.
- **Art style:** Pixel art. **TODO:** target resolution / sprite scale (e.g. 32x32 tiles?),
  palette direction, animation frame budget.
- **Language:** GDScript primary; C#/native reserved for hot paths only if profiling ever
  demands it (unlikely for a TD).

---

## 4. Scope

**Ambitious project** — a full game, built in milestones. See Roadmap (§12).

---

## 5. Core Gameplay Loop

1. **Prepare** — between waves, spend harvested currency to raise/upgrade minion-towers on
   valid tiles beside a fixed enemy path.
2. **Fight** — waves of skeletons and kin walk the path toward your objective; your minions
   attack automatically. Enemies debone on damage/death with signature reactions.
3. **Harvest** — kills yield in-run currency (gold-equivalent) and meta currency (bones/souls).
4. **Leak = damage** — enemies reaching the end chip away at *your own life* (see below).
5. **Death is not "game over" — it's the meta loop.** When your life runs out you aren't
   defeated; you are **pushed back / "reborn"** to the skill-tree menu to spend everything
   you harvested this run, then take another crack. Losing a run *is* how you progress.

### Fixed path
Enemies follow a set track from spawn to the objective (Kingdom Rush / Bloons-track style),
**not** free navigation and **not** maze-building. Tower placement puzzle = choosing which
tiles beside the path give the best coverage.

### The objective enemies attack = your **phylactery** (decided)
Enemies march toward a **literal phylactery** — a physical object placed on the map that
holds your unlife. It has a health/life meter that depletes as enemies reach it. Because
it's a real on-map object, **where it sits (and defending it) is part of the tactical
puzzle**, not just an abstract HUD counter.

When the phylactery breaks you don't lose the game; you are **cast back to the menu / skill
tree** (framed narratively as being "pushed back" or "reborn"). This makes the loop
**roguelite-flavored**: every run feeds the meta tree, and death is a cash-in moment, not a
wall.

### No-loss-on-death + success bonus (decided)
- **On death you keep 100% of what you harvested** this run. Failure is never punished —
  it always advances the meta. This keeps the game welcoming and the roguelite loop kind.
- **A successful run grants a bonus/multiplier** applied to that run's harvest at the end.
  So the incentive is inverted from "don't die" to "**finish strong for the big payout**" —
  a good run *feels* great without a bad run stinging.

**TODO:** Shape of the success bonus — flat multiplier? Scales with life remaining / speed /
no-leak clears? Decide what "successful" rewards (survival vs. mastery).

---

## 6. Enemies & The Debone Hook

Every enemy has a **signature reaction** — a distinct, recognizable way of taking damage
and dying. Reactions are ideally **mechanical, not just cosmetic**, creating tactical depth.

| Enemy | Role | Signature reaction |
|---|---|---|
| **Skeleton grunt** | Basic fodder | Loses parts progressively: skull pops off → crawling ribcage → collapses to bone pile |
| **Skeleton mage** | Ranged / support | Bursts into flames, flails, crumbles to ash (fire/holy sources extra funny) |
| **Skeletal dog** | Fast rusher | Splits apart mid-run, keeps sliding on momentum |
| **Armored knight** | Tanky | Armor shatters off first → becomes a fast grunt → *then* debones |
| **Bone golem** | Boss | Collapses into a pile that **spawns several small skeletons** |

**Design intent:** mechanical reactions create decisions — kill the golem now and eat the
swarm, or whittle it down? Armor-strip changes an enemy's speed/behavior mid-lane.

**Debone implementation = HP-threshold stages (decided).** Enemies advance through discrete
visual/behavioral **stages at fixed HP percentages** (e.g. grunt: 100–66% intact →
66–33% skull-off crawler → 33–0% collapsing), rather than a per-hit limb state machine.
Simpler to build and balance, and still reads clearly. Mechanical changes (knight armor-strip
speeds it up, golem death seeds skeletons) fire on crossing a threshold.

**TODO:** Full enemy roster per act (see §9). Stats/damage-type interactions now live in the
Combat Model (§8).

### Minibosses & Bosses
Two tiers of setpiece enemies break up the wave rhythm and test the player's build:

- **Minibosses** — appear mid-act as elite units *inside* a wave. Each carries a **mechanic
  that pressures a specific build weakness**, so your chosen tower route matters. Examples:
  - **Bone Marshal** — buffs/shields nearby skeletons; punishes low single-target DPS.
  - **Raised Necromancer** — periodically **resurrects fallen enemies** on the path; creates
    "kill it fast or drown" pressure.
  - **Reliquary Knight** (Act III) — projects a holy ward that heals allies; forces DoT/
    armor-strip answers.
- **Act Bosses** — an end-of-act setpiece, one per act. Bosses lean on the **HP-threshold
  system (§6)**: they **change form / phase at thresholds** (e.g. 66%, 33%) — shedding
  armor, splitting into adds, or switching attack patterns — which reuses the debone-stage
  tech we're already building. Bosses may also **strike the phylactery directly** if they
  reach it, raising the stakes of a leak.

**Boss concepts per act (placeholder — TODO):**
| Act | Boss | Hook |
|---|---|---|
| I | **The Master** (your cruel necromancer) or his crypt guardian | The tutorial villain; you finally turn on him |
| II | **Rival Necromancer-King** | Fields the strongest rival undead; phase-shifts by summoning waves |
| III | **Radiant Archon / High Cleric** | Holy setpiece; mass-heals and smites, the final obstacle to conquest |

**TODO:** Confirm boss roster + each boss's phase mechanics. **TODO:** Miniboss cadence
(how often per act). **TODO:** Do bosses drop unique currency / unlock rewards?

---

## 7. Towers = Raised Undead Minions

Towers are reanimated minions, themed as necromantic conjurations rather than machines.

- **In-run upgrades:** each minion has 2–3 upgrade tiers bought with in-run currency.
- **Branching paths:** at a tier, a minion forks into specialized variants
  (e.g. AoE grinder vs. single-target burst), à la Bloons TD 6, for build variety.

**Starter concepts (placeholder names — TODO finalize roster):**

| Minion (tower) | Fantasy | Rough role |
|---|---|---|
| **Bone Archer** | Reanimated skeleton archer | Cheap single-target ranged |
| **Bone-Mill Golem** | Raised grinder golem | Slow AoE, grinds bones to dust |
| **Plague Censer** | Undead thurifer swinging a poison censer | Damage-over-time / debuff |
| **Ballista Wight** | Bound wight crewing a ballista | High single-target burst, slow fire |
| **Necro-Beacon** | Support totem | Buffs nearby minions / harvests extra souls |

**TODO:** Finalize the roster, branch trees per tower, costs/scaling.

### Unlocking minions — commit to a route (decided)
Minions are **not** all available from the start. This is a core identity system:

- **You start with very few** (likely **one** starter minion, e.g. the Bone Archer — enough
  to play M0's loop). Everything else is **locked**.
- **Each minion is unlocked via a meta skill-tree node**, bought with currencies (§10).
  Once unlocked, the minion is permanent across runs; **further nodes down that minion's
  branch strengthen it** (more damage, new abilities, opening its in-run upgrade forks).
- **Having everything is very hard by design.** Costs escalate and unlock nodes are gated so
  that in the early/mid game **you cannot afford more than one or two routes** — the player
  must **choose a specialization** (e.g. "archer/burst route" vs. "golem/AoE route" vs.
  "plague/DoT route") and build around it. Opportunity cost is the point.
- **Late game = everything.** With enough deep grinding (and cross-arc currency farming, §10)
  a veteran can eventually unlock the full roster — but only after real investment.

**Commitment mechanism — TODO (pick during meta-tree design):** how "route commitment" is
enforced. Candidates:
1. **Pure cost-gating** — nothing is mutually exclusive, but escalating costs mean you can
   only afford one route at a time early on. Simplest; softest commitment.
2. **Mutually-exclusive forks** — at certain tiers you pick *one* school and lock out the
   other(s) until a (costly) respec. Hardest commitment, strongest build identity.
3. **Hybrid (leaning recommendation)** — a few key exclusive forks for identity, the rest
   cost-gated; an expensive **respec** exists so choices are meaningful but not permanent
   prison.

**TODO:** Respec — does one exist, and what does it cost (currency? a run? a cooldown)?

---

## 8. Combat Model — Stats, Damage Types & Counters

The heart of the tactical layer. Towers and enemies both carry **stats**, and a
**damage-type / armor-type counter system** makes some minions strong against some enemies
and weak against others. This is what turns "place highest DPS" into a real build puzzle —
and it's the mechanical justification for the route-commitment system (§7): a specialized
build has **holes** that specific enemies and minibosses exploit.

### Tower (minion) stats
Each minion is defined by a stat block:
- **Damage** — per hit.
- **Damage type** — see matrix below (e.g. Pierce, Blunt, Fire, Holy/Necrotic).
- **Attack speed / rate of fire.**
- **Range** (and shape — single-tile, line, radius/AoE).
- **Targeting** — single vs. splash; priority (first / strongest / weakest / nearest).
- **Special effects** — DoT, slow, armor-strip, buff-aura, currency-harvest bonus, etc.
- **Cost** (in-run) and **upgrade scaling** (how the above grow per tier).

### Enemy stats
Each enemy carries:
- **Max HP** (drives the debone thresholds, §6).
- **Armor type** — determines which damage types are strong/weak against it
  (e.g. Unarmored, Bone, Heavy Armor, Ethereal/Warded).
- **Move speed.**
- **Resistances / immunities** (e.g. skeletons resist Pierce — arrows rattle through ribs;
  weak to Blunt — shattering; holy units resist Necrotic).
- **Special behavior** — heals, shields allies, resurrects, splits, phase-shifts (bosses).

### Damage-type × armor-type matrix (draft — TODO balance)
Rough shape of the rock-paper-scissors. Values illustrative (×0.5 weak, ×1 normal, ×1.5 strong):

| Damage ↓ / Armor → | Unarmored | Bone | Heavy Armor | Ethereal/Warded |
|---|---|---|---|---|
| **Pierce** (archers) | 1.5 | **0.5** | 0.5 | 1 |
| **Blunt** (golem/mill) | 1 | **1.5** | 1 | 0.5 |
| **Fire** (censer, mages-burn) | 1.5 | 1 | 1 | 0.5 |
| **Holy/Necrotic** (relics) | 1 | 1 | 0.5 | **1.5** |

**Reading it:** Pierce shreds soft targets but **rattles uselessly through bone** → you need
a Blunt minion (Bone-Mill Golem) for skeleton hordes. Ethereal/warded holy-army units shrug
off physical → you need Necrotic sources. No single minion covers everything → **you must
diversify or accept a weakness** — exactly the tension the route system creates.

**Why this ties everything together:**
- **Minibosses (§6)** are designed to punch through a build's weak damage type.
- **Route commitment (§7)** means your unlocked minions may lack an answer to a given armor
  type — you feel the hole, and the meta tree is how you patch it.
- **Enemy factions rotate by act (§9)**, so each act's armor profile rewards different
  damage types — reinforcing cross-arc farming and build variety.

**TODO:** Finalize the damage/armor type lists and the full matrix values (balance pass).
**TODO:** Do towers deal one fixed damage type, or can upgrades change/add a type?
**TODO:** Are resistances hard immunities anywhere, or always soft multipliers?

---

## 9. Story & Act Structure

A **three-act villain-origin arc**. Enemy factions rotate by act, so content variety is
baked into the narrative.

### Act I — The Slave
Bound servant of a cruel necromancer. You defend your master's crypt just to survive.
Enemies: crypt-dwellers, grave-robbers, holy **inquisitors** raiding the tomb. You learn
the trade in chains. **Tone:** grim, oppressed, darkly comic.

### Act II — The Rebellion
You break free and turn on the necromancers. Enemies: **rival undead armies** — other
skeletons and mages (the debone / burst-into-flames reactions shine when your enemies are
your own kind). You harvest their bones and forbidden secrets; meta currency flows hard.
**Tone:** rising, vengeful, gaining swagger.

### Act III — The Conquest
You march on the "holy" land. Enemies: **paladins, clerics, radiant knights** — healers
and support that create new tactical puzzles. The underdog is now the overwhelming dark
power. **Tone:** triumphant villainy; the world tips into darkness and it feels earned.

**TODO:** Number of maps/levels per act. **TODO:** Boss per act. **TODO:** How story is
delivered (dialogue cards between levels? in-level barks? cutscene stingers?).

---

## 10. Progression Systems

Three stacked layers:

1. **In-run tower upgrades** (tactical, moment-to-moment) — buy tiers with run currency.
2. **Branching tower paths** (build variety within a run).
3. **Persistent meta skill tree** (long-term pull, between runs) — the heart of "why keep
   playing."

### Currencies — multiple, act-gated, cross-farmed (decided)
There is **not** one meta currency but **several**, and this drives a deliberate
**cross-arc farming loop**:

- **In-run currency** (spent *during* a run to raise/upgrade minions) — resets each run.
  Working name: **Bone Dust** (or just "bones").
- **Meta currencies** (persist, spent on the skill tree) — **multiple distinct types**,
  each primarily harvested in a specific act/arc. Placeholder examples:
  - **Grave Bones** — plentiful in Act I (crypt fodder).
  - **Rival Souls** — harvested from other necromancers' undead in Act II.
  - **Radiant Relics / Sanctified Ash** — dropped by the holy army in Act III.

**The loop this creates:** deeper skill-tree nodes cost **combinations** of currencies from
*different acts*. To afford a powerful Act III unlock you may need to **jump back to Act I/II
to farm** the currencies it requires. This makes earlier acts stay relevant, encourages
replaying maps, and gives the meta a "gather the ingredients" strategy layer on top of raw
grinding.

**Tuning intent — satisfying, not easy (decided).** Cross-arc combos are a **curated set**
of meaningful nodes, not every node — back-tracking should feel like a *rewarding plan*
("I'll farm Act I to unlock this power"), never a mindless tax. But the game overall is
**not meant to be easy**: currency is earned, gates are real, and mastery (finishing runs
strong for the success bonus, §5) is how you accelerate. Kind on failure, demanding on
ambition.

**TODO:** Confirm the currency set and names. **TODO:** Pick *which* specific nodes take
cross-arc combos and the ratios, during the balance pass.

### Meta skill tree — "Reclaiming Your Power"
- Fueled by the meta currencies above, harvested every run (and banked on death).
- Unlocks **content** (new minion types, new maps/modifiers) *and* **power** (global
  buffs, extra starting currency, more starting life).
- Thematically shaped as a **necromantic sigil / growing spine** — power radiating outward
  as you rise from slave to overlord.
- **Light incremental spice:** currency may accrue slightly between sessions so there's a
  reason to return — but the heart stays **tactical strategy**, not idle number-go-up.

**TODO:** Actual tree node list and layout. **TODO:** Is there a prestige/reset loop later?
**TODO:** Currency earn rates and tree costs (balance pass, much later).

---

## 11. Tone & Presentation

- **The player's voice:** the protagonist has a **developing personality** across the arc —
  from meek, frightened servant → wary rebel → gloating overlord. Carries much of the
  comedy. **TODO:** Delivery method (text barks, subtitle-style quips, VO later?).
- **Comedy through violence:** deboning, flaming mages, sliding dog-halves — slapstick,
  never grimdark-serious.
- **Diegetic UI flavor:** currency, upgrades, and menus themed as necromancy
  (raise / harvest / bind), not generic RTS chrome.

**TODO:** Art direction reference board. **TODO:** Music/SFX direction. **TODO:** UI mockups.

---

## 12. Roadmap (Milestones)

> Order and content provisional — to be refined after GDD review.

- **✅ M0 — Prototype (prove the fun) — DONE:** one map, fixed path, **2 minions** (Bone Archer /
  Bone-Mill Golem), **2 enemies** (grunt / dog) with debone stages, a 5-wave sequence,
  in-run economy, win/lose. No meta. **Full spec: [`M0-prototype.md`](./M0-prototype.md).**
- **✅ M1 — Core systems — DONE:** the persistent meta loop — Hub screen ("The Crypt"), Grave
  Bones currency, save/load, meta skill tree (minion unlocks + buffs), in-run branching
  upgrades, plus a 3rd minion (Bound Wraith / Necrotic) & enemy (Wraith / Ethereal) with
  unlock gating. Runs finite. **Full spec: [`M1-core-systems.md`](./M1-core-systems.md).**
  *(Difficulty is a first pass — final balance is pending playtest.)*
- **✅ M2 — Visual Overhaul — DONE (superseded):** brought the crazy-dark aesthetic in-engine
  (layered backdrop, lighting, shaded units, diegetic HUD) — but in a single low-res big-pixel
  look that playtesting rejected. **Spec: [`M2-visual-overhaul.md`](./M2-visual-overhaul.md).**
- **▶ M2b — Art Restyle (NEXT):** rebuild the rendering to **finer-pixel units on smooth painted
  backgrounds, a clean vector UI, and a necromantic-sigil skill tree**. Design carries; rendering
  approach changes. **Spec: [`M2b-restyle.md`](./M2b-restyle.md) · Art bible: [`art-direction.md`](./art-direction.md).**
- **M3 — Act I content:** full Act I maps, enemy roster, story delivery, the slave framing —
  built in the restyled look from the start.
- **M4+ — Acts II & III, polish, audio, balance.**

---

## 13. Open Questions (consolidated TODO list)

**Resolved (moved into body):**
- [x] Leak punishment — enemies attack *your own life*; death → pushed back / "reborn" to
      the skill tree to spend harvested currency (roguelite loop). *(§5)*
- [x] Limb-loss granularity — **HP-threshold stages**, not a per-hit state machine. *(§6)*
- [x] Meta currency count — **multiple, act-gated, with cross-arc farming**. *(§10)*
- [x] Leak objective — a **literal phylactery** object placed/defended on the map. *(§5)*
- [x] Death economy — **keep 100% on death**; **successful runs get a bonus/multiplier**. *(§5)*
- [x] Cross-arc tuning — curated combos, "satisfying not easy," kind-on-failure. *(§10)*
- [x] Tower availability — **start with ~1**, rest **unlocked via meta tree**; route
      commitment so all-towers is hard until late game. *(§7)*
- [x] Bosses/minibosses — **framework added**: minibosses pressure builds; act bosses
      phase-shift on HP thresholds and can strike the phylactery. *(§6)*

**Still open:**
- [ ] Pixel-art specs: tile/sprite resolution, palette, animation frame budget.
- [ ] Success-bonus shape — flat multiplier vs. scaling with life left / speed / no-leak.
- [ ] Route-commitment mechanism (cost-gate vs. exclusive forks vs. hybrid) + respec rules.
- [ ] Boss roster + phase mechanics; miniboss cadence; boss drop rewards.
- [ ] Full enemy roster per act + per-enemy stat blocks (HP, armor type, speed, resists).
- [ ] Damage-type & armor-type lists + full counter-matrix values (balance pass).
- [ ] Do towers deal one fixed damage type, or can upgrades change/add types?
- [ ] Are any resistances hard immunities, or always soft multipliers?
- [ ] Final tower/minion roster + per-minion stat blocks, branch trees, costs.
- [ ] Confirm currency set + names; which tree nodes need cross-arc combos vs. single.
- [ ] Meta skill tree node list, layout, and costs.
- [ ] Story delivery method and the protagonist's voice/bark system.
- [ ] Maps and bosses per act.
- [ ] Prestige/incremental depth — how far to lean idle, if at all.
- [ ] Art direction, music/SFX direction, UI mockups.
- [ ] M0 prototype scope + success criteria (immediate next step).

---

*This is a living document. Update it as decisions are made; move items from TODO into the
body once resolved.*
