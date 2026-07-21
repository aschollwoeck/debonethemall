extends GutTest
## The Master boss (M3 slice 7): its phase mechanics — it summons the dead throughout and, in its
## final phase, strikes the phylactery directly. These are the setpiece's whole identity.

const MASTER := preload("res://scripts/enemies/the_master.gd")
const PHYL := preload("res://scripts/core/phylactery.gd")


func test_boss_stats() -> void:
	var m: Enemy = MASTER.new()
	add_child_autofree(m)
	assert_gt(m.max_hp, 400.0, "a boss health pool")
	assert_eq(m.armor_type, CombatTypes.Armor.BONE, "shatters like bone (the Golem answers)")


func test_summons_the_dead_on_cadence() -> void:
	var m = MASTER.new()
	add_child_autofree(m)
	m.setup(PackedVector2Array([Vector2(0, 100), Vector2(900, 100)]))   # long path — won't leak
	watch_signals(m)
	var ticks := int(m.SUMMON_BASE / 0.1) + 3
	for i in ticks:
		m._physics_process(0.1)
	assert_signal_emitted(m, "reinforcement_requested", "summons reinforcements on a cadence")


func test_final_phase_strikes_the_phylactery() -> void:
	var phy = PHYL.new()
	add_child_autofree(phy)
	phy.global_position = Vector2(500, 100)
	var m = MASTER.new()
	add_child_autofree(m)
	m.setup(PackedVector2Array([Vector2(0, 100), Vector2(900, 100)]))
	m.target_phylactery = phy
	m.stage = 2                          # final phase
	var life0: int = phy.life
	for i in 30:
		m._physics_process(0.1)          # 3s > STRIKE_INTERVAL
	assert_lt(phy.life, life0, "the Master strikes the phylactery across the field in its final phase")
