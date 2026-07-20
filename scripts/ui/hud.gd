extends CanvasLayer
class_name HUD
## Vector in-run HUD (M2b restyle slice 7, docs/art-direction.md §10). Clean vector treatment —
## flat dark panels with a thin necrotic hairline border, minimal texture, high contrast against
## the pixel units: resource plaques (Bone Dust / Wave / Harvest), a phylactery life meter
## (green→red), flat buttons where the selected minion gets an accent hairline + glow, and flat
## panels for the upgrade popup and end screen. Emits intent signals; Main wires them.
##
## Public API is unchanged, so Main needs no edits.

signal minion_selected(kind: String)
signal start_wave_pressed
signal return_to_hub_pressed
signal upgrade_chosen(id: String)

# --- palette (vector UI, art-direction §3/§10) ---
const BONE := Color("ece3cb")
const INK_DIM := Color("6f6784")
const EMBER := Color("e8a24a")
const NECRO := Color("63e39a")
const BLOOD := Color("c8434a")
const PANEL := Color(0.05, 0.045, 0.09, 0.90)        # flat dark plaque bg
const PANEL_HI := Color(0.09, 0.08, 0.15, 0.95)      # hover / active bg
const PANEL_SOLID := Color(0.05, 0.04, 0.09, 0.98)   # opaque popup bg
const HAIR := Color(0.39, 0.89, 0.60, 0.55)          # necrotic accent hairline
const HAIR_DIM := Color(0.62, 0.68, 0.78, 0.20)      # faint neutral hairline (passive)
const ACCENT_GLOW := Color(0.39, 0.89, 0.60, 0.32)   # soft accent bloom on active elements

var _dust_val: Label
var _wave_val: Label
var _harvest_val: Label
var _life_fill: ColorRect
var _life_text: Label
var _hint_label: Label
var _minion_btns: Array[Button] = []
var _minion_ids: Array[String] = []
var _start_btn: Button
var _end_panel: PanelContainer
var _end_label: Label
var _upgrade_panel: PanelContainer
var _upgrade_vbox: VBoxContainer
var _upgrade_title: Label


func _ready() -> void:
	_build()


# ---------------------------------------------------------------- style helpers

