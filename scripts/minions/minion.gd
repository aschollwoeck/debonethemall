extends Node2D
class_name Minion
## Base raised-minion tower. Carries a stat block (GDD §8), scans the "enemies" group for
## targets in range, and attacks on cooldown. Subclasses define how they attack (projectile
## vs. AoE pulse) and how they draw.
##
## Upgrades branch (GDD §7): the first upgrade picks one of two specializations (branch "a" or
## "b"); a second tier deepens that branch. Subclasses declare branches via `_branches()` and
## apply their effects in `_apply_branch()`.

@export var display_name: String = "Minion"
@export var damage: float = 10.0
@export var damage_type: CombatTypes.Damage = CombatTypes.Damage.PIERCE
@export var attack_rate: float = 1.0        ## attacks per second
@export var attack_range: float = 70.0
@export var targets: int = 1                ## how many enemies it hits per attack
@export var cost: int = 50
@export var projectile_color: Color = Color("f2e9c8")

## Upgrade branch state: branch "" until chosen then "a"/"b"; tier 0 (base) → 1 → 2 (maxed).
var branch: String = ""
var tier: int = 0

var _cooldown: float = 0.0
var _show_range: bool = false


func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta
	if _cooldown <= 0.0:
		var tgts := _acquire_targets(targets)
		if not tgts.is_empty():
			_fire(tgts)
			_cooldown = 1.0 / max(0.05, attack_rate)


## The up-to-`n` enemies in range that are furthest along the path (closest to leaking).
func _acquire_targets(n: int) -> Array:
	var in_range: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy := e as Enemy
		if enemy != null and global_position.distance_to(enemy.global_position) <= attack_range:
			in_range.append(enemy)
	in_range.sort_custom(func(a, b): return a.get_progress() > b.get_progress())
	return in_range.slice(0, n)


## Override in subclasses. Default: direct hit on each target (no projectile).
func _fire(target_list: Array) -> void:
	for enemy in target_list:
		enemy.take_damage(damage, damage_type)


# ---------------------------------------------------------------- branching upgrades

## Override: {"a": {"name","cost1","cost2"}, "b": {...}}. Empty = no upgrades.
func _branches() -> Dictionary:
	return {}


## Override: apply branch `id`'s effect at the given tier (1 or 2) by mutating the stat block.
func _apply_branch(_id: String, _tier: int) -> void:
	pass


## True when there are no further upgrades (tier maxed, or a minion with no branches).
func is_maxed() -> bool:
	return tier >= 2 or _branches().is_empty()


## The upgrade choices available right now: [{id, label, cost}]. Empty when maxed.
func upgrade_options() -> Array:
	var b := _branches()
	if b.is_empty() or tier >= 2:
		return []
	if tier == 0:
		return [
			{"id": "a", "label": b["a"]["name"], "cost": int(b["a"]["cost1"])},
			{"id": "b", "label": b["b"]["name"], "cost": int(b["b"]["cost1"])},
		]
	return [{"id": branch, "label": "%s II" % b[branch]["name"], "cost": int(b[branch]["cost2"])}]


## Cost of choosing option `id` right now.
func cost_of(id: String) -> int:
	var b := _branches()
	return int(b[id]["cost1"]) if tier == 0 else int(b[id]["cost2"])


## Applies an upgrade choice. Returns true if it took effect (false for an invalid/wrong-branch
## id), so callers charge only on success.
func apply_upgrade_choice(id: String) -> bool:
	if tier == 0:
		branch = id
		tier = 1
		_apply_branch(id, 1)
		return true
	elif tier == 1 and id == branch:
		tier = 2
		_apply_branch(id, 2)
		return true
	return false


# ---------------------------------------------------------------- drawing

func set_range_visible(v: bool) -> void:
	_show_range = v
	queue_redraw()


func _draw() -> void:
	if _show_range:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 1, 0.06))
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 48, Color(1, 1, 1, 0.18), 1.0)
	_draw_ground()
	_draw_body()
	# pips marking upgrade tier, above the sprite
	for i in tier:
		draw_circle(Vector2(-4 + i * 4.0, -16), 1.2, Color(0.95, 0.85, 0.4))


## Cast shadow + a bone-ringed plot under the minion (shared grounding for all minions).
func _draw_ground() -> void:
	_ellipse(Vector2(0, 8), 9.0, 3.4, Color(0, 0, 0, 0.4))     # shadow
	_ellipse(Vector2(0, 7), 8.0, 3.0, Color("15121f"))         # plot base
	_ellipse(Vector2(0, 6.5), 6.0, 2.2, Color("201f2b"))       # plot top
	for i in 6:                                                # ring of little bones
		var a := i * TAU / 6.0
		var p := Vector2(cos(a) * 7.0, 7.0 + sin(a) * 3.0)
		draw_rect(Rect2(p.x - 1.0, p.y - 0.5, 2.0, 1.0), Color("3a3524"))


func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := i * TAU / 16.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)


## Override in subclasses to render the minion (above the plot; origin at its base).
func _draw_body() -> void:
	draw_circle(Vector2(0, -6), 6.0, Color.WHITE)
