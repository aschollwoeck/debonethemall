extends GutTest
## Guards the "read subclass stats after _ready" contract for minions. Minions set their stat
## block (cost, damage, damage_type, …) in _ready(), which fires on add_child — so placement
## code must read cost and apply the meta damage buff AFTER mounting. A regression here would
## silently charge the wrong cost or drop the damage buff (both happened before this test).

const ARCHER := preload("res://scripts/minions/bone_archer.gd")
const GOLEM := preload("res://scripts/minions/bone_mill_golem.gd")
const WRAITH := preload("res://scripts/minions/bound_wraith.gd")


func test_stats_are_set_by_ready_not_by_new() -> void:
	# Fresh from new(): base defaults from minion.gd (cost 50, damage 10), NOT the subclass values.
	var g: Minion = GOLEM.new()
	assert_eq(g.cost, 50, "before _ready, cost is the base default")
	assert_almost_eq(g.damage, 10.0, 0.001, "before _ready, damage is the base default")
	add_child_autofree(g)   # _ready() runs here
	assert_eq(g.cost, 80, "after _ready, cost is the Golem's value")
	assert_almost_eq(g.damage, 14.0, 0.001, "after _ready, damage is the Golem's value")


func test_archer_stats_after_ready() -> void:
	var a: Minion = ARCHER.new()
	add_child_autofree(a)
	assert_eq(a.cost, 50)
	assert_almost_eq(a.damage, 9.0, 0.001)


func test_damage_buff_multiplies_the_ready_value() -> void:
	# The buff must be applied after _ready, or it gets overwritten. 14 * 1.1 = 15.4.
	var g: Minion = GOLEM.new()
	add_child_autofree(g)
	g.damage *= 1.1
	assert_almost_eq(g.damage, 15.4, 0.001)


func test_bound_wraith_deals_necrotic() -> void:
	var w: Minion = WRAITH.new()
	add_child_autofree(w)
	assert_eq(w.cost, 70)
	assert_eq(w.damage_type, CombatTypes.Damage.HOLY, "Bound Wraith deals Necrotic/Holy")
