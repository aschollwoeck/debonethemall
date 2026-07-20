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


## Fine pixel art per debone stage (art-direction §6/§7): whole running hound → split halves.
func _author_stage(st: int) -> Image:
	var out := Color("241f19")
	var lo := Color("8f856a")
	var mid := Color("c8bd9c")
	var hi := Color("efe6cd")
	if st == 0:
		# whole skeletal hound, facing the direction of travel (right)
		var img := PixelArt.canvas(44, 24)
		PixelArt.hline(img, 8, 8, 27, mid); PixelArt.hline(img, 8, 9, 27, lo)   # spine
		PixelArt.hline(img, 10, 6, 22, mid)                                     # back
		for rx in [12, 16, 20, 24, 28]:                                         # ribs
			PixelArt.vline(img, rx, 6, 6, lo)
		PixelArt.line(img, 8, 8, 3, 4, lo)                                      # tail
		PixelArt.line(img, 12, 11, 10, 21, mid); PixelArt.line(img, 15, 11, 16, 21, lo)  # hind legs
		PixelArt.line(img, 28, 11, 26, 21, mid); PixelArt.line(img, 31, 11, 32, 21, lo)  # front legs
		for fx in [10, 16, 26, 32]:                                             # paws
			PixelArt.px(img, fx, 21, mid)
		PixelArt.rect(img, 33, 5, 6, 6, mid); PixelArt.hline(img, 33, 5, 6, hi) # skull
		PixelArt.rect(img, 39, 8, 4, 2, mid)                                    # snout
		PixelArt.rect(img, 35, 7, 1, 2, out)                                    # eye
		PixelArt.line(img, 34, 5, 33, 2, lo)                                    # ear
		PixelArt.px(img, 42, 9, out)                                            # nostril
		return img
	# split: front half skids ahead (right), rear half tumbles behind (left)
	var img := PixelArt.canvas(48, 24)
	# --- front half ---
	PixelArt.hline(img, 28, 9, 11, mid); PixelArt.hline(img, 28, 10, 11, lo)
	PixelArt.vline(img, 30, 8, 4, lo); PixelArt.vline(img, 34, 8, 4, lo)        # ribs
	PixelArt.rect(img, 37, 6, 6, 6, mid); PixelArt.hline(img, 37, 6, 6, hi)     # skull
	PixelArt.rect(img, 43, 9, 3, 2, mid)                                        # snout
	PixelArt.rect(img, 39, 8, 1, 2, out)                                        # eye
	PixelArt.line(img, 30, 12, 28, 21, mid); PixelArt.line(img, 34, 12, 36, 21, lo)  # front legs
	PixelArt.px(img, 28, 21, mid); PixelArt.px(img, 36, 21, mid)
	PixelArt.vline(img, 28, 7, 6, out)                                          # torn edge
	# --- rear half ---
	PixelArt.hline(img, 6, 12, 11, mid); PixelArt.hline(img, 6, 13, 11, lo)
	PixelArt.line(img, 6, 12, 2, 9, lo)                                         # tail
	PixelArt.vline(img, 9, 11, 3, lo); PixelArt.vline(img, 13, 11, 3, lo)       # ribs
	PixelArt.line(img, 9, 14, 7, 21, mid); PixelArt.line(img, 13, 14, 15, 21, lo)    # hind legs
	PixelArt.px(img, 7, 21, mid); PixelArt.px(img, 15, 21, mid)
	PixelArt.vline(img, 16, 10, 6, out)                                         # torn edge
	return img
