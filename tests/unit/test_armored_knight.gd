extends GutTest
## Armored Knight (M3 slice 4): the mechanical debone — HEAVY plate that shatters to a fast BONE
## skeleton at the first threshold. The armor-swap changes which minion answers it mid-lane, so
## it's the enemy's whole tactical identity and worth pinning.

const KNIGHT := preload("res://scripts/enemies/armored_knight.gd")


func test_starts_armored_heavy() -> void:
	var k: Enemy = KNIGHT.new()
	add_child_autofree(k)
	assert_eq(k.armor_type, CombatTypes.Armor.HEAVY, "starts in plate")
	assert_eq(k.stage, 0)


func test_heavy_plate_resists_pierce() -> void:
	var k: Enemy = KNIGHT.new()
	add_child_autofree(k)
	var hp0: float = k.hp
	k.take_damage(10.0, CombatTypes.Damage.PIERCE)   # PIERCE vs HEAVY = 0.5 → 5
	assert_almost_eq(k.hp, hp0 - 5.0, 0.01, "pierce glances off the plate")


func test_plate_shatters_to_bone() -> void:
	var k: Enemy = KNIGHT.new()
	add_child_autofree(k)
	k.take_damage(k.max_hp * 0.5, CombatTypes.Damage.BLUNT)   # BLUNT vs HEAVY = 1.0 → crosses 0.6
	assert_eq(k.stage, 1, "plate shattered at the first threshold")
	assert_eq(k.armor_type, CombatTypes.Armor.BONE, "the exposed skeleton is bone, not heavy")


func test_single_hit_crossing_both_thresholds_still_strips() -> void:
	var k: Enemy = KNIGHT.new()
	add_child_autofree(k)
	k.take_damage(k.max_hp * 0.9, CombatTypes.Damage.BLUNT)   # one blow past 0.6 AND 0.25
	assert_eq(k.stage, 2, "jumps straight to the collapsing stage")
	assert_eq(k.armor_type, CombatTypes.Armor.BONE, "still strips (hook fires once at stage 2)")


func test_stripped_form_sprints() -> void:
	var k: Enemy = KNIGHT.new()
	add_child_autofree(k)
	assert_gt(k.stage_speed_mult[1], k.stage_speed_mult[0], "the exposed skeleton is faster than the armoured knight")
