extends Node2D
class_name Backdrop
## Smooth, painted graveyard backdrop (M2b restyle slice 2, docs/art-direction.md §0/§8).
## Renders at native resolution (canvas_items stretch), so gradients, glows and silhouettes read
## soft — no pixels. A horizon strip (cold sky, glowing moon, soft crypt spires) over a misty
## graveyard field with a smoothly-lit road and painted macabre set-dressing. The bright glow of
## the braziers / summoning circle / runes / phylactery comes from the lighting pass
## (world/lighting.gd); this draws the soft world behind gameplay (z_index -10).

const HORIZON := 54.0

# palette (art-direction §3)
const SKY := [Color("060410"), Color("0e0b1e"), Color("141a2a"), Color("183028")]  # top→horizon
const GROUND_HI := Color("100d1c")
const GROUND_LO := Color("050308")
const SPIRE := Color("0b0817")
const MOON := Color("cdddc4")
const GRAVE := Color("14111f")
const TREE := Color("0a0714")
const SKULL := Color("cbc2a6")
const SKULL_DK := Color("14101a")
const EMBER := Color("e8a24a")
const BLOOD := Color(0.30, 0.06, 0.09, 0.5)
const ACCENT := Color("63e39a")
const FOG := Color(0.55, 0.64, 0.58, 0.03)

const SPIRES := [[26, 46], [42, 66], [58, 34], [150, 30], [300, 40], [406, 52], [430, 72], [452, 40]]
const BRAZIERS := [Vector2(84, 90), Vector2(318, 192)]
const SUMMON := Vector2(236, 246)
const SUMMON_R := 15.0

var _path: PackedVector2Array
var _blotches: Array = []   # {p, r, a} soft ground-tone variation
var _runes: Array = []      # Vector2 along the path (consumed by the lighting pass)
var _fog: float = 0.0


func _ready() -> void:
	z_index = -10


## Receives the enemy path from Main and precomputes the (deterministic) scene decoration.
func setup(path_points: PackedVector2Array) -> void:
	_path = path_points
	_generate()
	queue_redraw()


# light-source accessors for world/lighting.gd
func brazier_points() -> Array: return BRAZIERS
func summon_point() -> Vector2: return SUMMON
func summon_radius() -> float: return SUMMON_R
func rune_points() -> Array: return _runes


func _generate() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	_blotches.clear()
	for i in 10:
		_blotches.append({"p": Vector2(rng.randf() * 480.0, HORIZON + rng.randf() * (270.0 - HORIZON)),
			"r": 26.0 + rng.randf() * 46.0, "a": 0.10 + rng.randf() * 0.12})
	# rune anchors sampled along the path (their glimmer is drawn by the lighting pass)
	_runes.clear()
	if _path.size() >= 2:
		var acc := 0.0
		for i in _path.size() - 1:
			var a: Vector2 = _path[i]
			var b: Vector2 = _path[i + 1]
			var seg := a.distance_to(b)
			var dir := (b - a).normalized()
			var d := 0.0
			while d < seg:
				acc += 3.0
				if acc >= 26.0:
					acc = 0.0
					_runes.append(a + dir * d)
				d += 3.0


func _process(delta: float) -> void:
	_fog = fmod(_fog + delta, 100000.0)
	queue_redraw()   # only the fog animates; the rest of the scene is stable per frame


func _draw() -> void:
	draw_rect(Rect2(0, 0, 480, 270), GROUND_LO)
	# --- horizon: sky gradient, moon + halo, soft spires ---
	_vgrad(0, 0, 480, HORIZON + 8, SKY[0], SKY[3], 24)
	_vgrad(0, 0, 480, HORIZON * 0.5, SKY[0], SKY[1], 12)
	_soft_disc(Vector2(240, 20), 9.0, MOON, 40.0)
	for sp in SPIRES:
		_spire(sp[0], sp[1])
	# --- misty ground ---
	_vgrad(0, HORIZON, 480, 270 - HORIZON, GROUND_HI, GROUND_LO, 26)
	for b in _blotches:
		_soft_blob(b.p, b.r, Color(0, 0, 0, b.a))
	# --- set-dressing (painted; kept clear of the path corridor and build slots) ---
	_draw_props()
	# --- smoothly-lit road ---
	_draw_road()
	# --- drifting mist over the field ---
	_draw_fog()


func _vgrad(x: float, y: float, w: float, h: float, ct: Color, cb: Color, steps: int) -> void:
	var bh := h / float(steps)
	for i in steps:
		draw_rect(Rect2(x, y + i * bh, w, bh + 1.0), ct.lerp(cb, i / float(steps)))


## A soft filled disc with a fading halo (layered translucent circles → radial-gradient feel).
func _soft_disc(c: Vector2, r: float, col: Color, halo: float) -> void:
	for i in 6:
		var t := i / 6.0
		draw_circle(c, halo * (1.0 - t * 0.5), Color(col.r, col.g, col.b, 0.05 * (1.0 - t)))
	draw_circle(c, r, col)
	draw_circle(c - Vector2(r * 0.3, r * 0.3), r * 0.35, col.lerp(Color.WHITE, 0.25))


func _soft_blob(c: Vector2, r: float, col: Color) -> void:
	for i in 4:
		draw_circle(c, r * (1.0 - i * 0.22), Color(col.r, col.g, col.b, col.a * (0.4 + i * 0.2)))


