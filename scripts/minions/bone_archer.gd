extends Minion
## Bone Archer — Pierce, single-target, cheap and fast, long range.
## Great vs. soft (skeletal dogs); rattles uselessly through bone (skeleton grunts).


func _ready() -> void:
	display_name = "Bone Archer"
	damage = 9.0
	damage_type = CombatTypes.Damage.PIERCE
	attack_rate = 1.6
	attack_range = 82.0
	cost = 50
	projectile_color = Color("cfe8b0")


func _fire(target_list: Array) -> void:
	for enemy in target_list:
		var bolt := Projectile.new()
		bolt.setup(enemy, damage, damage_type, projectile_color)
		bolt.global_position = global_position
		get_parent().add_child(bolt)


## Volley — fire at more enemies at once (great vs. swarms) · Piercer — single-target power.
func _branches() -> Dictionary:
	return {
		"a": {"name": "Volley", "cost1": 55, "cost2": 95},
		"b": {"name": "Piercer", "cost1": 55, "cost2": 95},
	}


func _apply_branch(id: String, t: int) -> void:
	if id == "a":            # Volley: +1 simultaneous target per tier
		targets += 1
		if t == 2:
			damage *= 1.2
	else:                    # Piercer: single-target burst
		damage *= 1.8 if t == 1 else 1.6
		if t == 2:
			attack_range *= 1.2


## Fine pixel art (art-direction §6): a bone-white archer drawing a bone bow, quiver on the back.
func _author_body() -> Image:
	var out := Color("15121a")
	var lo := Color("8b8064")
	var mid := Color("c7bb96")
	var hi := Color("efe6cd")
	var bow := Color("b3a884")
	var lea := Color("4a3d26")
	var eye := Color("7bf0ad")
	var img := PixelArt.canvas(28, 42)
	# quiver slung on the back, arrows poking over the shoulder
	PixelArt.rect(img, 5, 14, 4, 9, lea)
	PixelArt.vline(img, 5, 14, 9, out)
	for ax in [6, 7, 8]:
		PixelArt.vline(img, ax, 9, 5, mid)
		PixelArt.px(img, ax, 9, eye)
	# legs + feet
	PixelArt.rect(img, 11, 29, 2, 12, mid); PixelArt.vline(img, 11, 29, 12, lo)
	PixelArt.rect(img, 15, 29, 2, 12, mid); PixelArt.vline(img, 16, 29, 12, lo)
	PixelArt.rect(img, 10, 40, 3, 2, mid); PixelArt.rect(img, 15, 40, 3, 2, mid)
	# pelvis
	PixelArt.rect(img, 11, 27, 6, 3, mid); PixelArt.hline(img, 11, 27, 6, hi)
	# spine + ribcage
	PixelArt.vline(img, 13, 13, 15, lo); PixelArt.vline(img, 14, 13, 15, mid)
	for ry in [16, 18, 20, 22, 24]:
		PixelArt.hline(img, 11, ry, 6, mid)
		PixelArt.px(img, 10, ry, lo); PixelArt.px(img, 17, ry, lo)
	# shoulders
	PixelArt.rect(img, 10, 13, 8, 2, mid); PixelArt.hline(img, 10, 13, 8, hi)
	# skull
	PixelArt.rect(img, 10, 4, 8, 6, mid)
	PixelArt.hline(img, 10, 4, 8, hi)
	PixelArt.vline(img, 10, 4, 6, lo)
	PixelArt.rect(img, 11, 10, 6, 2, mid)                                         # jaw
	PixelArt.rect(img, 11, 6, 2, 2, out); PixelArt.rect(img, 15, 6, 2, 2, out)    # eye sockets
	PixelArt.px(img, 12, 7, eye); PixelArt.px(img, 15, 7, eye)                    # eye glints
	PixelArt.px(img, 13, 9, out); PixelArt.px(img, 14, 9, out)                    # nasal
	PixelArt.hline(img, 12, 11, 4, out)                                           # jaw shadow
	# bone bow on the right + drawn string + nocked arrow
	PixelArt.line(img, 22, 7, 25, 13, bow)
	PixelArt.line(img, 25, 13, 25, 23, bow)
	PixelArt.line(img, 25, 23, 22, 29, bow)
	PixelArt.px(img, 24, 12, hi); PixelArt.px(img, 24, 24, hi)
	PixelArt.line(img, 22, 7, 17, 18, lo)                                         # upper string
	PixelArt.line(img, 17, 18, 22, 29, lo)                                        # lower string
	PixelArt.hline(img, 16, 18, 9, hi)                                            # arrow shaft
	PixelArt.px(img, 25, 18, out)                                                 # arrowhead
	PixelArt.px(img, 16, 17, eye); PixelArt.px(img, 16, 19, eye)                  # fletching
	# arms
	PixelArt.line(img, 15, 15, 17, 18, mid)                                       # drawing arm
	PixelArt.line(img, 15, 14, 22, 12, mid)                                       # bow arm
	return img
