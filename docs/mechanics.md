# Mechanics Reference

Player-facing reference for how the game works. Kept in sync with the code; the seed for a
future in-game codex. *(Reflects the current build — M0. M1 content marked "planned".)*

---

## The loop
Raise undead **minions** beside a fixed **path**. Skeletons and their kin march along it toward
your **phylactery**. Kill them for **Bone Dust** to raise and upgrade more minions. Survive all
waves to win; if the phylactery's life hits zero, the run ends.

## Currencies
- **Bone Dust** — earned from kills, spent during a run to raise/upgrade minions. Resets each run.
- **Grave Bones** — persistent currency spent on the meta skill tree in the Crypt (already
  spendable). *Earning* them by harvesting from runs is still being wired (planned, M1).

## The counter system
Every minion deals a **damage type**; every enemy has an **armor type**. The multiplier decides
how much it hurts (×0.5 weak · ×1.0 normal · ×1.5 strong):

| Damage ↓ / Armor → | Unarmored | Bone | Heavy* | Ethereal* |
|---|---|---|---|---|
| **Pierce** | 1.5 | 0.5 | 0.5 | 1.0 |
| **Blunt** | 1.0 | 1.5 | 1.0 | 0.5 |
| **Fire*** | 1.5 | 1.0 | 1.0 | 0.5 |
| **Necrotic/Holy*** | 1.0 | 1.0 | 0.5 | 1.5 |

\* Heavy, Ethereal, Fire, and Necrotic/Holy exist in the system but first appear as real content
in M1+. *(M1 will lower Pierce/Fire vs Ethereal to 0.5 so the Wraith clearly demands Necrotic.)*

**The takeaway:** no single minion answers everything. Archers shred soft foes but rattle off
bone; golems shatter bone but can't pin fast targets. **Mix your builds.**

## Minions
| Minion | Damage | Range | Role |
|---|---|---|---|
| **Bone Archer** | Pierce | Long | Cheap, fast single-target bolts. Great vs. soft, weak vs. bone. |
| **Bone-Mill Golem** | Blunt | Short | Slow AoE grind pulse. Shatters bone, mediocre vs. fast soft targets. |
| **Bound Wraith** *(M1)* | Necrotic | Medium | Necrotic bolts; the answer to ethereal foes. |

Each minion has **one upgrade** in M0; **branching upgrades** (two specializations) arrive in M1.

## Enemies
| Enemy | Armor | Behaviour | Debone stages |
|---|---|---|---|
| **Skeleton Grunt** | Bone | Standard pace | whole → skull-off crawler (slower) → bone pile |
| **Skeletal Dog** | Unarmored | Fast rusher | whole → split halves (keep sliding) |
| **Wraith** *(M1)* | Ethereal | Physical passes through it | planned |

**Deboning** is HP-threshold based: enemies visibly fall apart in stages as they take damage,
and some changes are mechanical (the grunt's crawler stage moves slower).

## The Crypt (Hub) *(M1)*
The game opens in **The Crypt** — your meta screen. Here you spend **Grave Bones** on the
**skill tree** (unlocking minions and permanent buffs), then press **Begin Run** to play. When
a run ends (win or lose), you **Return to Crypt** to spend and try again.

*Still being wired (planned, M1):* tree purchases don't affect runs yet — buffs and
minion-unlock gating aren't applied in-game, and harvesting Grave Bones from a run into the
Crypt isn't hooked up. Right now the Crypt is navigable and saves your purchases, but the
payoff lands in a later M1 feature.

## Controls
**In the Crypt (Hub):**
- **Click a tree node** to buy it (if affordable and its prerequisite is owned). Node colors:
  **bone/cream** = affordable now (shows its cost), **green** = owned, **amber** = you can't
  afford it yet, **grey** = locked (prerequisite not owned).
- **Begin Run** starts a run.

**In a run:**
- **Select a minion** (bottom-left buttons), then **click a build slot** to raise it.
- **Click a placed minion** to buy its upgrade.
- **Right-click** cancels the current selection.
- **Start Wave** (bottom-right) sends the next wave.
- **Return to Crypt** (on the end screen) returns to the Hub.
