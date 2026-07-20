extends Minion
## Bone-Mill Golem — Blunt, AoE, slow and short-ranged, pricey.
## Shatters bone (skeleton hordes); mediocre vs. fast soft targets that slip past its grind.

const STONE := Color("8a8f7a")
const BONE := Color("d8d2c4")

var _pulse: float = 0.0   # >0 while the grind visual plays


func _ready() -> void:
	display_name = "Bone-Mill Golem"
	damage = 14.0
	damage_type = CombatTypes.Damage.BLUNT
	attack_rate = 0.7
	attack_range = 52.0
	cost = 80
	upgrade_cost = 90
	projectile_color = STONE


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _pulse > 0.0:
		_pulse = max(0.0, _pulse - delta * 3.0)
		queue_redraw()


## AoE: grind every enemy currently in range.
func _attack(_target: Enemy) -> void:
	var hit_any := false
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy := e as Enemy
		if enemy == null:
			continue
		if global_position.distance_to(enemy.global_position) <= attack_range:
			enemy.take_damage(damage, damage_type)
			hit_any = true
	if hit_any:
		_pulse = 1.0
		queue_redraw()


func _draw() -> void:
	# grind shockwave first (under body), then range ring + body via base
	if _pulse > 0.0:
		draw_arc(Vector2.ZERO, attack_range * (1.0 - _pulse), 0, TAU, 40,
			Color(0.9, 0.85, 0.7, 0.35 * _pulse), 2.0)
	super._draw()


func _draw_body() -> void:
	# bulky stone golem
	draw_rect(Rect2(-6, -6, 12, 12), STONE)
	draw_rect(Rect2(-6, -6, 12, 12), Color(0, 0, 0, 0.25), false, 1.0)
	# grinding maw
	draw_rect(Rect2(-4, -1, 8, 3), Color("2a241f"))
	# bone shards embedded
	draw_line(Vector2(-3, -4), Vector2(-1, -2), BONE, 1.0)
	draw_line(Vector2(2, -4), Vector2(4, -2), BONE, 1.0)
