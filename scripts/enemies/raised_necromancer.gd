extends Enemy
## Raised Necromancer — an Act I **miniboss** (GDD §6, M3 slice 5). Elite and slow, it periodically
## **raises a fresh skeleton into the wave** — so unless you burst it down, the wave never ends
## ("kill it fast or drown"). Pressures low single-target DPS. BONE armor (the Golem's Blunt is the
## fast answer). Debones: crowned necromancer → cracked, guttering husk.

const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const RESURRECT_INTERVAL := 4.0   # seconds between raisings

var _raise_cd: float = RESURRECT_INTERVAL
var _raise_glow: float = 0.0


func _ready() -> void:
	max_hp = 140.0
	armor_type = CombatTypes.Armor.BONE
	move_speed = 22.0
	reward = 30
	bones_harvest = 8
	leak_damage = 3
	stage_thresholds = [0.5]           # intact → cracked husk
	stage_speed_mult = [1.0, 1.0]
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)      # march + hit-flash decay (returns early if dead)
	if _dead:
		return
	if _raise_glow > 0.0:
		_raise_glow = maxf(0.0, _raise_glow - delta * 1.5)
		queue_redraw()
	_raise_cd -= delta
	if _raise_cd <= 0.0:
		_raise_cd = RESURRECT_INTERVAL
		reinforcement_requested.emit(GRUNT)   # the WaveManager spawns + tracks it
		_raise_glow = 1.0
		queue_redraw()


func _draw() -> void:
	super._draw()
	# a necrotic raise-pulse ripples out from the ground as it summons
	if _raise_glow > 0.01:
		var r := 5.0 + (1.0 - _raise_glow) * 15.0
		draw_arc(Vector2(0, 8), r, 0.0, TAU, 30, Color(0.4, 0.95, 0.6, 0.6 * _raise_glow), 1.5, true)


## Fine pixel art per debone stage: crowned robed necromancer with raised summoning hands → a
## cracked, guttering husk (one arm fallen).
func _author_stage(st: int) -> Image:
	var out := Color("14121c")
	var robe := Color("241d38")
	var robe_hi := Color("3a3057")
	var bone := Color("c8bd9c")
	var bone_hi := Color("efe6cd")
	var necro := Color("7bf0ad")
	var img := PixelArt.canvas(38, 48)
	match st:
		0:
			# robe (wide bell) to the ground
			for y in range(20, 46):
				var half := mini(5 + (y - 20) / 2, 12)
				PixelArt.hline(img, 19 - half, y, half * 2, robe)
				PixelArt.px(img, 18 + half, y, robe_hi)          # lit right edge
			PixelArt.hline(img, 8, 45, 22, out)                  # hem shadow
			# raised summoning arms + glowing hands
			PixelArt.line(img, 14, 22, 7, 14, bone); PixelArt.line(img, 24, 22, 31, 14, bone)
			PixelArt.rect(img, 5, 12, 3, 3, necro); PixelArt.rect(img, 30, 12, 3, 3, necro)
			PixelArt.px(img, 6, 11, bone_hi); PixelArt.px(img, 31, 11, bone_hi)
			# summoning glow at the chest
			PixelArt.rect(img, 17, 24, 4, 4, Color(necro.r, necro.g, necro.b, 0.55))
			PixelArt.px(img, 18, 25, necro)
			# hooded skull with a bone crown
			PixelArt.rect(img, 13, 6, 12, 12, robe)              # hood
			PixelArt.rect(img, 15, 9, 8, 7, bone); PixelArt.hline(img, 15, 9, 8, bone_hi)  # skull
			for cx in [14, 17, 19, 21, 24]:                      # crown spikes
				PixelArt.vline(img, cx, 4, 3, bone)
			PixelArt.rect(img, 16, 11, 2, 2, out); PixelArt.rect(img, 20, 11, 2, 2, out)   # sockets
			PixelArt.px(img, 16, 11, necro); PixelArt.px(img, 21, 11, necro)               # eye glow
			PixelArt.hline(img, 16, 15, 6, out)                  # jaw
			return img
		_:
			# cracked, guttering husk — torn robe, one arm fallen, green leaking from the cracks
			for y in range(22, 46):
				var half := mini(4 + (y - 22) / 2, 10)
				if (y % 3) != 0:                                 # ragged / torn hem
					PixelArt.hline(img, 19 - half, y, half * 2, robe)
			PixelArt.line(img, 14, 24, 8, 30, bone)              # one arm fallen
			PixelArt.line(img, 24, 24, 30, 17, bone)             # other still raised, weakly
			PixelArt.rect(img, 29, 15, 3, 3, Color(necro.r, necro.g, necro.b, 0.7))
			# cracks
			PixelArt.line(img, 18, 20, 16, 34, necro); PixelArt.line(img, 21, 26, 22, 40, Color(necro.r, necro.g, necro.b, 0.6))
			# slumped skull
			PixelArt.rect(img, 14, 9, 8, 7, bone); PixelArt.hline(img, 14, 9, 8, bone_hi)
			for cx in [13, 16, 20, 23]:
				PixelArt.vline(img, cx, 7, 3, bone)
			PixelArt.rect(img, 15, 12, 2, 2, out); PixelArt.rect(img, 19, 12, 2, 2, out)
			PixelArt.px(img, 15, 12, necro)
			return img
