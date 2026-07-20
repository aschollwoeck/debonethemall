extends Node2D
class_name Minion
## Base raised-minion tower. Carries a stat block (GDD §8), scans the "enemies" group for a
## target in range, and attacks on cooldown. Subclasses define how they attack (single-target
## projectile vs. AoE pulse) and how they draw. One flat upgrade tier for M0.

@export var display_name: String = "Minion"
@export var damage: float = 10.0
@export var damage_type: CombatTypes.Damage = CombatTypes.Damage.PIERCE
@export var attack_rate: float = 1.0        ## attacks per second
@export var attack_range: float = 70.0
@export var cost: int = 50
@export var upgrade_cost: int = 60
@export var projectile_color: Color = Color("f2e9c8")

var level: int = 1
var _cooldown: float = 0.0
var _show_range: bool = false


func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta
	if _cooldown <= 0.0:
		var target := _acquire_target()
		if target != null:
			_attack(target)
			_cooldown = 1.0 / max(0.05, attack_rate)


## Picks the enemy in range that is furthest along the path (closest to leaking).
func _acquire_target() -> Enemy:
	var best: Enemy = null
	var best_progress := -1.0
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy := e as Enemy
		if enemy == null:
			continue
		if global_position.distance_to(enemy.global_position) <= attack_range:
			var p := enemy.get_progress()
			if p > best_progress:
				best_progress = p
				best = enemy
	return best


## Override in subclasses. Default: single-target hit (no projectile).
func _attack(target: Enemy) -> void:
	target.take_damage(damage, damage_type)


func can_upgrade() -> bool:
	return level < 2   # M0: one upgrade tier


## Applies the flat M0 upgrade. Subclasses may extend for bespoke scaling.
func apply_upgrade() -> void:
	level += 1
	damage *= 1.6
	attack_range *= 1.15


func set_range_visible(v: bool) -> void:
	_show_range = v
	queue_redraw()


func _draw() -> void:
	if _show_range:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 1, 0.06))
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 48, Color(1, 1, 1, 0.18), 1.0)
	_draw_body()


## Override in subclasses to render the minion.
func _draw_body() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color.WHITE)