func _spire(x: float, h: float) -> void:
	# soft silhouette: a darker wide base behind a solid spire → gives a hazy edge
	draw_colored_polygon(PackedVector2Array([Vector2(x - 3, HORIZON), Vector2(x + 4, HORIZON - h - 9),
		Vector2(x + 11, HORIZON)]), Color(SPIRE.r, SPIRE.g, SPIRE.b, 0.5))
	draw_colored_polygon(PackedVector2Array([Vector2(x, HORIZON), Vector2(x + 4, HORIZON - h - 6),
		Vector2(x + 8, HORIZON)]), SPIRE)


# ---------------------------------------------------------------- painted set-dressing

func _draw_props() -> void:
	_grave(16, 240); _grave(52, 244); _grave(170, 92); _grave(282, 138); _grave(386, 92)
	_grave_cross(34, 256)
	_tree(14, 134, 26); _tree(468, 134, 24)
	_skull_pile(72, 256); _skull_pile(432, 236)
	_staked_skull(30, 178); _staked_skull(452, 150)
	_summon_circle(SUMMON, SUMMON_R)
	for b in BRAZIERS:
		_brazier(b)
	_blood(Vector2(412, 186)); _blood(Vector2(150, 250))
	_fence(4, 96, 266)


func _grave(x: float, y: float) -> void:
	draw_circle(Vector2(x, y + 4), 7.0, Color(0, 0, 0, 0.3))          # soft shadow
	draw_rect(Rect2(x - 4, y - 9, 8, 10), GRAVE)
	draw_circle(Vector2(x, y - 9), 4.0, GRAVE)
	draw_line(Vector2(x - 4, y - 9), Vector2(x - 4, y), GRAVE.lerp(Color.WHITE, 0.15), 1.0)


func _grave_cross(x: float, y: float) -> void:
	draw_line(Vector2(x, y), Vector2(x, y - 11), GRAVE, 2.0)
	draw_line(Vector2(x - 4, y - 8), Vector2(x + 4, y - 8), GRAVE, 2.0)


func _tree(x: float, base: float, h: float) -> void:
	draw_line(Vector2(x, base), Vector2(x - 2, base - h), TREE, 2.0, true)
	draw_line(Vector2(x - 2, base - h), Vector2(x - 8, base - h - 5), TREE, 1.5, true)
	draw_line(Vector2(x - 2, base - h + 4), Vector2(x + 6, base - h - 2), TREE, 1.5, true)
	draw_line(Vector2(x - 1, base - h * 0.5), Vector2(x - 6, base - h * 0.5 - 3), TREE, 1.2, true)


func _skull(c: Vector2, s: float) -> void:
	draw_circle(c, s, SKULL)
	draw_rect(Rect2(c.x - s * 0.7, c.y, s * 1.4, s * 0.85), SKULL)
	draw_circle(Vector2(c.x - s * 0.35, c.y), s * 0.28, SKULL_DK)
	draw_circle(Vector2(c.x + s * 0.35, c.y), s * 0.28, SKULL_DK)


func _skull_pile(x: float, y: float) -> void:
	draw_circle(Vector2(x + 4, y + 4), 10.0, Color(0, 0, 0, 0.3))
	_skull(Vector2(x, y), 4.0); _skull(Vector2(x + 7, y), 4.0)
	_skull(Vector2(x - 4, y + 1), 3.2); _skull(Vector2(x + 3, y - 6), 3.4)


func _staked_skull(x: float, y: float) -> void:
	draw_line(Vector2(x, y), Vector2(x, y - 8), Color("0c0a16"), 1.5, true)
	_skull(Vector2(x, y - 10), 3.0)


func _summon_circle(c: Vector2, r: float) -> void:
	draw_circle(c, r, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.05))
	draw_arc(c, r, 0, TAU, 48, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.7), 1.5, true)
	draw_arc(c, r - 3, 0, TAU, 44, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.4), 1.0, true)


func _brazier(c: Vector2) -> void:
	draw_line(c, c + Vector2(0, 6), Color("1a1622"), 2.0)
	draw_circle(c + Vector2(0, -2), 3.0, Color("2a2734"))
	draw_circle(c + Vector2(0, -4), 1.6, EMBER)


func _blood(c: Vector2) -> void:
	draw_circle(c, 4.0, BLOOD)
	draw_circle(c + Vector2(4, 1), 2.0, BLOOD)


func _fence(x0: float, x1: float, y: float) -> void:
	var x := x0
	var i := 0
	while x < x1:
		var tall := 2.0 if i % 5 == 4 else 6.0
		draw_line(Vector2(x, y), Vector2(x, y - tall), Color("0a0814"), 1.0)
		x += 7.0
		i += 1
	draw_line(Vector2(x0, y - 6), Vector2(x1, y - 6), Color("0a0814"), 1.0)


# ---------------------------------------------------------------- road & fog

func _draw_road() -> void:
	_stroke(Color("07060d"), 20.0)                # soft dark casing
	_stroke(Color("211f2c"), 15.0)                # stone
	_stroke(Color("2d2a3a"), 9.0)                 # lit centre
	# a faint centre sheen
	_stroke(Color(0.22, 0.20, 0.28, 0.5), 3.0)


func _stroke(color: Color, width: float) -> void:
	for i in _path.size() - 1:
		draw_line(_path[i], _path[i + 1], color, width, true)
	for i in range(1, _path.size() - 1):
		draw_circle(_path[i], width * 0.5, color)


func _draw_fog() -> void:
	for i in 3:
		var off := fmod(_fog * (5.0 + i * 3.0), 480.0)
		var y := HORIZON + 10.0 + i * 46.0
		draw_rect(Rect2(-off, y, 480, 22), FOG)
		draw_rect(Rect2(480 - off, y, 480, 22), FOG)
