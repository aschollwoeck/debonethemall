extends Node2D
class_name Backdrop
## Layered graveyard backdrop (M2 visual overhaul, docs/art-direction.md §8–9).
## Replaces the flat grey field with atmosphere: a distant horizon strip (cold sky, a sick moon,
## crypt-spire silhouettes) over a top-down dark graveyard field with varied ground (blotches,
## cracks, moss, gravel, bone), a scatter of macabre set-dressing (gravestones, dead trees,
## skull piles, staked skulls, a summoning circle, braziers, blood, loose bones, a broken fence),
## and the cobbled winding path. Draws behind gameplay (z_index -10), clear of path/build slots.
##
## The additive lighting/vignette that makes the braziers, summoning circle, and runes bloom is
## M2 slice 2; here they're drawn as their base (unlit) shapes.

const HORIZON := 50.0   # y below which the top-down field begins

# --- palette (docs/art-direction.md §3) ---
const SKY_TOP := Color("060410")
const SKY_HORIZON := Color("12241f")
const GROUND_HI := Color("0f0d1a")
const GROUND_LO := Color("050308")
const SPIRE := Color("0b0817")
const MOON := Color("c3d3bb")
const STAR := Color("3a4650")
const MOSS := Color("1c3324")
const GRAVEL := Color("2a2734")
const BONEBIT := Color("2e2718")
const DIRT := Color("120f1c")
const BLOTCH := Color(0, 0, 0, 0.22)
const CRACK := Color(0.02, 0.015, 0.03, 0.9)
const STONE_DARK := Color("050308")
const STONE_BASE := Color("211f2c")
const STONE_LIT := Color("2b2836")
const COBBLE := Color("34313e")
const GRAVE := Color("100d1c")
const GRAVE_LIT := Color("1c1830")
const TREE := Color("080611")
const SKULL := Color("cdc3a4")
const SKULL_DARK := Color("141018")
const EMBER := Color("e8a24a")
const BLOOD := Color(0.34, 0.07, 0.10, 0.5)
const RUNE := Color("63e39a")   # act accent — slice 2 makes it bloom

const FOG_COLOR := Color(0.55, 0.62, 0.58, 0.028)
## Crypt spires along the horizon: [x, height].
const SPIRES := [[28, 40], [44, 54], [58, 30], [150, 26], [300, 34], [408, 44], [430, 58], [452, 34]]

# Light-source anchors (single source of truth for both the props and the lighting pass, §slice 2).
const BRAZIERS := [Vector2(84, 88), Vector2(318, 190)]
const SUMMON := Vector2(236, 246)
const SUMMON_R := 15.0

var _path: PackedVector2Array
var _stars: Array = []
var _speckles: Array = []       # {p:Vector2, c:Color, s:int}  (s = pixel size)
var _blotches: Array = []       # {p:Vector2, r:float}
var _cracks: Array = []         # {a:Vector2, b:Vector2}
var _cobbles: Array = []        # {p:Vector2, c:Color}
var _runes: Array = []          # Vector2
var _fog: float = 0.0


func _ready() -> void:
	z_index = -10   # behind gameplay (path drawn here, minions/enemies draw on top)


## Receives the enemy path from Main and precomputes the (deterministic) scene decoration.
func setup(path_points: PackedVector2Array) -> void:
	_path = path_points
	_generate()
	queue_redraw()


# Light-source accessors for the lighting pass (world/lighting.gd).
func brazier_points() -> Array: return BRAZIERS
func summon_point() -> Vector2: return SUMMON
func summon_radius() -> float: return SUMMON_R
func rune_points() -> Array: return _runes


func _generate() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	_stars.clear()
	for i in 40:
		_stars.append(Vector2(rng.randf() * 480.0, rng.randf() * HORIZON))
	# ground speckle: dirt / moss clumps / gravel / bone bits
	_speckles.clear()
	for i in 320:
		var p := Vector2(rng.randf() * 480.0, HORIZON + rng.randf() * (270.0 - HORIZON))
		var v := rng.randf()
		var c: Color; var s := 1
		if v > 0.92: c = MOSS; s = 2
		elif v > 0.86: c = GRAVEL; s = 1
		elif v > 0.82: c = BONEBIT; s = 1
		else: c = DIRT; s = 1
		_speckles.append({"p": p, "c": c, "s": s})
	# large soft dark patches (ground variegation)
	_blotches.clear()
	for i in 7:
		_blotches.append({"p": Vector2(rng.randf() * 480.0, HORIZON + rng.randf() * (270.0 - HORIZON)),
			"r": 24.0 + rng.randf() * 34.0})
	# hairline cracks in the earth
	_cracks.clear()
	for i in 26:
		var a := Vector2(rng.randf() * 480.0, HORIZON + rng.randf() * (270.0 - HORIZON))
		var ang := rng.randf() * TAU
		var ln := 4.0 + rng.randf() * 9.0
		_cracks.append({"a": a, "b": a + Vector2(cos(ang), sin(ang)) * ln})
	# cobble texture + rune stones along the real path
	_cobbles.clear()
	_runes.clear()
	if _path.size() >= 2:
		var acc := 0.0
		for i in _path.size() - 1:
			var a: Vector2 = _path[i]
			var b: Vector2 = _path[i + 1]
			var seg := a.distance_to(b)
			var dir := (b - a).normalized()
			var perp := Vector2(-dir.y, dir.x)
			var d := 0.0
			while d < seg:
				var pos := a + dir * d
				for k in [-1, 0, 1]:
					var pp: Vector2 = pos + perp * (k * 7)
					if rng.randf() > 0.55:
						_cobbles.append({"p": pp, "c": COBBLE if rng.randf() > 0.5 else STONE_BASE})
					elif rng.randf() > 0.9:
						_cobbles.append({"p": pp, "c": MOSS})
				acc += 3.0
				if acc >= 20.0:
					acc = 0.0
					_runes.append(pos)
				d += 3.0


