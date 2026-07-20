extends Enemy
## Skeletal dog — UNARMORED, fast rusher. Strong target for Pierce (shreds soft), poor for
## the slow Blunt golem (too fast to pin). Debones: whole hound → split halves sliding → gone.

func _ready() -> void:
	max_hp = 32.0
	armor_type = CombatTypes.Armor.UNARMORED
	move_speed = 66.0
	reward = 6
	bones_harvest = 1
	leak_damage = 1
	stage_thresholds = [0.5]              # two stages: whole → split
	stage_speed_mult = [1.0, 1.15]        # split halves keep sliding on momentum
	super._ready()


func _draw() -> void:
	_shadow()
	var f := _hit_flash * 0.7
	var ol := Color("241f19").lerp(Color.WHITE, f * 0.5)
	var lo := Color("8f856a").lerp(Color.WHITE, f)
	var mid := Color("c8bd9c").lerp(Color.WHITE, f)
	if stage == 0:
		_draw_whole(ol, lo, mid)
	else:
		_draw_split(ol, lo, mid)


func _draw_whole(ol: Color, lo: Color, mid: Color) -> void:
	draw_line(Vector2(-6, -1), Vector2(5, -1), mid, 1.5)    # spine
	for x in [-4.0, -1.0, 2.0]:                             # ribs
		draw_line(Vector2(x, -3), Vector2(x, 1), lo, 1.0)
	# skull + snout, facing the direction of travel (right)
	draw_circle(Vector2(6, -2), 2.6, mid)
	draw_line(Vector2(8, -2), Vector2(11, -1), mid, 1.0)    # snout
	draw_circle(Vector2(6, -2.5), 0.7, ol)                 # eye
	draw_line(Vector2(5, -4), Vector2(6, -5), lo, 1.0)      # ear
	# running legs (splayed)
	draw_line(Vector2(-4, 1), Vector2(-6, 4), mid, 1.0)
	draw_line(Vector2(-3, 1), Vector2(-1, 4), lo, 1.0)
	draw_line(Vector2(2, 1), Vector2(0, 4), mid, 1.0)
	draw_line(Vector2(3, 1), Vector2(5, 4), lo, 1.0)
	draw_line(Vector2(-6, -1), Vector2(-9, -3), lo, 1.0)    # tail


func _draw_split(ol: Color, lo: Color, mid: Color) -> void:
	# front half skids ahead...
	draw_line(Vector2(2, -1), Vector2(6, -1), mid, 1.5)
	draw_circle(Vector2(7, -2), 2.4, mid)
	draw_line(Vector2(9, -2), Vector2(11, -1), mid, 1.0)
	draw_circle(Vector2(7, -2.5), 0.6, ol)
	draw_line(Vector2(3, 1), Vector2(2, 4), mid, 1.0)
	draw_line(Vector2(5, 1), Vector2(6, 4), lo, 1.0)
	# ...rear half tumbles behind
	draw_line(Vector2(-8, 0), Vector2(-4, 0), mid, 1.5)
	draw_line(Vector2(-8, 0), Vector2(-11, -2), lo, 1.0)   # tail
	draw_line(Vector2(-6, 1), Vector2(-7, 5), mid, 1.0)
	draw_line(Vector2(-4, 1), Vector2(-3, 5), lo, 1.0)
