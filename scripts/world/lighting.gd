extends Node2D
class_name Lighting
## Additive lighting pass (M2 slice 2, docs/art-direction.md §5). Draws glow pools over the world
## — the phylactery, braziers, the summoning circle, and the path rune-stones — plus drifting
## necrotic motes, using an additive material and a procedurally generated soft glow texture.
##
## `accent` tints the necrotic lights: green by default; a later act sets this one value to
## witchfire purple. Braziers stay warm amber. Draws above gameplay (z 5), under the HUD layer.

## The act's signature glow colour (GDD §4 / art-direction §4). Set per act; green is Act I–II.
@export var accent: Color = Color("63e39a")

const EMBER := Color("e8a24a")

var _glow: Texture2D
var _t: float = 0.0
var _phyl := Vector2.ZERO
var _braziers: Array = []
var _summon := Vector2.ZERO
var _summon_r: float = 15.0
var _runes: Array = []
var _motes: Array = []   # {p:Vector2, ph:float, sp:float}


func _ready() -> void:
	z_index = 5   # above gameplay (z0), under the HUD (a separate CanvasLayer)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR   # smooth bloom from a small texture
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = m
	_glow = _make_glow(48)


## Wires the light sources from the phylactery + backdrop, and seeds the drifting motes.
func setup(phylactery_pos: Vector2, backdrop: Backdrop) -> void:
	_phyl = phylactery_pos
	_braziers = backdrop.brazier_points()
	_summon = backdrop.summon_point()
	_summon_r = backdrop.summon_radius()
	_runes = backdrop.rune_points()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	_motes.clear()
	for i in 22:
		_motes.append({"p": Vector2(rng.randf() * 480.0, 60.0 + rng.randf() * 200.0),
			"ph": rng.randf() * TAU, "sp": 4.0 + rng.randf() * 8.0})
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_t * 3.0)
	# phylactery — the brightest source, a tight core + a wide bleed
	_light(_phyl, 50.0, accent, 0.22 + 0.12 * pulse)
	_light(_phyl, 92.0, accent, 0.05 + 0.03 * pulse)
	# summoning circle
	_light(_summon, _summon_r + 10.0, accent, 0.14 + 0.07 * pulse)
	# path rune-stones catch the light
	for r in _runes:
		_light(r, 7.0, accent, 0.10 + 0.05 * sin(_t * 4.0 + r.x * 0.1))
	# braziers — warm amber, flickering
	for b in _braziers:
		var flick := 0.6 + 0.4 * absf(sin(_t * 20.0 + b.x) + 0.3 * sin(_t * 47.0))
		_light(b + Vector2(0, -4), 26.0, EMBER, 0.28 * flick)
	# drifting necrotic motes
	for mo in _motes:
		var y: float = mo.p.y - fmod(_t * mo.sp, 40.0)
		var x: float = mo.p.x + sin(_t * 0.8 + mo.ph) * 4.0
		_light(Vector2(x, y), 3.0, accent, 0.30)


## Draws one additive glow of radius `r` tinted `col` at `intensity` (0–1).
func _light(pos: Vector2, r: float, col: Color, intensity: float) -> void:
	draw_texture_rect(_glow, Rect2(pos - Vector2(r, r), Vector2(r * 2.0, r * 2.0)), false,
		Color(col.r, col.g, col.b, intensity))


## Soft radial glow texture (white, alpha falls off to the edge). Tinted per-light via modulate.
func _make_glow(size: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c := size / 2.0
	for y in size:
		for x in size:
			var d := Vector2(x - c + 0.5, y - c + 0.5).length() / c
			var a := clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)
