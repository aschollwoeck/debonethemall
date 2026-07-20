extends Node2D
class_name Backdrop
## Layered graveyard backdrop (M2 slice 1 — the Visual Overhaul, docs/art-direction.md §8).
## Replaces the flat grey field with atmosphere: a distant horizon strip (cold sky, a sick moon,
## crypt-spire silhouettes) over a top-down dark graveyard field (dirt/moss/bone speckle +
## drifting ground fog), plus the cobbled winding path. Draws behind gameplay (z_index -10).
##
## Lighting, vignette, and the additive glow are M2 slice 2; the macabre prop kit is slice 7.

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
const BONEBIT := Color("2e2718")
const DIRT := Color("120f1c")
const STONE_DARK := Color("050308")
const STONE_BASE := Color("211f2c")
const STONE_LIT := Color("2b2836")
const COBBLE := Color("34313e")
const GRAVE := Color("100d1c")
const TREE := Color("080611")
const RUNE := Color("63e39a")   # act accent — slice 2 makes it bloom
const FOG_COLOR := Color(0.55, 0.62, 0.58, 0.028)
## Crypt spires along the horizon: [x, height].
const SPIRES := [[28, 40], [44, 54], [58, 30], [150, 26], [300, 34], [408, 44], [430, 58], [452, 34]]

var _path: PackedVector2Array
var _stars: Array = []
var _speckles: Array = []       # {p:Vector2, c:Color}
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


func _generate() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	_stars.clear()
	for i in 40:
		_stars.append(Vector2(rng.randf() * 480.0, rng.randf() * HORIZON))
	_speckles.clear()
	for i in 280:
		var p := Vector2(rng.randf() * 480.0, HORIZON + rng.randf() * (270.0 - HORIZON))
		var v := rng.randf()
		var c := MOSS if v > 0.9 else (BONEBIT if v > 0.85 else DIRT)
		_speckles.append({"p": p, "c": c})
	# cobble texture + glowing rune stones sampled along the real path
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
	# base
	draw_rect(Rect2(0, 0, 480, 270), GROUND_LO)
	# --- horizon strip ---
	_vgrad(0, 0, 480, HORIZON, SKY_TOP, SKY_HORIZON, 16)
	for s in _stars:
		draw_rect(Rect2(s.x, s.y, 1, 1), STAR)
	# sick moon + faint halo (kept clear of the top-right HUD readouts)
	draw_circle(Vector2(240, 17), 13, Color(0.58, 0.72, 0.55, 0.10))
	draw_circle(Vector2(240, 17), 8, MOON)
	# crypt spires rising to the horizon
	for sp in SPIRES:
		_spire(sp[0], sp[1])
	# --- top-down field ---
	_vgrad(0, HORIZON, 480, 270 - HORIZON, GROUND_HI, GROUND_LO, 20)
	for sp in _speckles:
		draw_rect(Rect2(sp.p.x, sp.p.y, 1, 1), sp.c)
	# sparse set-dressing, kept clear of the path corridor (the macabre kit is slice 7)
	_gravestone(30, 132); _gravestone(38, 250); _gravestone(432, 246)
	_gravestone(96, 256); _gravestone(206, 258)
	_tree(15, 150, 26); _tree(466, 150, 24)
	# --- the cobbled path ---
	_draw_path()
	# --- drifting ground fog (subtle) ---
	_draw_fog()


func _vgrad(x: float, y: float, w: float, h: float, ct: Color, cb: Color, steps: int) -> void:
	var bh := h / float(steps)
	for i in steps:
		draw_rect(Rect2(x, y + i * bh, w, bh + 1.0), ct.lerp(cb, i / float(steps)))


func _spire(x: float, h: float) -> void:
	draw_rect(Rect2(x, HORIZON - h, 8, h), SPIRE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, HORIZON - h), Vector2(x + 4, HORIZON - h - 7), Vector2(x + 8, HORIZON - h)]), SPIRE)


func _gravestone(x: float, y: float) -> void:
	draw_rect(Rect2(x - 4, y - 10, 8, 10), GRAVE)
	draw_circle(Vector2(x, y - 10), 4, GRAVE)
	draw_rect(Rect2(x - 4, y - 8, 1, 8), STONE_DARK)


func _tree(x: float, base: float, h: float) -> void:
	draw_line(Vector2(x, base), Vector2(x - 2, base - h), TREE, 2.0)
	draw_line(Vector2(x - 2, base - h), Vector2(x - 8, base - h - 5), TREE, 1.0)
	draw_line(Vector2(x - 2, base - h + 4), Vector2(x + 6, base - h - 2), TREE, 1.0)


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
