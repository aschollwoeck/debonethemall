extends Minion
## Bound Wraith — Necrotic, single-target, medium range/rate. The answer to ethereal foes:
## physical minions rattle through wraiths, but necrotic bolts tear them apart.
## Unlocked via the meta skill tree (not available on a fresh save).

const NECRO := Color("9be7a0")   # sickly necrotic green (projectile tint)


func _ready() -> void:
	display_name = "Bound Wraith"
	damage = 11.0
	damage_type = CombatTypes.NECROTIC   # necrotic == the HOLY matrix slot
	attack_rate = 1.2
	attack_range = 76.0
	cost = 70
	projectile_color = NECRO


func _fire(target_list: Array) -> void:
	for enemy in target_list:
		var bolt := Projectile.new()
		bolt.setup(enemy, damage, damage_type, projectile_color)
		bolt.global_position = global_position
		get_parent().add_child(bolt)


## Reaper — raw necrotic damage · Warden — greater reach & cadence.
func _branches() -> Dictionary:
	return {
		"a": {"name": "Reaper", "cost1": 75, "cost2": 120},
		"b": {"name": "Warden", "cost1": 75, "cost2": 120},
	}


func _apply_branch(id: String, t: int) -> void:
	if id == "a":            # Reaper: necrotic power
		damage *= 1.7 if t == 1 else 1.5
	else:                    # Warden: reach & cadence
		attack_range *= 1.2
		attack_rate *= 1.2 if t == 1 else 1.3


func _draw_body() -> void:
	var mid := Color(0.22, 0.66, 0.42, 0.72)
	var hi := Color(0.5, 0.92, 0.68, 0.85)
	var core := Color(0.85, 1.0, 0.9, 0.92)
	var hollow := Color(0.03, 0.09, 0.06, 0.75)
	# spectral shroud — hood down to wispy tails, hovering above the plot
	var shroud := PackedVector2Array([
		Vector2(-6, 3), Vector2(-6, -6), Vector2(-3, -12), Vector2(0, -14), Vector2(3, -12),
		Vector2(6, -6), Vector2(6, 3), Vector2(4, 0), Vector2(2, 4), Vector2(0, 0),
		Vector2(-2, 4), Vector2(-4, 0),
	])
	draw_colored_polygon(shroud, mid)
	# lit crown of the hood
	draw_colored_polygon(PackedVector2Array([
		Vector2(-3, -12), Vector2(0, -14), Vector2(3, -12), Vector2(0, -9)]), hi)
	# dark hollow where a face should be
	draw_colored_polygon(PackedVector2Array([
		Vector2(-3, -9), Vector2(0, -11), Vector2(3, -9), Vector2(2, -4), Vector2(-2, -4)]), hollow)
	# glowing eyes + bound soul orb
	draw_circle(Vector2(-1.8, -8), 1.0, core)
	draw_circle(Vector2(1.8, -8), 1.0, core)
	draw_circle(Vector2(0, -3), 1.6, core)
	# bound chains across the middle
	for cx in [-4.0, -1.0, 2.0]:
		draw_rect(Rect2(cx, -2, 2, 1.4), Color("4a4636"))
	draw_line(Vector2(-6, -1), Vector2(6, -2), Color("2a2620"), 1.0)
	draw_polyline(shroud + PackedVector2Array([shroud[0]]), hi, 1.0)
