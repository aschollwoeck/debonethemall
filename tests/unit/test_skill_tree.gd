extends GutTest
## Unit tests for the meta skill tree (SkillTree autoload): data integrity, purchase gating
## (prereqs / affordability / already-owned), and effect aggregation into RunModifiers. This
## logic gates all meta progression, so wrong gating or bad aggregation would break the game's
## core loop.


func before_each() -> void:
	MetaState.reset_all()


# ---- data integrity ----

func test_every_node_has_required_fields_and_valid_effect() -> void:
	for id in SkillTree.all_node_ids():
		var node: Dictionary = SkillTree.get_node_def(id)
		for key in ["name", "desc", "cost", "prereqs", "effect"]:
			assert_true(node.has(key), "node '%s' missing field '%s'" % [id, key])
		assert_gt(node["cost"], 0, "node '%s' should cost > 0" % id)
		assert_eq(node["effect"].size(), 1, "node '%s' effect must hold exactly one key" % id)
		for ekey in node["effect"]:
			assert_true(ekey in SkillTree.EFFECT_KEYS, "node '%s' has unknown effect '%s'" % [id, ekey])


func test_all_prereqs_reference_existing_nodes() -> void:
	for id in SkillTree.all_node_ids():
		for prereq in SkillTree.get_node_def(id)["prereqs"]:
			assert_true(SkillTree.has_node_def(prereq),
				"node '%s' has prereq '%s' that doesn't exist" % [id, prereq])


# ---- purchase gating ----

func test_root_node_purchasable_when_affordable() -> void:
	MetaState.grave_bones = 100
	assert_true(SkillTree.can_purchase("hoard_1"))   # cost 40, no prereqs


func test_not_purchasable_when_broke() -> void:
	MetaState.grave_bones = 10
	assert_false(SkillTree.can_purchase("hoard_1"))


func test_gated_node_needs_prereq() -> void:
	MetaState.grave_bones = 1000
	assert_false(SkillTree.can_purchase("hoard_2"), "hoard_2 needs hoard_1 first")
	assert_true(SkillTree.purchase("hoard_1"))
	assert_true(SkillTree.can_purchase("hoard_2"), "now that hoard_1 is owned")


func test_cannot_repurchase_owned_node() -> void:
	MetaState.grave_bones = 1000
	assert_true(SkillTree.purchase("unlock_golem"))
	assert_false(SkillTree.can_purchase("unlock_golem"))


func test_purchase_spends_and_unlocks() -> void:
	MetaState.grave_bones = 100
	assert_true(SkillTree.purchase("hoard_1"))       # cost 40
	assert_eq(MetaState.grave_bones, 60)
	assert_true(MetaState.is_unlocked("hoard_1"))


func test_purchase_fails_and_keeps_state_when_gated() -> void:
	MetaState.grave_bones = 1000
	assert_false(SkillTree.purchase("hoard_2"))       # prereq missing
	assert_eq(MetaState.grave_bones, 1000, "no spend on a failed purchase")
	assert_false(MetaState.is_unlocked("hoard_2"))


func test_unknown_node_is_not_purchasable() -> void:
	MetaState.grave_bones = 1000
	assert_false(SkillTree.can_purchase("does_not_exist"))
	assert_false(SkillTree.purchase("does_not_exist"))


# ---- effect aggregation ----

func test_fresh_modifiers_have_only_starter_minion() -> void:
	var mods := SkillTree.build_run_modifiers()
	assert_eq(mods.unlocked_minions, ["archer"])
	assert_eq(mods.phylactery_bonus, 0)
	assert_eq(mods.starting_dust_bonus, 0)
	assert_almost_eq(mods.minion_damage_mult, 1.0, 0.001)


func test_unlocking_minions_adds_them() -> void:
	MetaState.unlock("unlock_golem")
	MetaState.unlock("unlock_wraith")
	var mods := SkillTree.build_run_modifiers()
	assert_true(mods.has_minion("archer"))
	assert_true(mods.has_minion("golem"))
	assert_true(mods.has_minion("wraith"))


func test_buffs_aggregate_across_unlocked_nodes() -> void:
	MetaState.unlock("phylactery_1")
	MetaState.unlock("phylactery_2")
	MetaState.unlock("hoard_1")
	MetaState.unlock("malice_1")
	MetaState.unlock("malice_2")
	var mods := SkillTree.build_run_modifiers()
	assert_eq(mods.phylactery_bonus, 10, "5 + 5")
	assert_eq(mods.starting_dust_bonus, 50)
	# 1.0 + 0.10 (malice_1) + 0.15 (malice_2) = 1.25
	assert_almost_eq(mods.minion_damage_mult, 1.25, 0.001)


func test_unknown_unlocked_id_is_ignored_in_aggregation() -> void:
	MetaState.unlock("legacy_node_from_old_save")
	var mods := SkillTree.build_run_modifiers()
	assert_eq(mods.unlocked_minions, ["archer"], "unknown ids must not crash or add effects")


func test_get_node_def_unknown_returns_empty() -> void:
	assert_eq(SkillTree.get_node_def("nope"), {})


func test_aggregation_does_not_mutate_shared_data_or_accumulate() -> void:
	MetaState.unlock("unlock_golem")
	MetaState.unlock("malice_1")
	var first := SkillTree.build_run_modifiers()
	var second := SkillTree.build_run_modifiers()
	# Two calls must be identical — no accumulation, no mutation of const NODES/STARTER_MINIONS.
	assert_eq(second.unlocked_minions, first.unlocked_minions)
	assert_almost_eq(second.minion_damage_mult, first.minion_damage_mult, 0.001)
	assert_eq(SkillTree.STARTER_MINIONS, ["archer"] as Array[String], "starter list must be untouched")


func test_purchase_then_build_reflects_unlock_end_to_end() -> void:
	# Closes the seam: gating (purchase) and aggregation (build) agree.
	MetaState.grave_bones = 1000
	assert_false(SkillTree.build_run_modifiers().has_minion("golem"))
	assert_true(SkillTree.purchase("unlock_golem"))
	assert_true(SkillTree.build_run_modifiers().has_minion("golem"))
