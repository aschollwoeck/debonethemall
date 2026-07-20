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


## Fine pixel art per debone stage (art-direction §6/§7): whole → skull-off crawler → bone pile.
func _author_stage(st: int) -> Image:
	var out := Color("241f19")
	var lo := Color("8f856a")
	var mid := Color("c8bd9c")
	var hi := Color("efe6cd")
	match st:
		0:
			# whole marching skeleton, grinning
			var img := PixelArt.canvas(28, 36)
			PixelArt.rect(img, 11, 26, 2, 9, mid); PixelArt.vline(img, 11, 26, 9, lo)   # legs
			PixelArt.rect(img, 15, 26, 2, 9, mid); PixelArt.vline(img, 16, 26, 9, lo)
			PixelArt.rect(img, 10, 33, 3, 2, mid); PixelArt.rect(img, 15, 33, 3, 2, mid) # feet
			PixelArt.rect(img, 11, 24, 6, 2, mid)                                        # pelvis
			PixelArt.vline(img, 13, 14, 10, lo); PixelArt.vline(img, 14, 14, 10, mid)    # spine
			for ry in [16, 18, 20, 22]:                                                  # ribs
				PixelArt.hline(img, 11, ry, 6, mid)
				PixelArt.px(img, 10, ry, lo); PixelArt.px(img, 17, ry, lo)
			PixelArt.hline(img, 10, 14, 8, hi)                                           # shoulders
			PixelArt.line(img, 11, 15, 8, 20, mid); PixelArt.line(img, 16, 15, 19, 20, mid) # arms
			PixelArt.px(img, 8, 20, lo); PixelArt.px(img, 19, 20, lo)
			PixelArt.rect(img, 10, 6, 8, 6, mid)                                         # skull
			PixelArt.hline(img, 10, 6, 8, hi); PixelArt.vline(img, 10, 6, 6, lo)
			PixelArt.rect(img, 11, 12, 6, 2, mid)                                        # jaw
			PixelArt.rect(img, 11, 8, 2, 2, out); PixelArt.rect(img, 15, 8, 2, 2, out)   # eyes
			PixelArt.px(img, 13, 11, out); PixelArt.px(img, 14, 11, out)                 # nasal
			PixelArt.hline(img, 12, 13, 4, out)                                          # grin
			return img
		1:
			# headless torso dragging itself forward; skull popped off, rolled behind (left)
			var img := PixelArt.canvas(40, 20)
			PixelArt.hline(img, 18, 10, 13, mid)                                         # ribcage top
			PixelArt.hline(img, 18, 12, 14, mid)                                         # spine
			PixelArt.hline(img, 18, 15, 13, lo)                                          # lower edge
			for rx in [20, 23, 26, 29]:                                                  # ribs
				PixelArt.vline(img, rx, 10, 5, lo)
			PixelArt.px(img, 31, 11, mid); PixelArt.px(img, 32, 12, lo)                  # neck stub
			PixelArt.line(img, 31, 13, 36, 16, mid)                                      # clawing arm
			PixelArt.px(img, 37, 16, lo); PixelArt.px(img, 37, 15, lo)                   # claw
			PixelArt.line(img, 18, 15, 14, 18, lo)                                       # dragging leg
			PixelArt.rect(img, 6, 10, 7, 6, mid)                                         # popped skull
			PixelArt.hline(img, 6, 10, 7, hi)
			PixelArt.rect(img, 7, 16, 5, 1, lo)                                          # jaw
			PixelArt.rect(img, 7, 12, 2, 2, out); PixelArt.rect(img, 10, 12, 2, 2, out)  # eyes
			PixelArt.hline(img, 8, 15, 3, out)                                           # grin
			return img
		_:
			# collapsed heap; skull half-buried, still grinning up
			var img := PixelArt.canvas(28, 16)
			PixelArt.line(img, 6, 11, 18, 12, lo)
			PixelArt.line(img, 8, 13, 20, 10, lo)
			PixelArt.line(img, 10, 9, 14, 13, lo)
			PixelArt.line(img, 15, 13, 22, 11, lo)
			PixelArt.rect(img, 13, 8, 6, 5, mid)                                         # skull
			PixelArt.hline(img, 13, 8, 6, hi)
			PixelArt.rect(img, 14, 10, 1, 2, out); PixelArt.rect(img, 17, 10, 1, 2, out) # eyes
			PixelArt.hline(img, 14, 12, 4, out)                                          # grin
			return img
