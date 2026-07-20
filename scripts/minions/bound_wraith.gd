extends Minion
## Bound Wraith — Necrotic, single-target, medium range/rate. The answer to ethereal foes:
## physical minions rattle through wraiths, but necrotic bolts tear them apart.
## Unlocked via the meta skill tree (not available on a fresh save).

const BONE := Color("d8d2c4")
const NECRO := Color("9be7a0")   # sickly necrotic green
const DARK := Color("161022")


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
	# pedestal
	draw_rect(Rect2(-5, 4, 10, 3), DARK)
	# spectral shroud (a rounded hood tapering to wisps)
	var shroud := PackedVector2Array([
		Vector2(-5, 4), Vector2(-5, -4), Vector2(0, -9), Vector2(5, -4), Vector2(5, 4),
		Vector2(3, 2), Vector2(1, 5), Vector2(-1, 2), Vector2(-3, 5),
	])
	draw_colored_polygon(shroud, Color(NECRO.r, NECRO.g, NECRO.b, 0.35))
	draw_polyline(shroud, NECRO, 1.0)
	# glowing eyes
	draw_circle(Vector2(-1.6, -4), 0.9, NECRO)
	draw_circle(Vector2(1.6, -4), 0.9, NECRO)
	# bound soul orb
	draw_circle(Vector2(0, 0), 1.6, Color(1, 1, 1, 0.85))
