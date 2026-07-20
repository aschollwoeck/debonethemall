extends Enemy
## Skeleton grunt — BONE armor. Weak to Blunt (shatters), resists Pierce (rattles through
## ribs). Debones in three stages: whole skeleton → skull-off crawler (slower) → bone pile.

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
	_shadow()
	var f := _hit_flash * 0.7
	var ol := Color("241f19").lerp(Color.WHITE, f * 0.5)
	var lo := Color("8f856a").lerp(Color.WHITE, f)
	var mid := Color("c8bd9c").lerp(Color.WHITE, f)
	var hi := Color("efe6cd").lerp(Color.WHITE, f)
	match stage:
		0:
			_draw_whole(ol, lo, mid, hi)
		1:
			_draw_crawler(ol, lo, mid)
		_:
			_draw_pile(ol, lo, mid)


func _draw_whole(ol: Color, lo: Color, mid: Color, hi: Color) -> void:
	# marching legs
	draw_line(Vector2(-1, 3), Vector2(-3, 9), mid, 1.5)
	draw_line(Vector2(1, 3), Vector2(3, 8), mid, 1.5)
	draw_rect(Rect2(-2, 2, 4, 2), lo)                 # pelvis
	draw_line(Vector2(0, -4), Vector2(0, 3), mid, 1.5)  # spine
	for ry in [-3.0, -1.0, 1.0]:                      # ribs
		draw_line(Vector2(-3, ry), Vector2(3, ry + 0.4), lo, 1.0)
	draw_line(Vector2(-1, -3), Vector2(-4, 1), mid, 1.0)  # arms
	draw_line(Vector2(1, -3), Vector2(4, 0), mid, 1.0)
	# skull
	draw_circle(Vector2(0, -8), 3.4, mid)
	draw_circle(Vector2(-1, -9), 1.1, hi)             # highlight
	draw_rect(Rect2(-2, -9, 1.4, 1.4), ol)            # eye sockets
	draw_rect(Rect2(0.6, -9, 1.4, 1.4), ol)
	draw_rect(Rect2(-1.2, -6, 2.4, 1), ol)            # grinning teeth


func _draw_crawler(ol: Color, lo: Color, mid: Color) -> void:
	# headless torso dragging itself forward, one clawing arm
	draw_line(Vector2(-5, 3), Vector2(4, 3), mid, 1.5)   # dragging ribcage
	for x in [-3.0, -1.0, 1.0, 3.0]:
		draw_line(Vector2(x, 1), Vector2(x, 4), lo, 1.0)
	draw_line(Vector2(4, 3), Vector2(6, 2), mid, 1.0)    # neck stub (no skull)
	draw_line(Vector2(5, 3), Vector2(8, 5), mid, 1.0)    # clawing arm
	draw_line(Vector2(8, 5), Vector2(9.5, 4), lo, 1.0)   # claw
	draw_line(Vector2(-5, 3), Vector2(-7, 6), lo, 1.0)   # dragging leg
	# the gag: the skull popped off and rolled behind, still grinning
	draw_circle(Vector2(-8, 4), 2.4, mid)
	draw_rect(Rect2(-9, 3.4, 1, 1), ol)
	draw_rect(Rect2(-7.4, 3.4, 1, 1), ol)
	draw_rect(Rect2(-8.4, 5, 1.6, 0.7), ol)              # grin


func _draw_pile(ol: Color, lo: Color, mid: Color) -> void:
	# collapsed heap, skull half-buried grinning up
	draw_line(Vector2(-5, 5), Vector2(3, 6), lo, 1.0)
	draw_line(Vector2(-3, 7), Vector2(4, 5), lo, 1.0)
	draw_line(Vector2(-1, 4), Vector2(2, 7), lo, 1.0)
	draw_circle(Vector2(1, 6), 2.2, mid)
	draw_rect(Rect2(0.2, 5.4, 0.9, 0.9), ol)
	draw_rect(Rect2(1.6, 5.4, 0.9, 0.9), ol)
