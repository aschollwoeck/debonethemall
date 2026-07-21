extends Enemy
## Skeleton Mage — BONE armor, a **ranged caster** (GDD §6, M3 slice 3). Instead of marching to the
## phylactery to leak, it halts once within range and lobs necrotic bolts at it on a cadence — so
## it threatens from afar and must be killed before it sets up. Weak to Blunt (shatters like any
## bone), resists Pierce. Signature death: flails, bursts into flames, crumbles to ash.

const CAST_RANGE := 72.0     # halts and casts once this close to the phylactery
const CAST_INTERVAL := 1.5   # seconds between bolts
const CAST_DAMAGE := 1       # chip damage per bolt

var _cast_cd: float = CAST_INTERVAL
var _casting: bool = false
var _cast_glow: float = 0.0


func _ready() -> void:
	max_hp = 46.0
	armor_type = CombatTypes.Armor.BONE
	move_speed = 36.0
	reward = 9
	bones_harvest = 2
	leak_damage = 1
	stage_thresholds = [0.6, 0.3]        # caster → aflame flailing → ash
	stage_speed_mult = [1.0, 1.0, 1.0]
	super._ready()


func _physics_process(delta: float) -> void:
	if _dead:
		return
	var phy := target_phylactery
	_casting = phy != null and is_instance_valid(phy) and global_position.distance_to(phy.global_position) <= CAST_RANGE
	if _casting:
		_cast_glow = minf(1.0, _cast_glow + delta * 3.0)
		_cast_cd -= delta
		if _cast_cd <= 0.0:
			phy.take_damage(CAST_DAMAGE)
			_cast_cd = CAST_INTERVAL
			_cast_glow = 1.0
		queue_redraw()
	else:
		_cast_glow = maxf(0.0, _cast_glow - delta * 2.0)
		_advance_along_path(delta)
	if _hit_flash > 0.0:
		_hit_flash = maxf(0.0, _hit_flash - delta * 6.0)
		queue_redraw()


func _draw() -> void:
	super._draw()
	# a necrotic flare at the staff tip while charging/casting
	if _cast_glow > 0.01 and stage < 2:
		var tip := Vector2(7, -13)
		for i in 3:
			var t := i / 3.0
			draw_circle(tip, 5.5 - i * 1.5, Color(0.55, 0.95, 0.65, 0.5 * _cast_glow * (1.0 - t)))


## Fine pixel art per debone stage: robed caster → engulfed in flame → ash pile.
func _author_stage(st: int) -> Image:
	var out := Color("241f19")
	var lo := Color("8f856a")
	var mid := Color("c8bd9c")
	var hi := Color("efe6cd")
	var robe := Color("2b2340")
	var robe_hi := Color("42385e")
	var wood := Color("5a4a30")
	var necro := Color("7bf0ad")
	var ember := Color("e8a24a")
	var flame := Color("ffd24a")
	var ash := Color("3a3630")
	match st:
		0:
			# robed skeleton caster with a glowing staff
			var img := PixelArt.canvas(30, 40)
			# robe (bell shape) down to the ground
			for y in range(16, 38):
				var half := mini(4 + (y - 16) / 3, 9)
				PixelArt.hline(img, 15 - half, y, half * 2, robe)
			for y in range(16, 38):                                   # lit right edge
				var half := mini(4 + (y - 16) / 3, 9)
				PixelArt.px(img, 14 + half, y, robe_hi)
			PixelArt.hline(img, 11, 37, 8, out)                       # hem shadow
			# hood + skull
			PixelArt.rect(img, 10, 5, 10, 10, robe)
			PixelArt.rect(img, 12, 8, 6, 6, mid); PixelArt.hline(img, 12, 8, 6, hi)
			PixelArt.rect(img, 13, 10, 2, 2, out); PixelArt.px(img, 13, 10, necro)   # eyes glow
			PixelArt.rect(img, 16, 10, 2, 2, out); PixelArt.px(img, 16, 10, necro)
			PixelArt.hline(img, 13, 13, 4, out)                       # jaw
			# bony arm reaching to the staff
			PixelArt.line(img, 18, 18, 22, 14, mid)
			# staff on the right + glowing necrotic orb
			PixelArt.vline(img, 22, 10, 26, wood)
			PixelArt.rect(img, 21, 7, 3, 3, necro); PixelArt.px(img, 22, 8, hi)
			PixelArt.px(img, 20, 8, Color(necro.r, necro.g, necro.b, 0.6))
			return img
		1:
			# flailing, engulfed in flame — arms up, robe alight
			var img := PixelArt.canvas(30, 40)
			for y in range(18, 38):                                   # charred robe
				var half := mini(4 + (y - 18) / 3, 8)
				PixelArt.hline(img, 15 - half, y, half * 2, ash)
			# flames licking up the body
			for fx in [9, 12, 15, 18, 21]:
				var fh: int = 8 + (int(fx) % 3) * 4
				PixelArt.vline(img, fx, 28 - fh, fh, ember)
				PixelArt.vline(img, fx, 28 - fh, fh / 2, flame)
			PixelArt.rect(img, 11, 4, 8, 6, flame)                    # crown of fire
			PixelArt.rect(img, 12, 8, 6, 6, mid)                      # skull in the blaze
			PixelArt.rect(img, 13, 10, 2, 2, out); PixelArt.rect(img, 16, 10, 2, 2, out)
			# flailing bone arms thrown up
			PixelArt.line(img, 11, 16, 6, 9, mid); PixelArt.line(img, 19, 16, 24, 9, mid)
			PixelArt.px(img, 6, 9, ember); PixelArt.px(img, 24, 9, ember)
			return img
		_:
			# a smouldering ash pile with a few embers and a half-buried skull
			var img := PixelArt.canvas(24, 14)
			for i in 5:
				var ax := 4 + i * 3
				PixelArt.vline(img, ax, 9 - (i % 2), 4 + (i % 2), ash)
			PixelArt.hline(img, 4, 12, 16, ash)
			PixelArt.px(img, 7, 10, ember); PixelArt.px(img, 14, 11, ember); PixelArt.px(img, 18, 10, flame)
			PixelArt.rect(img, 10, 8, 4, 3, mid); PixelArt.hline(img, 10, 8, 4, hi)   # skull
			PixelArt.px(img, 11, 9, out); PixelArt.px(img, 12, 9, out)
			return img
