extends Enemy
## Wraith — ETHEREAL. Physical attacks (Pierce/Blunt) and Fire rattle through it (×0.5);
## only Necrotic/Holy bites (×1.5). Forces the player to unlock the Bound Wraith — the
## "the tree gave me the tool I needed" moment. Debones by fading: whole → tattered → wisp.


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


func _shadow_alpha() -> float:
	return 0.16   # barely touches the ground — it floats


func _feet_y() -> float:
	return 4.0    # hovers above the ground


## Fine pixel art per debone stage (art-direction §6/§7): whole → tattered → wisp, fading as it
## debones. Ethereal: no hard outline, translucent green baked into the texels.
func _author_stage(st: int) -> Image:
	match st:
		0:
			return _author_shroud(28, 36, 0.66, 9)
		1:
			return _author_shroud(24, 32, 0.44, 10)   # smaller, more ragged, fainter
		_:
			# wisp: a fading smear with one dim eye
			var g := Color(0.55, 0.86, 0.64, 0.30)
			var eye := Color(0.9, 1.0, 0.92, 0.6)
			var img := PixelArt.canvas(16, 16)
			PixelArt.rect(img, 5, 4, 6, 5, g)
			PixelArt.px(img, 6, 3, g); PixelArt.px(img, 9, 3, g)
			PixelArt.line(img, 4, 9, 11, 11, g)
			PixelArt.rect(img, 7, 6, 2, 2, eye)
			return img


## A hooded shroud tapering to a tattered hem, glowing eyes, lit crown. `a` is the base opacity;
## `tails` sets the raggedness of the hem. Fills a `w`×`h` canvas (feet at bottom-centre).
func _author_shroud(w: int, h: int, a: float, tails: int) -> Image:
	var g := Color(0.55, 0.86, 0.64, a)
	var gh := Color(0.74, 0.97, 0.80, min(1.0, a + 0.24))   # lit crown
	var hollow := Color(0.03, 0.10, 0.06, min(1.0, a + 0.20))
	var eye := Color(0.9, 1.0, 0.92, min(1.0, a + 0.34))
	var img := PixelArt.canvas(w, h)
	var cx := w / 2
	var body_top := 10
	var hem := h - 10
	# hood crown, narrowing to a point
	for y in range(2, body_top + 4):
		var half := mini((y - 2) + 1, cx - 3)
		PixelArt.hline(img, cx - half, y, half * 2, g)
	# body
	PixelArt.rect(img, 3, body_top, w - 6, hem - body_top, g)
	# tattered hem
	for i in range((w - 6) / 2):
		var hx := 3 + i * 2
		var hh := 6 if i % 2 == 0 else 3
		PixelArt.vline(img, hx, hem, hh, g)
	# lit crown edge
	for y in range(2, body_top):
		var half := (y - 2) + 1
		PixelArt.px(img, cx - half, y, gh); PixelArt.px(img, cx - 1 + half, y, gh)
	# face hollow + glowing eyes
	PixelArt.rect(img, cx - 5, 6, 10, 8, hollow)
	PixelArt.rect(img, cx - 3, 8, 2, 2, eye); PixelArt.rect(img, cx + 1, 8, 2, 2, eye)
	return img
