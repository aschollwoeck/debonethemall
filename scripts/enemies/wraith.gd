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
	_shadow(0.16)   # barely touches the ground — it floats
	# fades as it debones; hit-flash brightens
	var alpha: float = [0.62, 0.42, 0.28][stage] if stage < 3 else 0.28
	var body := GHOST.lerp(Color.WHITE, _hit_flash * 0.6)
	body.a = alpha
	var crown := Color(body.r, body.g, body.b, min(1.0, alpha + 0.22))
	var eye := Color(0.85, 1.0, 0.9, min(1.0, alpha + 0.4))
	match stage:
		0:
			_draw_ghost(body, crown, eye, 1.0, 5)
		1:
			_draw_ghost(body, crown, eye, 0.8, 6)   # smaller, more ragged
		_:
			# wisp: a fading smear, one dim eye
			draw_circle(Vector2(0, -2), 2.4, body)
			draw_line(Vector2(-3, 1), Vector2(2, 3), body, 1.0)
			draw_circle(Vector2(0, -3), 0.8, eye)


## Hooded shroud tapering to a tattered lower edge. `sc` scales it, `tails` sets the raggedness.
func _draw_ghost(body: Color, crown: Color, eye: Color, sc: float, tails: int) -> void:
	var pts := PackedVector2Array([
		Vector2(-6 * sc, 2), Vector2(-6 * sc, -6 * sc), Vector2(0, -13 * sc),
		Vector2(6 * sc, -6 * sc), Vector2(6 * sc, 2)])
	for i in range(tails + 1):                       # tattered hem
		var x := lerpf(6.0 * sc, -6.0 * sc, float(i) / tails)
		var y := 2.0 + (3.5 if i % 2 == 0 else 0.5)
		pts.append(Vector2(x, y))
	draw_colored_polygon(pts, body)
	draw_colored_polygon(PackedVector2Array([                       # lit crown
		Vector2(-3 * sc, -8 * sc), Vector2(0, -13 * sc), Vector2(3 * sc, -8 * sc), Vector2(0, -6 * sc)]), crown)
	draw_circle(Vector2(-2 * sc, -7 * sc), 1.0, eye)                # glowing eyes
	draw_circle(Vector2(2 * sc, -7 * sc), 1.0, eye)
