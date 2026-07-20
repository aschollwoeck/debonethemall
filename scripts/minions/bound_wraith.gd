extends Minion
## Bound Wraith — Necrotic, single-target, medium range/rate. The answer to ethereal foes:
## physical minions rattle through wraiths, but necrotic bolts tear them apart.
## Unlocked via the meta skill tree (not available on a fresh save).

const NECRO := Color("9be7a0")   # sickly necrotic green (projectile tint)


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


## Fine pixel art (art-direction §6/§7): a translucent hooded shroud with a face-hollow, a bound
## soul orb, and binding chains — ethereal, no hard outline, glowing in the act accent.
func _author_body() -> Image:
	var mid := Color(0.22, 0.66, 0.42, 0.70)
	var hi := Color(0.5, 0.92, 0.68, 0.85)
	var core := Color(0.85, 1.0, 0.9, 0.95)
	var hollow := Color(0.03, 0.09, 0.06, 0.85)
	var chain := Color("4a4636")
	var img := PixelArt.canvas(28, 42)
	# hood crown — narrows to a point at the top
	for y in range(5, 13):
		var half := mini((y - 5) + 1, 8)
		PixelArt.hline(img, 14 - half, y, half * 2, mid)
	# shoulders + body
	PixelArt.rect(img, 6, 13, 16, 16, mid)
	# lit crown edge
	for y in range(5, 11):
		var half := (y - 5) + 1
		PixelArt.px(img, 14 - half, y, hi); PixelArt.px(img, 13 + half, y, hi)
	# wispy tails trailing below
	var tails := [7, 11, 15, 18]
	for i in tails.size():
		var wx: int = tails[i]
		var wlen := 6 + (i % 2) * 3
		PixelArt.vline(img, wx, 28, wlen, mid)
		PixelArt.px(img, wx, 28 + wlen - 1, hi)
	# dark hollow where a face should be
	PixelArt.rect(img, 10, 8, 8, 9, hollow)
	# glowing eyes
	PixelArt.rect(img, 11, 11, 2, 2, core); PixelArt.rect(img, 15, 11, 2, 2, core)
	# bound soul orb at the chest
	PixelArt.rect(img, 12, 20, 4, 4, core); PixelArt.rect(img, 13, 21, 2, 2, hi)
	# binding chains across the middle
	for cx in [7, 10, 13, 16, 19]:
		PixelArt.rect(img, cx, 26, 2, 1, chain)
	PixelArt.line(img, 6, 27, 21, 26, Color("2a2620"))
	return img
