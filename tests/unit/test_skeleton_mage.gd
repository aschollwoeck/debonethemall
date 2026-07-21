extends GutTest
## Skeleton Mage (M3 slice 3): its ranged-caster behaviour — halts within range of the phylactery
## and chips it on a cadence instead of leaking; out of range it advances. The mechanic is the
## enemy's whole identity, so it's worth pinning.

const MAGE := preload("res://scripts/enemies/skeleton_mage.gd")
const PHYLACTERY := preload("res://scripts/core/phylactery.gd")


func test_armor_is_bone() -> void:
	var m: Enemy = MAGE.new()
	add_child_autofree(m)
	assert_eq(m.armor_type, CombatTypes.Armor.BONE, "shatters like bone (weak to Blunt)")


func test_casts_at_the_phylactery_when_in_range() -> void:
	var phy = PHYLACTERY.new()
	add_child_autofree(phy)
	phy.global_position = Vector2(400, 200)
	var m = MAGE.new()
	add_child_autofree(m)
	m.target_phylactery = phy
	m.global_position = Vector2(360, 200)   # within CAST_RANGE (72) of the phylactery
	var life0: int = phy.life
	# tick past one cast interval
	for i in 20:
		m._physics_process(0.1)   # 2.0s total > CAST_INTERVAL (1.5s)
	assert_lt(phy.life, life0, "the mage chips the phylactery from range")
	assert_eq(m.global_position, Vector2(360, 200), "it halts to cast (doesn't advance)")


func test_advances_when_out_of_range() -> void:
	var phy = PHYLACTERY.new()
	add_child_autofree(phy)
	phy.global_position = Vector2(400, 200)
	var m = MAGE.new()
	add_child_autofree(m)
	m.setup(PackedVector2Array([Vector2(0, 200), Vector2(400, 200)]))
	m.target_phylactery = phy
	m.global_position = Vector2(0, 200)     # far from the phylactery
	var life0: int = phy.life
	m._physics_process(0.2)
	assert_gt(m.global_position.x, 0.0, "out of range, it marches along the path")
	assert_eq(phy.life, life0, "and does not damage the phylactery yet")
