extends RefCounted
class_name RunModifiers
## The aggregated effect of all unlocked skill-tree nodes, computed by SkillTree at the start
## of a run. A run reads this to know which minions are available and what global buffs apply
## (GDD §7/§10). Plain data — no behaviour beyond convenience accessors.

## Minion ids the player may place this run (starter + tree unlocks).
var unlocked_minions: Array[String] = []

## Extra phylactery max life granted by the tree.
var phylactery_bonus: int = 0

## Extra starting Bone Dust granted by the tree.
var starting_dust_bonus: int = 0

## Global minion damage multiplier (1.0 = no change).
var minion_damage_mult: float = 1.0


## True if the given minion id is placeable this run.
func has_minion(id: String) -> bool:
	return id in unlocked_minions
