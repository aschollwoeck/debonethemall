extends Node2D
class_name Phylactery
## The objective enemies march toward (GDD §5). A physical on-map object holding the
## player's unlife. Enemies that reach it deplete its life; at zero the run ends.

signal life_changed(current: int, max_life: int)
signal destroyed

@export var max_life: int = 20

var life: int

var _pulse: float = 0.0


func _ready() -> void:
	life = max_life


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
	var glow := 0.55 + 0.25 * sin(_pulse * 2.0)
	var frac := float(life) / float(max_life) if max_life > 0 else 0.0
	# base color shifts from green (healthy) toward red (near death)
	var core := Color(0.2, 0.9, 0.5).lerp(Color(0.9, 0.2, 0.25), 1.0 - frac)
	# aura
	draw_circle(Vector2.ZERO, 12.0, Color(core.r, core.g, core.b, 0.15 * glow))
	# crystal body (diamond)
	var pts := PackedVector2Array([
		Vector2(0, -10), Vector2(6, 0), Vector2(0, 10), Vector2(-6, 0),
	])
	draw_colored_polygon(pts, Color(core.r, core.g, core.b, 0.9))
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color(1, 1, 1, 0.6 * glow), 1.0)
	# inner spark
	draw_circle(Vector2.ZERO, 2.0, Color(1, 1, 1, glow))
