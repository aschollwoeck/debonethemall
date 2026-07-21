extends Enemy
## The Master — the Act I **boss** (GDD §6, M3 slice 7): your cruel necromancer, the end-of-act
## setpiece. A ~2× crowned necromancer-lord that changes behaviour at HP thresholds (reusing the
## debone-stage tech): it **summons** the dead throughout, escalates to raising **knights**, and in
## its final phase **strikes the phylactery directly** across the field. Carries its own necrotic
## light. BONE armor. Reaching the phylactery in person is near-fatal (huge leak).

const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const KNIGHT := preload("res://scripts/enemies/armored_knight.gd")

const SUMMON_BASE := 6.0     # phase-0 seconds between summons (shortens per phase)
const STRIKE_INTERVAL := 2.0 # phase-2 seconds between phylactery strikes
const STRIKE_DAMAGE := 2

var _summon_cd: float = SUMMON_BASE
var _strike_cd: float = STRIKE_INTERVAL
var _aura: float = 0.0        # summon / strike pulse
var _t: float = 0.0


func _ready() -> void:
	max_hp = 700.0
	armor_type = CombatTypes.Armor.BONE
	move_speed = 16.0
	reward = 120
	bones_harvest = 40
	leak_damage = 10
	stage_thresholds = [0.66, 0.33]        # three phases
	stage_speed_mult = [0.9, 1.1, 1.3]     # lunges faster as it unravels
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)          # march + hit-flash (returns early if dead)
	if _dead:
		return
	_t += delta
	if _aura > 0.0:
		_aura = maxf(0.0, _aura - delta * 1.2)
	# summon the dead on a cadence that tightens with each phase
	_summon_cd -= delta
	if _summon_cd <= 0.0:
		_summon_cd = _summon_interval()
		reinforcement_requested.emit(_summon_pick())
		_aura = 1.0
	# final phase: reach across the field and strike the phylactery
	if stage >= 2 and target_phylactery != null and is_instance_valid(target_phylactery):
		_strike_cd -= delta
		if _strike_cd <= 0.0:
			_strike_cd = STRIKE_INTERVAL
			target_phylactery.take_damage(STRIKE_DAMAGE)
			_aura = 1.0
	queue_redraw()


func _summon_interval() -> float:
	return [SUMMON_BASE, 4.0, 2.8][stage] if stage < 3 else 2.8


func _summon_pick() -> Script:
	return KNIGHT if stage == 1 else GRUNT   # phase 1 raises knights; else grunts (a swarm)


## A burst of summons the moment a phase breaks.
func _on_stage_changed() -> void:
	_summon_cd = 0.5
	_aura = 1.0


func _draw() -> void:
	# own light source: a persistent necrotic aura, plus a raise/strike pulse — drawn BEHIND the
	# sprite (super._draw draws the shadow + blitted pixel body on top).
	var base := 0.30 + 0.10 * sin(_t * 2.0)
	_aura_glow(Vector2(0, -10), 36.0, base)
	if _aura > 0.01:
		draw_arc(Vector2(0, 8), 6.0 + (1.0 - _aura) * 26.0, 0.0, TAU, 40,
			Color(0.4, 0.95, 0.6, 0.6 * _aura), 2.0, true)
	super._draw()


func _aura_glow(pos: Vector2, r: float, intensity: float) -> void:
	for i in 5:
		var t := i / 5.0
		draw_circle(pos, r * (1.0 - t * 0.7), Color(0.35, 0.9, 0.55, intensity * (1.0 - t) * 0.35))


