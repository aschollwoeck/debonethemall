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
- **Grave Bones** *(planned, M1)* — persistent currency banked between runs, spent on the meta
  skill tree.

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

## Controls
- **Select a minion** (bottom-left buttons), then **click a build slot** to raise it.
- **Click a placed minion** to buy its upgrade.
- **Right-click** cancels the current selection.
- **Start Wave** (bottom-right) sends the next wave.