func _process(delta: float) -> void:
	_fog = fmod(_fog + delta, 100000.0)   # bounded so float precision never degrades
	queue_redraw()   # only the fog animates; the rest is stable per frame


func _draw() -> void:
	draw_rect(Rect2(0, 0, 480, 270), GROUND_LO)
	# --- horizon strip ---
	_vgrad(0, 0, 480, HORIZON, SKY_TOP, SKY_HORIZON, 16)
	for s in _stars:
		draw_rect(Rect2(s.x, s.y, 1, 1), STAR)
	draw_circle(Vector2(240, 17), 13, Color(0.58, 0.72, 0.55, 0.10))
	draw_circle(Vector2(240, 17), 8, MOON)
	for sp in SPIRES:
		_spire(sp[0], sp[1])
	# --- top-down field ---
	_vgrad(0, HORIZON, 480, 270 - HORIZON, GROUND_HI, GROUND_LO, 20)
	for b in _blotches:
		draw_circle(b.p, b.r, BLOTCH)
	for sp in _speckles:
		draw_rect(Rect2(sp.p.x, sp.p.y, sp.s, sp.s), sp.c)
	for cr in _cracks:
		draw_line(cr.a, cr.b, CRACK, 1.0)
	# --- set-dressing (kept clear of the path corridor and the 9 build slots) ---
	_draw_props()
	# --- the cobbled path (drawn over the ground, kept clean) ---
	_draw_path()
	# --- drifting ground fog ---
	_draw_fog()


func _vgrad(x: float, y: float, w: float, h: float, ct: Color, cb: Color, steps: int) -> void:
	var bh := h / float(steps)
	for i in steps:
		draw_rect(Rect2(x, y + i * bh, w, bh + 1.0), ct.lerp(cb, i / float(steps)))


func _spire(x: float, h: float) -> void:
	draw_rect(Rect2(x, HORIZON - h, 8, h), SPIRE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, HORIZON - h), Vector2(x + 4, HORIZON - h - 7), Vector2(x + 8, HORIZON - h)]), SPIRE)


# ---------------------------------------------------------------- set-dressing

func _draw_props() -> void:
	# a small graveyard clustered bottom-left, and lone stones tucked in the path's pockets
	_grave(16, 240); _grave_cross(34, 256); _grave(52, 242)
	_grave(170, 92); _grave(282, 136); _grave(386, 92)
	# dead trees at the field edges
	_tree(12, 132, 24); _tree(470, 132, 22)
	# macabre kit (docs/art-direction.md §9)
	_skull_pile(72, 256); _skull_pile(432, 236)
	_staked_skull(30, 178); _staked_skull(452, 150)
	_summon_circle(SUMMON.x, SUMMON.y, SUMMON_R)
	for b in BRAZIERS:
		_brazier(b.x, b.y)
	_blood(412, 186); _blood(150, 250)
	_bones(44, 158); _bones(196, 250)
	_fence(4, 96, 266)


func _grave(x: float, y: float) -> void:
	draw_rect(Rect2(x - 4, y - 10, 8, 10), GRAVE)
	draw_circle(Vector2(x, y - 10), 4, GRAVE)
	draw_rect(Rect2(x - 4, y - 10, 1, 10), GRAVE_LIT)   # lit left edge
	draw_rect(Rect2(x - 2, y - 6, 4, 1), STONE_DARK)    # a carved line


func _grave_cross(x: float, y: float) -> void:
	draw_rect(Rect2(x - 1, y - 11, 2, 11), GRAVE)
	draw_rect(Rect2(x - 4, y - 8, 8, 2), GRAVE)
	draw_rect(Rect2(x - 1, y - 11, 1, 11), GRAVE_LIT)


