extends GutTest
## Tests the WaveManager's per-kill bookkeeping: Grave Bones harvest accrues and in-run Bone
## Dust is granted on each death. (Full spawn/timing behaviour is exercised via headless
## playthroughs, not unit tests.)


const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const PHYL := preload("res://scripts/core/phylactery.gd")


func before_each() -> void:
	GameState.bone_dust = 0


func test_harvest_starts_at_zero() -> void:
	var wm := WaveManager.new()
	add_child_autofree(wm)
	assert_eq(wm.total_harvest(), 0)


func test_harvest_and_dust_accrue_per_kill() -> void:
	var wm := WaveManager.new()
	add_child_autofree(wm)
	wm._on_enemy_died(8, 2)   # reward=8 dust, 2 grave bones
	wm._on_enemy_died(6, 1)   # reward=6 dust, 1 grave bone
	assert_eq(wm.total_harvest(), 3, "grave-bones harvest sums across kills")
	assert_eq(GameState.bone_dust, 14, "in-run Bone Dust also accrues")


func test_reinforcement_only_spawns_while_a_wave_is_active() -> void:
	var wm := WaveManager.new()
	add_child_autofree(wm)
	var phy = PHYL.new()
	add_child_autofree(phy)
	wm.setup(PackedVector2Array([Vector2(0, 0), Vector2(200, 0)]), wm, phy,
		[[{"script": GRUNT, "count": 1, "interval": 1.0, "delay": 0.0}]])
	wm._on_reinforcement(GRUNT)
	assert_eq(wm._alive, 0, "no raising before the wave is active")
	wm.start_next_wave()
	var before: int = wm._alive
	wm._on_reinforcement(GRUNT)
	assert_eq(wm._alive, before + 1, "a raised reinforcement is spawned and tracked (wave can't clear yet)")
