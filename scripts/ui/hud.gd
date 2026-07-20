extends CanvasLayer
class_name HUD
## Code-built in-run HUD: Bone Dust / phylactery-life / wave / Grave Bones-harvest readouts,
## minion-select buttons, a start-wave button, and a centered end-game panel (with the banked
## harvest). Emits intent signals; the run orchestrator wires them.

signal minion_selected(kind: String)
signal start_wave_pressed
signal return_to_hub_pressed

const ARCHER := "archer"
const GOLEM := "golem"
const PANEL_BG := Color(0.10, 0.08, 0.12, 0.92)

var _dust_label: Label
var _life_label: Label
var _wave_label: Label
var _harvest_label: Label
var _hint_label: Label
var _archer_btn: Button
var _golem_btn: Button
var _start_btn: Button
var _end_panel: PanelContainer
var _end_label: Label

var _selected: String = ""


func _ready() -> void:
	_build()


func _build() -> void:
	# Fixed 480x270 viewport → absolute positions are safe and simplest.
	# ---- top status row ----
	_dust_label = _make_label(Vector2(8, 6), "Bone Dust: 0")
	_wave_label = _make_label(Vector2(8, 22), "Wave: -/-")
	_life_label = _make_label(Vector2(316, 6), "Phylactery: 0")
	_harvest_label = _make_label(Vector2(316, 22), "Harvest: +0")
	_harvest_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))

	# ---- minion select (bottom-left) ----
	_archer_btn = _make_button(Vector2(8, 236), Vector2(108, 22), "Archer (50)")
	_archer_btn.toggle_mode = true
	_archer_btn.pressed.connect(func(): _select(ARCHER))

	_golem_btn = _make_button(Vector2(122, 236), Vector2(108, 22), "Golem (80)")
	_golem_btn.toggle_mode = true
	_golem_btn.pressed.connect(func(): _select(GOLEM))

	# ---- start wave (bottom-right) ----
	_start_btn = _make_button(Vector2(388, 232), Vector2(84, 26), "Start Wave")
	_start_btn.pressed.connect(func(): start_wave_pressed.emit())

	# ---- hint (centered, above the button row) ----
	_hint_label = _make_label(Vector2.ZERO, "Select a minion below, then click a build slot to raise it.")
	_hint_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hint_label.offset_left = 0
	_hint_label.offset_right = 0
	_hint_label.offset_top = 216
	_hint_label.offset_bottom = 230
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 9)

	# ---- end-game panel ----
	_build_end_panel()


func _make_label(pos: Vector2, text: String) -> Label:
	var l := Label.new()
	l.position = pos
	l.text = text
	l.add_theme_font_size_override("font_size", 12)
	add_child(l)
	return l


func _make_button(pos: Vector2, size: Vector2, text: String) -> Button:
	var b := Button.new()
	b.position = pos
	b.custom_minimum_size = size
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	add_child(b)
	return b


func _build_end_panel() -> void:
	_end_panel = PanelContainer.new()
	_end_panel.position = Vector2(130, 80)   # centered in the 480x270 viewport
	_end_panel.custom_minimum_size = Vector2(220, 110)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.set_corner_radius_all(6)
	style.set_content_margin_all(14)
	_end_panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_end_panel.add_child(vbox)

	_end_label = Label.new()
	_end_label.text = ""
	_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_end_label)

	var retry := Button.new()
	retry.text = "Return to Crypt"
	retry.focus_mode = Control.FOCUS_NONE
	retry.pressed.connect(func(): return_to_hub_pressed.emit())
	vbox.add_child(retry)

	_end_panel.visible = false
	add_child(_end_panel)


func _select(kind: String) -> void:
	_selected = kind
	_archer_btn.button_pressed = kind == ARCHER
	_golem_btn.button_pressed = kind == GOLEM
	_archer_btn.toggle_mode = true
	_golem_btn.toggle_mode = true
	minion_selected.emit(kind)


# ---- public update API (called by Main) ----

func set_dust(amount: int) -> void:
	_dust_label.text = "Bone Dust: %d" % amount


func set_life(current: int, max_life: int) -> void:
	_life_label.text = "Phylactery: %d/%d" % [current, max_life]


func set_harvest(total: int) -> void:
	_harvest_label.text = "Harvest: +%d" % total


func set_wave(current: int, total: int, active: bool) -> void:
	_wave_label.text = "Wave: %d/%d%s" % [current, total, "  (in progress)" if active else ""]
	_start_btn.disabled = active


func clear_selection() -> void:
	_selected = ""
	_archer_btn.button_pressed = false
	_golem_btn.button_pressed = false


func show_end(won: bool, banked_bones: int) -> void:
	var headline := "The holy land kneels.\nYou win!" if won else "Your phylactery shatters...\nfor now."
	var bonus := "  (clear bonus!)" if won else ""
	_end_label.text = "%s\n\nHarvested %d Grave Bones%s" % [headline, banked_bones, bonus]
	_end_panel.visible = true
	_start_btn.disabled = true


func hide_end() -> void:
	_end_panel.visible = false