## A flat vector box: solid dark bg, a 1px hairline border, near-square corners, no carved lip.
## An optional accent `glow` blooms softly behind active elements (no drop shadow otherwise).
func _sbox(bg: Color, border: Color, glow := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(1)
	s.set_border_width_all(1)
	s.border_color = border
	s.content_margin_left = 7; s.content_margin_right = 7
	s.content_margin_top = 3; s.content_margin_bottom = 4
	if glow.a > 0.0:
		s.shadow_color = glow; s.shadow_size = 4
	return s


## Applies flat vector styling to a button. kind: "stone" | "primary" | "toggle".
## Interactive/active states carry the necrotic accent hairline + glow; passive states a faint
## neutral hairline. A selected (toggled) minion reads by its accent outline (art-direction §10).
func _style_button(b: Button, kind: String) -> void:
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 11)
	b.add_theme_color_override("font_color", BONE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", NECRO)
	b.add_theme_color_override("font_focus_color", BONE)
	b.add_theme_color_override("font_disabled_color", INK_DIM)
	# normal: the primary CTA already wears the accent hairline; the rest a faint neutral one.
	var normal_border := HAIR if kind == "primary" else HAIR_DIM
	var normal_glow := ACCENT_GLOW if kind == "primary" else Color(0, 0, 0, 0)
	b.add_theme_stylebox_override("normal", _sbox(PANEL, normal_border, normal_glow))
	b.add_theme_stylebox_override("hover", _sbox(PANEL_HI, HAIR))
	# pressed (momentary) / toggled-selected: accent hairline + glow.
	b.add_theme_stylebox_override("pressed", _sbox(PANEL_HI, HAIR, ACCENT_GLOW))
	b.add_theme_stylebox_override("disabled", _sbox(Color(0.04, 0.035, 0.07, 0.85), HAIR_DIM))


## Flat dark popup frame (upgrade / end screen): solid bg, a necrotic hairline, a soft lift shadow.
func _panel_box() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_SOLID
	s.set_corner_radius_all(2)
	s.set_border_width_all(1)
	s.border_color = HAIR
	s.set_content_margin_all(12)
	s.shadow_color = Color(0, 0, 0, 0.5); s.shadow_size = 8
	return s


# ---------------------------------------------------------------- build

## A small stone plaque (prefix + coloured value) positioned absolutely. Returns the value label.
func _plaque(pos: Vector2, prefix: String, value_color: Color) -> Label:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.add_theme_stylebox_override("panel", _sbox(PANEL, HAIR_DIM))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	panel.add_child(row)
	var pl := Label.new()
	pl.text = prefix
	pl.add_theme_font_size_override("font_size", 10)
	pl.add_theme_color_override("font_color", INK_DIM)
	row.add_child(pl)
	var vl := Label.new()
	vl.add_theme_font_size_override("font_size", 11)
	vl.add_theme_color_override("font_color", value_color)
	row.add_child(vl)
	add_child(panel)
	return vl


func _build() -> void:
	# ---- resource plaques ----
	_dust_val = _plaque(Vector2(8, 6), "BONE DUST", EMBER)
	_wave_val = _plaque(Vector2(8, 28), "WAVE", BONE)

	# ---- phylactery life meter (top-right) ----
	var life_frame := Panel.new()
	life_frame.position = Vector2(316, 6)
	life_frame.custom_minimum_size = Vector2(150, 15)
	life_frame.size = Vector2(150, 15)
	life_frame.add_theme_stylebox_override("panel", _sbox(Color(0.03, 0.025, 0.06, 0.95), HAIR))
	add_child(life_frame)
	_life_fill = ColorRect.new()
	_life_fill.position = Vector2(318, 8)
	_life_fill.size = Vector2(146, 11)
	_life_fill.color = NECRO
	add_child(_life_fill)
	_life_text = Label.new()
	_life_text.position = Vector2(316, 5)
	_life_text.size = Vector2(150, 15)
	_life_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_life_text.add_theme_font_size_override("font_size", 9)
	_life_text.add_theme_color_override("font_color", Color("0a0812"))
	add_child(_life_text)

	_harvest_val = _plaque(Vector2(316, 28), "HARVEST +", NECRO)

	# ---- start wave (bottom-right) ----
	_start_btn = Button.new()
	_start_btn.position = Vector2(384, 232)
	_start_btn.custom_minimum_size = Vector2(88, 26)
	_start_btn.text = "Summon Wave"
	_style_button(_start_btn, "primary")
	_start_btn.pressed.connect(func(): start_wave_pressed.emit())
	add_child(_start_btn)

	# ---- hint (centred, above the button row) ----
	_hint_label = Label.new()
	_hint_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hint_label.offset_top = 216; _hint_label.offset_bottom = 230
	_hint_label.offset_left = 0; _hint_label.offset_right = 0
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 9)
	_hint_label.add_theme_color_override("font_color", INK_DIM)
	_hint_label.text = "Raise a minion, then click a build slot. Click a minion to upgrade it."
	add_child(_hint_label)

	_build_end_panel()
	_build_upgrade_panel()


func _build_end_panel() -> void:
	_end_panel = PanelContainer.new()
	_end_panel.position = Vector2(130, 78)
	_end_panel.custom_minimum_size = Vector2(220, 112)
	_end_panel.add_theme_stylebox_override("panel", _panel_box())
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	_end_panel.add_child(vbox)
	_end_label = Label.new()
	_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_label.add_theme_font_size_override("font_size", 13)
	_end_label.add_theme_color_override("font_color", BONE)
	vbox.add_child(_end_label)
	var btn := Button.new()
	btn.text = "Return to Crypt"
	_style_button(btn, "stone")
	btn.pressed.connect(func(): return_to_hub_pressed.emit())
	vbox.add_child(btn)
	_end_panel.visible = false
	add_child(_end_panel)


