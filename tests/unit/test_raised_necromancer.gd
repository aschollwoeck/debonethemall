extends GutTest
## Raised Necromancer miniboss (M3 slice 5): its identity is raising reinforcements on a cadence
## ("kill it fast or drown"). Pins the miniboss stats and that it actually emits the raise request
## the WaveManager listens for.

const NECRO := preload("res://scripts/enemies/raised_necromancer.gd")


func test_miniboss_stats() -> void:
	var n: Enemy = NECRO.new()
	add_child_autofree(n)
	assert_eq(n.armor_type, CombatTypes.Armor.BONE, "shatters like bone (Golem answers it)")
	assert_gt(n.max_hp, 100.0, "elite HP — must be bursted down")


func test_raises_reinforcements_on_cadence() -> void:
	var n = NECRO.new()
	add_child_autofree(n)
	n.setup(PackedVector2Array([Vector2(0, 100), Vector2(600, 100)]))   # long path — won't leak
	watch_signals(n)
	var ticks := int(n.RESURRECT_INTERVAL / 0.1) + 3
	for i in ticks:
		n._physics_process(0.1)
	assert_signal_emitted(n, "reinforcement_requested", "raises a fresh skeleton on a cadence")
