extends Minion
## Bone Archer — Pierce, single-target, cheap and fast, long range.
## Great vs. soft (skeletal dogs); rattles uselessly through bone (skeleton grunts).

const BONE := Color("e8e2d0")
const DARK := Color("1a141f")


func _ready() -> void:
	display_name = "Bone Archer"
	damage = 9.0
	damage_type = CombatTypes.Damage.PIERCE
	attack_rate = 1.6
	attack_range = 82.0
	cost = 50
	projectile_color = Color("cfe8b0")


func _fire(target_list: Array) -> void:
	for enemy in target_list:
		var bolt := Projectile.new()
		bolt.setup(enemy, damage, damage_type, projectile_color)
		bolt.global_position = global_position
		get_parent().add_child(bolt)


## Volley — fire at more enemies at once (great vs. swarms) · Piercer — single-target power.
func _branches() -> Dictionary:
	return {
		"a": {"name": "Volley", "cost1": 55, "cost2": 95},
		"b": {"name": "Piercer", "cost1": 55, "cost2": 95},
	}


func _apply_branch(id: String, t: int) -> void:
	if id == "a":            # Volley: +1 simultaneous target per tier
		targets += 1
		if t == 2:
			damage *= 1.2
	else:                    # Piercer: single-target burst
		damage *= 1.8 if t == 1 else 1.6
		if t == 2:
			attack_range *= 1.2


func _draw_body() -> void:
	# little pedestal
	draw_rect(Rect2(-5, 4, 10, 3), DARK)
	# skeleton torso
	draw_circle(Vector2(0, -6), 3.0, BONE)      # skull
	draw_line(Vector2(0, -3), Vector2(0, 4), BONE, 1.5)
	# bow (drawn as an arc on the right)
	draw_arc(Vector2(4, -1), 5.0, -PI / 2.2, PI / 2.2, 10, BONE, 1.2)
	draw_line(Vector2(4, -5), Vector2(4, 3), Color(0.8, 0.7, 0.5), 1.0)  # bowstring
