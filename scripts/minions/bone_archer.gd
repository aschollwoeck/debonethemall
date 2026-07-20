extends Minion
## Bone Archer — Pierce, single-target, cheap and fast, long range.
## Great vs. soft (skeletal dogs); rattles uselessly through bone (skeleton grunts).


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
	var ol := Color("241f19")
	var lo := Color("9c9276")
	var mid := Color("d8cdae")
	var hi := Color("f2ead2")
	# quiver of arrows slung on the back
	draw_line(Vector2(-4, -12), Vector2(-6, -2), Color("5a4a30"), 2.0)
	draw_line(Vector2(-6, -13), Vector2(-4, -11), lo, 1.0)
	draw_line(Vector2(-7, -12), Vector2(-5, -10), lo, 1.0)
	# legs
	draw_line(Vector2(-1, 2), Vector2(-3, 6), mid, 1.5)
	draw_line(Vector2(1, 2), Vector2(2, 6), mid, 1.5)
	# spine + ribcage
	draw_line(Vector2(0, -9), Vector2(0, 3), mid, 2.0)
	for ry in [-6.0, -4.0, -2.0]:
		draw_line(Vector2(-3, ry), Vector2(3, ry + 0.5), lo, 1.0)
	# skull
	draw_circle(Vector2(0, -11), 3.2, mid)
	draw_circle(Vector2(-1, -12), 1.2, hi)          # highlight
	draw_rect(Rect2(-2, -12, 1.4, 1.4), ol)         # eye sockets
	draw_rect(Rect2(0.6, -12, 1.4, 1.4), ol)
	draw_rect(Rect2(-1, -9, 2, 1), ol)              # jaw
	# bone bow on the right, arrow nocked
	draw_arc(Vector2(6, -6), 7.0, -1.2, 1.2, 14, mid, 1.6)
	draw_line(Vector2(6, -12), Vector2(6, 0), Color(0.7, 0.65, 0.5), 1.0)   # string
	draw_line(Vector2(1, -6), Vector2(11, -6), hi, 1.0)                     # arrow shaft
	draw_rect(Rect2(10.5, -6.7, 1.6, 1.6), ol)                             # arrowhead
	draw_line(Vector2(0, -6), Vector2(4, -6), lo, 1.0)                      # drawing arm
