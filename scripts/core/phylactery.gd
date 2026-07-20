extends Node2D
class_name Phylactery
## The objective enemies march toward (GDD §5) — a faceted crystal on a rune-etched stone dais
## that holds the player's unlife. Enemies that reach it deplete its life; at zero the run ends. As
## life falls the crystal shifts from necrotic green toward blood-red and fractures visibly.
## Its glow pool is provided by the lighting pass (world/lighting.gd); this draws the object.

signal life_changed(current: int, max_life: int)
signal destroyed

@export var max_life: int = 20

var life: int

# life-driven colour ramps (healthy necrotic → dying blood)
const NECRO := [Color("1a5836"), Color("2f9b63"), Color("6be3a0"), Color("d9ffe9")]  # lo/mid/hi/spark
const BLOOD := [Color("4d1013"), Color("9a262b"), Color("df4a4a"), Color("ffd0c6")]
const STONE_DARK := Color("0e0d16")
const STONE_RIM := Color("222131")
const STONE_LIT := Color("34323f")
const RUNE := Color("63e39a")

# crystal silhouette + facet geometry (local space, top point up)
const APEX := Vector2(0, -13)
var _sil := PackedVector2Array([Vector2(0, -13), Vector2(6, -4), Vector2(5, 4),
	Vector2(0, 10), Vector2(-5, 4), Vector2(-6, -4)])

var _pulse: float = 0.0
var _cracks: Array = []   # Array[PackedVector2Array] — revealed progressively as life falls


func _ready() -> void:
	life = max_life
	# fracture lines across the crystal, shown in order as life drops
	_cracks = [
		PackedVector2Array([Vector2(-3, -6), Vector2(1, -1), Vector2(-1, 5)]),
		PackedVector2Array([Vector2(3, -4), Vector2(0, 1), Vector2(2, 7)]),
		PackedVector2Array([Vector2(0, -9), Vector2(-2, -2), Vector2(1, 3)]),
		PackedVector2Array([Vector2(-4, 0), Vector2(0, 3), Vector2(-1, 8)]),
		PackedVector2Array([Vector2(2, -8), Vector2(-1, -2), Vector2(0, 2)]),
	]


func _process(delta: float) -> void:
	_pulse = fmod(_pulse + delta, TAU)
	queue_redraw()


func take_damage(amount: int) -> void:
	if life <= 0:
		return
	life = max(0, life - amount)
	life_changed.emit(life, max_life)
	queue_redraw()
	if life <= 0:
		destroyed.emit()


func _draw() -> void:
	var frac := float(life) / float(max_life) if max_life > 0 else 0.0
	var t := 1.0 - frac                     # 0 healthy → 1 dying
	var pulse := 0.5 + 0.5 * sin(_pulse * 2.0)
	var lo: Color = NECRO[0].lerp(BLOOD[0], t)
	var mid: Color = NECRO[1].lerp(BLOOD[1], t)
	var hi: Color = NECRO[2].lerp(BLOOD[2], t)
	var spark: Color = NECRO[3].lerp(BLOOD[3], t)

	_draw_dais()

	# crystal floats + bobs gently above the dais
	var c := Vector2(0, -3 + sin(_pulse) * 0.8)
	draw_set_transform(c, 0.0, Vector2.ONE)
	# facets: left (dark) · right (mid) · centre highlight sliver · top glint
	draw_colored_polygon(PackedVector2Array([APEX, Vector2(-6, -4), Vector2(-5, 4), Vector2(0, 10)]), lo)
	draw_colored_polygon(PackedVector2Array([APEX, Vector2(6, -4), Vector2(5, 4), Vector2(0, 10)]), mid)
	draw_colored_polygon(PackedVector2Array([APEX, Vector2(-1.5, -3), Vector2(0, 10), Vector2(1.5, -3)]), hi)
	draw_colored_polygon(PackedVector2Array([APEX, Vector2(-3, -6), Vector2(3, -6)]), hi.lerp(spark, 0.5))
	# revealed cracks
	var shown := int(round(t * _cracks.size()))
	for i in shown:
		draw_polyline(_cracks[i], Color(0.02, 0.02, 0.03, 0.9), 1.0)
	# outline + inner spark
	draw_polyline(_sil + PackedVector2Array([APEX]), Color(spark.r, spark.g, spark.b, 0.5 + 0.4 * pulse), 1.0)
	draw_circle(Vector2(0, -1), 1.6 + 0.6 * pulse, Color(spark.r, spark.g, spark.b, 0.7 + 0.3 * pulse))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_dais() -> void:
	draw_circle(Vector2(0, 13), 15.0, Color(0, 0, 0, 0.4))            # shadow
	_ellipse(Vector2(0, 11), 14.0, 5.5, STONE_DARK)                   # base
	_ellipse(Vector2(0, 9), 12.0, 4.5, STONE_RIM)                     # rim
	_ellipse(Vector2(0, 9), 8.5, 3.0, STONE_LIT)                      # lit inner
	_ellipse(Vector2(0, 9), 5.0, 1.8, STONE_DARK)                    # socket the crystal sits in
	for i in 4:                                                        # rune ticks on the rim
		var a := PI + i * PI / 3.0
		var p := Vector2(cos(a) * 12.0, 9.0 + sin(a) * 4.0)
		draw_rect(Rect2(p.x - 1, p.y - 1, 2, 2), RUNE)


func _ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := i * TAU / 20.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)
