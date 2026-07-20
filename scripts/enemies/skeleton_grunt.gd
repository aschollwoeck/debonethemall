extends Enemy
## Skeleton grunt — BONE armor. Weak to Blunt (shatters), resists Pierce (rattles through
## ribs). Debones in three stages: whole skeleton → skull-off crawler (slower) → bone pile.

const BONE := Color("e8e2d0")
const DARK := Color("1a141f")


func _ready() -> void:
	max_hp = 70.0
	armor_type = CombatTypes.Armor.BONE
	move_speed = 34.0
	reward = 8
	bones_harvest = 2
	leak_damage = 1
	stage_thresholds = [0.66, 0.33]
	stage_speed_mult = [1.0, 0.6, 0.45]   # loses legs → crawls slower (mechanical debone)
	super._ready()


func _draw() -> void:
	var col := BONE.lerp(Color.WHITE, _hit_flash * 0.8)
	match stage:
		0:
			_draw_whole(col)
		1:
			_draw_crawler(col)
		_:
			_draw_pile(col)


func _draw_whole(col: Color) -> void:
	# skull
	draw_circle(Vector2(0, -8), 4.0, col)
	draw_circle(Vector2(-1.5, -8), 1.0, DARK)
	draw_circle(Vector2(1.5, -8), 1.0, DARK)
	# spine
	draw_line(Vector2(0, -4), Vector2(0, 4), col, 1.5)
	# ribs
	for y in [-2.0, 0.0, 2.0]:
		draw_line(Vector2(-3, y), Vector2(3, y), col, 1.0)
	# legs
	draw_line(Vector2(0, 4), Vector2(-3, 9), col, 1.5)
	draw_line(Vector2(0, 4), Vector2(3, 9), col, 1.5)


func _draw_crawler(col: Color) -> void:
	# no skull, dragging ribcage
	draw_line(Vector2(-4, 2), Vector2(4, 2), col, 1.5)
	for x in [-3.0, 0.0, 3.0]:
		draw_line(Vector2(x, 0), Vector2(x, 4), col, 1.0)
	# one clawing arm
	draw_line(Vector2(4, 2), Vector2(7, 5), col, 1.0)


func _draw_pile(col: Color) -> void:
	draw_line(Vector2(-4, 5), Vector2(3, 6), col, 1.0)
	draw_line(Vector2(-3, 7), Vector2(4, 5), col, 1.0)
	draw_circle(Vector2(2, 5), 1.5, col)
