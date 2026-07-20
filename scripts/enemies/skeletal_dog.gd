extends Enemy
## Skeletal dog — UNARMORED, fast rusher. Strong target for Pierce (shreds soft), poor for
## the slow Blunt golem (too fast to pin). Debones: whole hound → split halves sliding → gone.

const BONE := Color("d8d2c4")
const DARK := Color("1a141f")


func _ready() -> void:
	max_hp = 18.0
	armor_type = CombatTypes.Armor.UNARMORED
	move_speed = 66.0
	reward = 6
	bones_harvest = 1
	leak_damage = 1
	stage_thresholds = [0.5]              # two stages: whole → split
	stage_speed_mult = [1.0, 1.15]        # split halves keep sliding on momentum
	super._ready()


func _draw() -> void:
	var col := BONE.lerp(Color.WHITE, _hit_flash * 0.8)
	if stage == 0:
		_draw_whole(col)
	else:
		_draw_split(col)


func _draw_whole(col: Color) -> void:
	# body spine
	draw_line(Vector2(-6, 0), Vector2(5, 0), col, 1.5)
	# ribs
	for x in [-4.0, -1.0, 2.0]:
		draw_line(Vector2(x, -2), Vector2(x, 2), col, 1.0)
	# skull (snout forward, moving right)
	draw_circle(Vector2(6, -1), 2.5, col)
	draw_line(Vector2(8, -1), Vector2(10, 0), col, 1.0)   # snout
	draw_circle(Vector2(6, -1.5), 0.7, DARK)              # eye
	# legs
	draw_line(Vector2(-4, 2), Vector2(-5, 5), col, 1.0)
	draw_line(Vector2(2, 2), Vector2(3, 5), col, 1.0)


func _draw_split(col: Color) -> void:
	# front half (skull) skidding ahead
	draw_circle(Vector2(5, -1), 2.5, col)
	draw_line(Vector2(2, 0), Vector2(5, 0), col, 1.5)
	# rear half trailing
	draw_line(Vector2(-7, 1), Vector2(-3, 1), col, 1.5)
	draw_line(Vector2(-5, 1), Vector2(-6, 4), col, 1.0)
