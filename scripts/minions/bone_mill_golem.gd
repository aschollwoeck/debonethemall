extends Minion
## Bone-Mill Golem — Blunt, AoE, slow and short-ranged, pricey.
## Shatters bone (skeleton hordes); mediocre vs. fast soft targets that slip past its grind.

const STONE := Color("8a8f7a")   # projectile/dust tint

var _pulse: float = 0.0   # >0 while the grind visual plays


func _ready() -> void:
	display_name = "Bone-Mill Golem"
	damage = 14.0
	damage_type = CombatTypes.Damage.BLUNT
	attack_rate = 0.7
	attack_range = 52.0
	cost = 80
	projectile_color = STONE


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _pulse > 0.0:
		_pulse = max(0.0, _pulse - delta * 3.0)
		queue_redraw()


## AoE: grind every enemy currently in range (ignores the target list — hits all).
func _fire(_target_list: Array) -> void:
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


## Wider Grind — bigger AoE radius · Bone Crusher — heavier damage & cadence.
func _branches() -> Dictionary:
	return {
		"a": {"name": "Wider Grind", "cost1": 90, "cost2": 140},
		"b": {"name": "Bone Crusher", "cost1": 90, "cost2": 140},
	}


func _apply_branch(id: String, t: int) -> void:
	if id == "a":            # Wider Grind: radius (and a little damage at II)
		attack_range *= 1.3
		if t == 2:
			damage *= 1.2
	else:                    # Bone Crusher: damage (and faster grind at II)
		damage *= 1.8 if t == 1 else 1.6
		if t == 2:
			attack_rate *= 1.25


func _draw() -> void:
	# grind shockwave first (under body), then range ring + body via base
	if _pulse > 0.0:
		draw_arc(Vector2.ZERO, attack_range * (1.0 - _pulse), 0, TAU, 40,
			Color(0.9, 0.85, 0.7, 0.35 * _pulse), 2.0)
	super._draw()


func _draw_body() -> void:
	var ol := Color("100e15")
	var lo := Color("26242c")
	var mid := Color("3c3a45")
	var hi := Color("55535f")
	var bone := Color("d8cdae")
	var crack := Color("63e39a")
	# shoulders / fists
	draw_rect(Rect2(-11, -8, 4, 9), lo); draw_rect(Rect2(7, -8, 4, 9), mid)
	draw_rect(Rect2(-11, 1, 4, 3), ol); draw_rect(Rect2(7, 1, 4, 3), ol)
	# hunched stone body
	draw_rect(Rect2(-8, -13, 16, 18), mid)
	draw_rect(Rect2(-8, -13, 4, 18), lo)                 # shadowed left
	draw_rect(Rect2(-8, -13, 16, 2), hi)                 # lit top edge
	draw_rect(Rect2(-8, -13, 16, 18), ol, false, 1.0)    # outline
	# grinding maw with bone teeth
	draw_rect(Rect2(-5, -3, 10, 5), Color("161219"))
	for tx in [-4.0, -2.0, 0.0, 2.0]:
		draw_rect(Rect2(tx, -3, 1, 2), bone)
		draw_rect(Rect2(tx + 1, 0, 1, 2), bone)
	# glowing necrotic cracks + eyes
	draw_line(Vector2(-3, -11), Vector2(-1, -6), crack, 1.0)
	draw_line(Vector2(3, -12), Vector2(2, -8), crack, 1.0)
	draw_rect(Rect2(-3.5, -10, 1.6, 1.6), crack); draw_rect(Rect2(2, -10, 1.6, 1.6), crack)
	# embedded bone shards
	draw_rect(Rect2(-6, -9, 3, 1), bone); draw_rect(Rect2(3, -6, 3, 1), bone)
