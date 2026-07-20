extends GutTest
## Unit tests for the damage-type × armor-type counter matrix (CombatTypes autoload).
## This is high-value logic: the whole tactical layer depends on these multipliers.


func test_pierce_is_strong_vs_unarmored() -> void:
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.PIERCE, CombatTypes.Armor.UNARMORED), 1.5)


func test_pierce_is_weak_vs_bone() -> void:
	# Arrows rattle through ribs — the core "archers alone won't do" lesson.
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.PIERCE, CombatTypes.Armor.BONE), 0.5)


func test_blunt_is_strong_vs_bone() -> void:
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.BLUNT, CombatTypes.Armor.BONE), 1.5)


func test_holy_is_strong_vs_ethereal() -> void:
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.HOLY, CombatTypes.Armor.ETHEREAL), 1.5)


func test_ethereal_resists_all_physical_only_necrotic_bites() -> void:
	# The Wraith's whole identity: Pierce/Blunt/Fire all rattle through (×0.5); only Necrotic/Holy works.
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.PIERCE, CombatTypes.Armor.ETHEREAL), 0.5)
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.BLUNT, CombatTypes.Armor.ETHEREAL), 0.5)
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.FIRE, CombatTypes.Armor.ETHEREAL), 0.5)
	assert_eq(CombatTypes.multiplier(CombatTypes.Damage.HOLY, CombatTypes.Armor.ETHEREAL), 1.5)


func test_resolve_damage_applies_multiplier() -> void:
	# 10 blunt into bone → ×1.5 = 15
	assert_eq(CombatTypes.resolve_damage(10.0, CombatTypes.Damage.BLUNT, CombatTypes.Armor.BONE), 15.0)


func test_resolve_damage_reduces_on_weakness() -> void:
	# 10 pierce into bone → ×0.5 = 5
	assert_eq(CombatTypes.resolve_damage(10.0, CombatTypes.Damage.PIERCE, CombatTypes.Armor.BONE), 5.0)


func test_matrix_covers_every_damage_and_armor_combination() -> void:
	# Guards against adding a type and forgetting a matrix cell (would crash at runtime).
	for d in CombatTypes.Damage.values():
		assert_true(CombatTypes.MATRIX.has(d), "matrix missing damage type %s" % d)
		for a in CombatTypes.Armor.values():
			assert_true(CombatTypes.MATRIX[d].has(a),
				"matrix[%s] missing armor type %s" % [d, a])