func _build_upgrade_panel() -> void:
	_upgrade_panel = PanelContainer.new()
	_upgrade_panel.position = Vector2(150, 70)
	_upgrade_panel.custom_minimum_size = Vector2(180, 0)
	_upgrade_panel.add_theme_stylebox_override("panel", _panel_box())
	_upgrade_vbox = VBoxContainer.new()
	_upgrade_vbox.add_theme_constant_override("separation", 6)
	_upgrade_panel.add_child(_upgrade_vbox)
	_upgrade_title = Label.new()
	_upgrade_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_upgrade_title.add_theme_font_size_override("font_size", 11)
	_upgrade_title.add_theme_color_override("font_color", NECRO)
	_upgrade_vbox.add_child(_upgrade_title)
	_upgrade_panel.visible = false
	add_child(_upgrade_panel)


# ---------------------------------------------------------------- selection

func _select(kind: String) -> void:
	for i in _minion_btns.size():
		_minion_btns[i].button_pressed = _minion_ids[i] == kind
	minion_selected.emit(kind)


# ---------------------------------------------------------------- public API (Main-facing)

## Builds the minion-select buttons from the run's available minions.
## Each entry: {"id": String, "name": String, "cost": int}.
func set_minions(minions: Array) -> void:
	for b in _minion_btns:
		b.queue_free()
	_minion_btns.clear()
	_minion_ids.clear()
	var x := 8
	for m in minions:
		var id: String = m["id"]
		var btn := Button.new()
		btn.position = Vector2(x, 236)
		btn.custom_minimum_size = Vector2(92, 22)
		btn.text = "%s (%d)" % [m["name"], m["cost"]]
		btn.toggle_mode = true
		_style_button(btn, "toggle")
		btn.pressed.connect(_select.bind(id))
		add_child(btn)
		_minion_btns.append(btn)
		_minion_ids.append(id)
		x += 96


func set_dust(amount: int) -> void:
	_dust_val.text = str(amount)


func set_life(current: int, max_life: int) -> void:
	var frac := clampf(float(current) / float(max_life), 0.0, 1.0) if max_life > 0 else 0.0
	_life_fill.size.x = 146.0 * frac
	_life_fill.color = NECRO.lerp(BLOOD, 1.0 - frac)   # bleeds red as it fails
	_life_text.text = "PHYLACTERY  %d/%d" % [current, max_life]


func set_harvest(total: int) -> void:
	_harvest_val.text = str(total)


func set_wave(current: int, total: int, active: bool) -> void:
	_wave_val.text = "%d/%d%s" % [current, total, "  •" if active else ""]
	_start_btn.disabled = active


func clear_selection() -> void:
	for b in _minion_btns:
		b.button_pressed = false


## Shows the upgrade choices for a clicked minion. `options`: [{id, label, cost}].
func show_upgrades(minion_name: String, options: Array) -> void:
	for child in _upgrade_vbox.get_children():
		if child != _upgrade_title:
			_upgrade_vbox.remove_child(child)
			child.queue_free()
	_upgrade_title.text = "Upgrade %s" % minion_name
	for opt in options:
		var id: String = opt["id"]
		var btn := Button.new()
		btn.text = "%s  (%d)" % [opt["label"], opt["cost"]]
		_style_button(btn, "stone")
		btn.disabled = int(opt["cost"]) > GameState.bone_dust
		btn.pressed.connect(func(): upgrade_chosen.emit(id))
		_upgrade_vbox.add_child(btn)
	_upgrade_panel.visible = true


func hide_upgrades() -> void:
	_upgrade_panel.visible = false
	for child in _upgrade_vbox.get_children():
		if child != _upgrade_title:
			_upgrade_vbox.remove_child(child)
			child.queue_free()


func show_end(won: bool, banked_bones: int) -> void:
	var headline := "The holy land kneels.\nYou win!" if won else "Your phylactery shatters...\nfor now."
	var bonus := "  (clear bonus!)" if won else ""
	_end_label.text = "%s\n\nHarvested %d Grave Bones%s" % [headline, banked_bones, bonus]
	_end_panel.visible = true
	_start_btn.disabled = true


func hide_end() -> void:
	_end_panel.visible = false
