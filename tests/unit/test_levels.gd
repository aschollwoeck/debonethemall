extends GutTest
## Tests the Act I level registry + progression (M3, docs/M3-act-one.md). The registry ordering,
## unlock gating, and the "next uncleared" cursor drive the Hub's level bar and the Continue flow,
## so a regression here would strand the player or unlock the wrong crypt.


func before_each() -> void:
	MetaState._cleared_levels.clear()   # isolate level progress without touching bones/unlocks


func test_act1_registry_shape() -> void:
	assert_eq(Levels.act1_count(), 6, "5 maps + boss")
	assert_eq(Levels.act1_level(0).id, "act1_l1")
	assert_false(Levels.act1_level(0).is_boss, "level 1 is not the boss")
	assert_true(Levels.act1_level(5).is_boss, "the last level is the boss")
	assert_null(Levels.act1_level(99), "out-of-range index → null")


func test_level_one_has_real_content() -> void:
	var l1 := Levels.act1_level(0)
	assert_gt(l1.path.size(), 1, "has a path")
	assert_gt(l1.slots.size(), 0, "has build slots")
	assert_gt(l1.waves.size(), 0, "has a wave schedule")


func test_first_level_unlocked_rest_gated() -> void:
	assert_true(Levels.is_act1_unlocked(0), "the first level is always playable")
	assert_false(Levels.is_act1_unlocked(1), "level 2 is locked until level 1 is cleared")


func test_clearing_a_level_unlocks_the_next() -> void:
	MetaState.mark_level_cleared("act1_l1")
	assert_true(Levels.is_act1_unlocked(1), "clearing L1 unlocks L2")
	assert_false(Levels.is_act1_unlocked(2), "but L3 stays locked")


func test_next_index_advances_with_clears() -> void:
	assert_eq(Levels.act1_next_index(), 0, "start on level 1")
	MetaState.mark_level_cleared("act1_l1")
	MetaState.mark_level_cleared("act1_l2")
	assert_eq(Levels.act1_next_index(), 2, "next uncleared is level 3")


func test_next_index_clamps_when_all_cleared() -> void:
	for lvl in Levels.act1:
		MetaState.mark_level_cleared(lvl.id)
	assert_eq(Levels.act1_next_index(), Levels.act1_count() - 1, "clamps to the last when all cleared")


func test_levels_carry_story_beats() -> void:
	var l1 := Levels.act1_level(0)
	assert_gt(l1.intro.size(), 0, "level 1 has intro dialogue")
	assert_gt(l1.outro.size(), 0, "level 1 has outro dialogue")
	var beat: Dictionary = l1.intro[0]
	assert_true(beat.has("who") and beat.has("line"), "a beat carries who + line")
	var boss := Levels.act1_level(Levels.act1_count() - 1)
	assert_gt(boss.intro.size(), 0, "the boss has intro dialogue")
	assert_gt(boss.outro.size(), 0, "the boss has outro dialogue (the story turn)")
