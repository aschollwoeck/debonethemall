extends CanvasLayer
class_name DialogueCard
## Between-level story overlay (M3 slice 2, docs/M3-act-one.md). Plays a sequence of dialogue
## `beats` — each {who: "master"|"you", name, line} — as flat vector cards over the scene: the
## Master's cruel taunts (bloodmark) vs. the slave's simmering inner voice (necrotic). Click or
## press Continue to advance; emits `finished` after the last beat, then frees itself.
##
## Sits above the HUD (high layer) and dims + captures input, so nothing behind it reacts.

signal finished

# palette (art-direction §3 / vector UI §10)
const BONE := Color(0.93, 0.89, 0.79)
const DIM := Color(0.62, 0.58, 0.68)
const MASTER_COL := Color("c8434a")   # bloodmark — the Master
const YOU_COL := Color(0.39, 0.89, 0.60)   # necrotic — your inner voice
const PANEL := Color(0.05, 0.04, 0.09, 0.98)

var _beats: Array = []
var _i: int = 0
var _dim: ColorRect
var _speaker: Label
var _line: Label


## Starts the sequence. `beats` is an Array of {who, name, line}. Does nothing (and finishes
## immediately) if empty.
func play(beats: Array) -> void:
	_beats = beats
	_i = 0
	if _beats.is_empty():
		_finish()
		return
	if _dim == null:
		_build()
	_show_beat()


## Index of the beat currently shown (for tests / callers).
func current_index() -> int:
	return _i


func _build() -> void:
	layer = 30   # above the HUD (its own CanvasLayer at layer 1)
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.62)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP   # swallow clicks meant for the game behind
	add_child(_dim)

	var card := PanelContainer.new()
	card.position = Vector2(64, 88)
	card.custom_minimum_size = Vector2(352, 0)
	var box := StyleBoxFlat.new()
	box.bg_color = PANEL
	box.set_corner_radius_all(2)
	box.set_border_width_all(1)
	box.border_color = Color(YOU_COL.r, YOU_COL.g, YOU_COL.b, 0.5)
	box.set_content_margin_all(12)
	box.shadow_color = Color(0, 0, 0, 0.55)
	box.shadow_size = 10
	card.add_theme_stylebox_override("panel", box)
	_dim.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 7)
	card.add_child(vb)

	_speaker = Label.new()
	_speaker.add_theme_font_size_override("font_size", 12)
	vb.add_child(_speaker)

	_line = Label.new()
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.custom_minimum_size = Vector2(328, 0)
	_line.add_theme_font_size_override("font_size", 11)
	_line.add_theme_color_override("font_color", BONE)
	vb.add_child(_line)

	var hint := Label.new()
	hint.text = "Continue  ›"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 9)
	hint.add_theme_color_override("font_color", DIM)
	vb.add_child(hint)


func _show_beat() -> void:
	var beat: Dictionary = _beats[_i]
	_speaker.text = beat.get("name", "")
	_speaker.add_theme_color_override("font_color", MASTER_COL if beat.get("who") == "master" else YOU_COL)
	_line.text = beat.get("line", "")


func _input(event: InputEvent) -> void:
	if _dim == null:
		return
	var advance: bool = (event is InputEventMouseButton and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT)
	if not advance and event.is_action_pressed("ui_accept"):
		advance = true
	if advance:
		get_viewport().set_input_as_handled()
		_advance()


## Advances to the next beat, or finishes after the last. (Public for tests.)
func _advance() -> void:
	_i += 1
	if _i >= _beats.size():
		_finish()
	else:
		_show_beat()


func _finish() -> void:
	finished.emit()
	queue_free()
