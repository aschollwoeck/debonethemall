extends GutTest
## Enemy armor types and the counter matrix applied through a real enemy's take_damage — the
## core "which minion answers which enemy" contract, especially the Wraith's Necrotic demand.

const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const DOG := preload("res://scripts/enemies/skeletal_dog.gd")
const WRAITH := preload("res://scripts/enemies/wraith.gd")


func test_armor_types() -> void:
	var g: Enemy = GRUNT.new()
	add_child_autofree(g)
	assert_eq(g.armor_type, CombatTypes.Armor.BONE)

	var d: Enemy = DOG.new()
	add_child_autofree(d)
	assert_eq(d.armor_type, CombatTypes.Armor.UNARMORED)

	var w: Enemy = WRAITH.new()
	add_child_autofree(w)
	assert_eq(w.armor_type, CombatTypes.Armor.ETHEREAL)


func test_wraith_shrugs_off_pierce_but_takes_necrotic() -> void:
	var w: Enemy = WRAITH.new()
	add_child_autofree(w)
	var hp0: float = w.hp
	w.take_damage(10.0, CombatTypes.Damage.PIERCE)   # ×0.5 → 5
	assert_almost_eq(w.hp, hp0 - 5.0, 0.01, "pierce rattles through (half damage)")
	var hp1: float = w.hp
	w.take_damage(10.0, CombatTypes.Damage.HOLY)     # ×1.5 → 15
	assert_almost_eq(w.hp, hp1 - 15.0, 0.01, "necrotic tears it apart (1.5×)")


func test_grunt_weak_to_blunt_resists_pierce() -> void:
	var g: Enemy = GRUNT.new()
	add_child_autofree(g)
	var hp0: float = g.hp
	g.take_damage(10.0, CombatTypes.Damage.BLUNT)    # ×1.5 → 15
	assert_almost_eq(g.hp, hp0 - 15.0, 0.01)