## Fine pixel art per phase (~2× a normal unit): crowned necromancer-lord → enraged, torn, aflame
## → unravelling skeletal husk pouring green.
func _author_stage(st: int) -> Image:
	var ink := Color("100e18")
	var robe := Color("1e1830")
	var robe_hi := Color("342a4e")
	var robe_lo := Color("14101f")
	var bone := Color("c8bd9c")
	var bone_hi := Color("efe6cd")
	var necro := Color("7bf0ad")
	var gold := Color("c8a24a")
	var flame := Color("ffd24a")
	var img := PixelArt.canvas(64, 84)
	# --- shared: crown, hood, skull, staff (drawn first so robe/effects layer over as needed) ---
	# great staff on the right
	PixelArt.vline(img, 54, 8, 72, Color("5a4a30")); PixelArt.vline(img, 55, 8, 72, Color("3a2f20"))
	PixelArt.rect(img, 51, 5, 7, 7, ink); PixelArt.rect(img, 52, 6, 5, 5, necro); PixelArt.px(img, 53, 7, bone_hi)
	# robe bell (torn in later phases)
	var hem_lo := 38 if st == 0 else (42 if st == 1 else 48)
	for y in range(hem_lo, 82):
		var half := mini(8 + (y - hem_lo) / 2, 26)
		if st == 2 and (y % 3) == 0:
			continue                                   # tattered
		PixelArt.hline(img, 32 - half, y, half * 2, robe)
		PixelArt.px(img, 31 + half, y, robe_hi); PixelArt.px(img, 32 - half, y, robe_lo)
	PixelArt.hline(img, 8, 81, 48, ink)
	# broad mantle / shoulders
	PixelArt.rect(img, 8, 34, 48, 6, robe_hi); PixelArt.rect(img, 8, 34, 48, 2, robe)
	PixelArt.rect(img, 6, 36, 6, 11, robe); PixelArt.rect(img, 52, 36, 6, 11, robe)
	# hood
	PixelArt.rect(img, 20, 10, 24, 26, robe); PixelArt.hline(img, 20, 10, 24, robe_hi)
	# skull face
	PixelArt.rect(img, 24, 16, 16, 14, bone); PixelArt.hline(img, 24, 16, 16, bone_hi)
	PixelArt.rect(img, 27, 20, 4, 4, ink); PixelArt.rect(img, 33, 20, 4, 4, ink)
	PixelArt.rect(img, 27, 20, 2, 2, necro); PixelArt.rect(img, 34, 20, 2, 2, necro)
	PixelArt.rect(img, 30, 26, 4, 3, ink)                # nasal
	for tx in range(26, 39, 2):
		PixelArt.vline(img, tx, 28, 3, bone)             # teeth
	# horned gold crown
	for cx in [22, 26, 30, 34, 38, 42]:
		PixelArt.vline(img, cx, 6, 5, gold)
	PixelArt.rect(img, 17, 8, 4, 6, gold); PixelArt.rect(img, 43, 8, 4, 6, gold)   # horns
	# chest sigil
	PixelArt.rect(img, 28, 44, 8, 8, Color(necro.r, necro.g, necro.b, 0.4)); PixelArt.rect(img, 30, 46, 4, 4, necro)
	match st:
		0:
			# arms folded in command
			PixelArt.line(img, 22, 46, 42, 46, bone); PixelArt.line(img, 44, 44, 54, 40, bone)
		1:
			# enraged: a raised summoning arm + green flames licking the robe, a crack
			PixelArt.line(img, 20, 44, 10, 26, bone); PixelArt.rect(img, 8, 22, 4, 4, necro)   # raised hand
			for fx in [12, 18, 46, 50]:
				PixelArt.vline(img, fx, 58, 10, flame); PixelArt.vline(img, fx, 62, 6, necro)
			PixelArt.line(img, 30, 40, 26, 60, necro)    # crack
		_:
			# unravelling: ribs through the tatters, green pouring out, staff guttering
			for ry in [46, 50, 54]:
				PixelArt.hline(img, 24, ry, 16, bone)
			PixelArt.line(img, 26, 42, 22, 66, necro); PixelArt.line(img, 38, 44, 40, 64, Color(necro.r, necro.g, necro.b, 0.6))
			PixelArt.rect(img, 51, 5, 7, 4, Color(necro.r, necro.g, necro.b, 0.4))   # orb bleeding
			PixelArt.line(img, 20, 46, 12, 58, bone)     # limp arm
	return img
