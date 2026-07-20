extends GutTest
## Tests the branching upgrade system (GDD §7): tier/branch progression, the two-then-one
## option shape, per-tier costs, and that branches produce distinct stat changes.

const ARCHER := preload("res://scripts/minions/bone_archer.gd")
const GOLEM := preload("res://scripts/minions/bone_mill_golem.gd")


func test_starts_unbranched_with_two_options() -> void:
	var a: Minion = ARCHER.new()
	add_child_autofree(a)
	assert_eq(a.tier, 0)
	assert_false(a.is_maxed())
	var opts := a.upgrade_options()
	assert_eq(opts.size(), 2, "tier 0 offers both branches")
	assert_eq(opts[0]["id"], "a")
	assert_eq(opts[1]["id"], "b")


func test_volley_branch_progression_adds_targets() -> void:
	var a: Minion = ARCHER.new()
	add_child_autofree(a)
	assert_eq(a.targets, 1)
	a.apply_upgrade_choice("a")             # Volley I
	assert_eq(a.branch, "a")
	assert_eq(a.tier, 1)
	assert_eq(a.targets, 2)
	var opts := a.upgrade_options()
	assert_eq(opts.size(), 1, "tier 1 offers only the deepen option")
	assert_eq(opts[0]["id"], "a")
	a.apply_upgrade_choice("a")             # Volley II
	assert_eq(a.tier, 2)
	assert_eq(a.targets, 3)
	assert_true(a.is_maxed())
	assert_eq(a.upgrade_options().size(), 0)


func test_piercer_branch_boosts_damage_stays_single_target() -> void:
	var a: Minion = ARCHER.new()
	add_child_autofree(a)
	var base: float = a.damage
	a.apply_upgrade_choice("b")             # Piercer I: ×1.8
	assert_almost_eq(a.damage, base * 1.8, 0.01)
	assert_eq(a.targets, 1, "Piercer stays single-target")


func test_cost_of_reflects_tier() -> void:
	var a: Minion = ARCHER.new()
	add_child_autofree(a)
	assert_eq(a.cost_of("a"), 55)           # tier 0 → cost1
	a.apply_upgrade_choice("a")
	assert_eq(a.cost_of("a"), 95)           # tier 1 → cost2


func test_cannot_switch_branches_midway() -> void:
	var a: Minion = ARCHER.new()
	add_child_autofree(a)
	a.apply_upgrade_choice("a")             # committed to branch "a"
	var targets_before: int = a.targets
	a.apply_upgrade_choice("b")             # wrong branch — must be ignored
	assert_eq(a.tier, 1)
	assert_eq(a.branch, "a")
	assert_eq(a.targets, targets_before)


func test_golem_branches_differ() -> void:
	var wide: Minion = GOLEM.new()
	add_child_autofree(wide)
	var crush: Minion = GOLEM.new()
	add_child_autofree(crush)
	var base_range: float = wide.attack_range
	var base_dmg: float = crush.damage
	wide.apply_upgrade_choice("a")          # Wider Grind — range
	crush.apply_upgrade_choice("b")         # Bone Crusher — damage
	assert_gt(wide.attack_range, base_range)
	assert_gt(crush.damage, base_dmg)
	assert_almost_eq(crush.attack_range, base_range, 0.01, "Crusher doesn't add range at I")