func _tree(x: float, base: float, h: float) -> void:
	draw_line(Vector2(x, base), Vector2(x - 2, base - h), TREE, 2.0)
	draw_line(Vector2(x - 2, base - h), Vector2(x - 8, base - h - 5), TREE, 1.0)
	draw_line(Vector2(x - 2, base - h + 4), Vector2(x + 6, base - h - 2), TREE, 1.0)
	draw_line(Vector2(x - 1, base - h * 0.5), Vector2(x - 6, base - h * 0.5 - 3), TREE, 1.0)


func _skull(x: float, y: float, s: float) -> void:
	draw_circle(Vector2(x, y), s, SKULL)
	draw_rect(Rect2(x - s * 0.7, y, s * 1.4, s * 0.9), SKULL)
	draw_rect(Rect2(x - s * 0.6, y - s * 0.2, s * 0.5, s * 0.5), SKULL_DARK)
	draw_rect(Rect2(x + s * 0.1, y - s * 0.2, s * 0.5, s * 0.5), SKULL_DARK)


func _skull_pile(x: float, y: float) -> void:
	_skull(x, y, 4.0); _skull(x + 7, y, 4.0); _skull(x - 4, y + 1, 3.2); _skull(x + 3, y - 6, 3.4)


func _staked_skull(x: float, y: float) -> void:
	draw_rect(Rect2(x, y - 8, 1, 8), Color("0c0a16"))   # foreshortened stake
	_skull(x, y - 10, 3.0)


func _summon_circle(x: float, y: float, r: float) -> void:
	draw_circle(Vector2(x, y), r, Color(RUNE.r, RUNE.g, RUNE.b, 0.05))   # faint inner
	draw_arc(Vector2(x, y), r, 0, TAU, 40, RUNE, 1.0)
	draw_arc(Vector2(x, y), r - 3, 0, TAU, 36, Color(RUNE.r, RUNE.g, RUNE.b, 0.5), 1.0)
	for i in 6:                                          # rune ticks around the ring
		var a := i * TAU / 6.0
		var p := Vector2(x + cos(a) * r, y + sin(a) * r)
		draw_rect(Rect2(p.x - 1, p.y - 1, 2, 2), RUNE)


func _brazier(x: float, y: float) -> void:
	draw_rect(Rect2(x - 1, y, 2, 6), Color("1a1622"))   # post
	draw_rect(Rect2(x - 3, y - 3, 6, 3), Color("2a2734")) # bowl
	draw_rect(Rect2(x - 1, y - 5, 2, 3), EMBER)          # ember (blooms in slice 2)


func _blood(x: float, y: float) -> void:
	draw_circle(Vector2(x, y), 4.0, BLOOD)
	draw_circle(Vector2(x + 4, y + 1), 2.0, BLOOD)


func _bones(x: float, y: float) -> void:
	draw_line(Vector2(x - 3, y), Vector2(x + 3, y - 1), SKULL, 1.0)
	draw_line(Vector2(x - 2, y + 2), Vector2(x + 3, y + 1), SKULL, 1.0)
	draw_circle(Vector2(x + 3, y), 1.4, SKULL)


func _fence(x0: float, x1: float, y: float) -> void:
	var x := x0
	var i := 0
	while x < x1:
		var tall := 2.0 if i % 5 == 4 else 6.0   # every 5th bar snapped short
		draw_line(Vector2(x, y), Vector2(x, y - tall), Color("0a0814"), 1.0)
		x += 7.0
		i += 1
	draw_line(Vector2(x0, y - 6), Vector2(x1, y - 6), Color("0a0814"), 1.0)


# ---------------------------------------------------------------- path & fog

func _draw_path() -> void:
	_stroke(STONE_DARK, 18.0)
	_stroke(STONE_BASE, 14.0)
	_stroke(STONE_LIT, 10.0)
	for d in _cobbles:
		draw_rect(Rect2(d.p.x, d.p.y, 2, 2), d.c)
	for r in _runes:
		draw_rect(Rect2(r.x - 2, r.y - 2, 4, 4), Color("1e3a28"))
		draw_rect(Rect2(r.x - 1, r.y - 1, 2, 2), RUNE)


## Strokes the path with rounded joints (draw_line segments + circles fill the corners).
func _stroke(color: Color, width: float) -> void:
	for i in _path.size() - 1:
		draw_line(_path[i], _path[i + 1], color, width)
	for i in range(1, _path.size() - 1):
		draw_circle(_path[i], width * 0.5, color)


func _draw_fog() -> void:
	for i in 3:
		var off := fmod(_fog * (6.0 + i * 3.0), 480.0)
		var y := HORIZON + 8.0 + i * 46.0
		draw_rect(Rect2(-off, y, 480, 18), FOG_COLOR)
		draw_rect(Rect2(480 - off, y, 480, 18), FOG_COLOR)
