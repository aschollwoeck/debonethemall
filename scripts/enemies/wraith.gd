extends Enemy
## Wraith — ETHEREAL. Physical attacks (Pierce/Blunt) and Fire rattle through it (×0.5);
## only Necrotic/Holy bites (×1.5). Forces the player to unlock the Bound Wraith — the
## "the tree gave me the tool I needed" moment. Debones by fading: whole → tattered → wisp.

const GHOST := Color("9be7a0")


func _ready() -> void:
	max_hp = 60.0
	armor_type = CombatTypes.Armor.ETHEREAL
	move_speed = 42.0
	reward = 10
	bones_harvest = 3            # worth more — it demands the right tool
	leak_damage = 1
	stage_thresholds = [0.66, 0.33]
	stage_speed_mult = [1.0, 1.0, 1.0]
	super._ready()


func _draw() -> void:
	# fades as it debones; hit-flash brightens
	var alpha: float = [0.7, 0.5, 0.32][stage] if stage < 3 else 0.32
	var col := GHOST.lerp(Color.WHITE, _hit_flash * 0.7)
	col.a = alpha
	match stage:
		0:
			_draw_shroud(col, 9.0, 6)
		1:
			_draw_shroud(col, 7.0, 4)
		_:
			# wisp: a small trailing smear
			draw_circle(Vector2(0, -2), 2.5, col)
			draw_line(Vector2(-3, 2), Vector2(2, 4), col, 1.0)
	# glowing eyes (dim as it fades)
	if stage < 2:
		var eye := Color(GHOST.r, GHOST.g, GHOST.b, min(1.0, alpha + 0.3))
		draw_circle(Vector2(-2, -3), 0.9, eye)
		draw_circle(Vector2(2, -3), 0.9, eye)


func _draw_shroud(col: Color, height: float, tails: int) -> void:
	var pts := PackedVector2Array([Vector2(-5, 2), Vector2(-5, -height * 0.4), Vector2(0, -height),
		Vector2(5, -height * 0.4), Vector2(5, 2)])
	# tattered lower edge
	for i in range(tails + 1):
		var x := lerpf(5.0, -5.0, float(i) / tails)
		var y := 2.0 + (3.0 if i % 2 == 0 else 0.0)
		pts.append(Vector2(x, y))
	draw_colored_polygon(pts, col)
