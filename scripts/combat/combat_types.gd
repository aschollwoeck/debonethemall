extends Node
## Autoload singleton (CombatTypes).
##
## Central definition of damage types, armor types, and the counter matrix that makes
## some minions strong against some enemies and weak against others (GDD §8).
## Keep balance values here so tuning lives in one place.

enum Damage {
	PIERCE,   ## Bone Archer — great vs. soft, rattles through bone
	BLUNT,    ## Bone-Mill Golem — shatters bone, mediocre vs. soft
	FIRE,     ## censer / mage burn (post-M0)
	HOLY,     ## necrotic/relic (post-M0)
}

enum Armor {
	UNARMORED,   ## soft flesh — skeletal dog
	BONE,        ## skeleton grunt
	HEAVY,       ## armored knight (post-M0)
	ETHEREAL,    ## warded holy units (post-M0)
}

## Multiplier applied to damage: matrix[damage_type][armor_type].
## 0.5 = weak, 1.0 = normal, 1.5 = strong. Illustrative M0 values — tune in the balance pass.
const MATRIX := {
	Damage.PIERCE: {
		Armor.UNARMORED: 1.5,
		Armor.BONE: 0.5,
		Armor.HEAVY: 0.5,
		Armor.ETHEREAL: 1.0,
	},
	Damage.BLUNT: {
		Armor.UNARMORED: 1.0,
		Armor.BONE: 1.5,
		Armor.HEAVY: 1.0,
		Armor.ETHEREAL: 0.5,
	},
	Damage.FIRE: {
		Armor.UNARMORED: 1.5,
		Armor.BONE: 1.0,
		Armor.HEAVY: 1.0,
		Armor.ETHEREAL: 0.5,
	},
	Damage.HOLY: {
		Armor.UNARMORED: 1.0,
		Armor.BONE: 1.0,
		Armor.HEAVY: 0.5,
		Armor.ETHEREAL: 1.5,
	},
}


## Returns the damage multiplier for a given damage type hitting a given armor type.
func multiplier(damage_type: Damage, armor_type: Armor) -> float:
	return MATRIX[damage_type][armor_type]


## Final damage after applying the counter matrix. Central hit-resolution helper so every
## minion/projectile computes damage the same way.
func resolve_damage(base_damage: float, damage_type: Damage, armor_type: Armor) -> float:
	return base_damage * multiplier(damage_type, armor_type)
