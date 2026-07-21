extends Control
## Hub scene ("The Crypt") — the meta screen and the game's entry point (GDD §5/§10).
##
## The skill tree is a **necromantic sigil** (art-direction §10): a central glowing skull-core with
## vein-branches radiating to the route nodes, concentric sigil rings framing it. Each node is a
## compact **rectangular card** (cost, or a gem when owned); states read at a glance — owned
## (accent glow), available (amber pulse), locked (dim behind its gate), or met-but-unaffordable
## (amber dim). Veins light up as a branch is unlocked. Custom-drawn smooth (the UI is the smooth
## layer); hovering a card shows its name/description, and clicking an available card buys it.
##
## Buying/routing/currency all go through SkillTree + MetaState (unchanged); this file only changes
## how the tree is presented and how nodes are picked.

const RUN_SCENE := "res://scenes/main/main.tscn"

## Display grouping of nodes into routes (spokes). Order sets the spoke angle. Each route lists its
## nodes inner→outer (tier 1 then its tier-2 follow-up). A display concern, so it lives here.
const ROUTES := [
	{"title": "Golem", "nodes": ["unlock_golem", "golem_might"]},
	{"title": "Wraith", "nodes": ["unlock_wraith", "wraith_might"]},
	{"title": "Malice", "nodes": ["malice_1", "malice_2"]},
	{"title": "Hoard", "nodes": ["hoard_1", "hoard_2"]},
	{"title": "Phylactery", "nodes": ["phylactery_1", "phylactery_2"]},
]

# --- sigil geometry (logical 480×270 space) ---
const CENTER := Vector2(240, 146)
const R_INNER := 44.0
const R_OUTER := 88.0
const CARD := Vector2(40, 20)   # compact rectangular node
# Keep the cards non-overlapping if you retune these: a route's inner+outer cards share a
# near-horizontal spoke at the sides, so require (R_OUTER - R_INNER) > CARD.x * cos(18°) ≈ 38.
# (Current margin is ~2px; widening CARD.x or shrinking the radial gap will collide them.)

# --- palette (art-direction §3) ---
const ACCENT := Color(0.39, 0.89, 0.60)   # necrotic — owned / lit veins / core
const AMBER := Color(0.93, 0.66, 0.29)    # available (buyable)
const DIMV := Color(0.44, 0.42, 0.52)     # locked (violet-grey)
const BONE := Color(0.93, 0.89, 0.79)
const VOID := Color(0.045, 0.04, 0.075)
const HAIR := Color(0.39, 0.89, 0.60, 0.55)
const HAIR_DIM := Color(0.62, 0.68, 0.78, 0.20)   # faint neutral hairline (locked level chips)

var _balance_label: Label
var _sigil_nodes: Array = []   # {id, pos, route, tier}
var _hover: String = ""
var _t: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_sigil()
	_build_chrome()
	_refresh()


## Precomputes each node's card centre on its spoke (done once; states are read live in _draw).
func _build_sigil() -> void:
	_sigil_nodes.clear()
	for i in ROUTES.size():
		var ang := -PI / 2.0 + i * TAU / ROUTES.size()
		var dir := Vector2(cos(ang), sin(ang))
		var ids: Array = ROUTES[i]["nodes"]
		_sigil_nodes.append({"id": ids[0], "pos": CENTER + dir * R_INNER, "route": i, "tier": 0})
		_sigil_nodes.append({"id": ids[1], "pos": CENTER + dir * R_OUTER, "route": i, "tier": 1})


## Title / balance / level bar — real Controls (top & bottom), clear of the sigil. The Labels
## ignore mouse so sigil-area clicks reach `_gui_input`; the level chips (Buttons) keep their own.
func _build_chrome() -> void:
	# NB: the sigil is drawn in this Control's own _draw(); child Controls render on top of it, so
	# the background is painted in _draw() (not an opaque child, which would hide the sigil).
	var title := _label("THE CRYPT", 18, BONE, Vector2(14, 8))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("outline_size", 3)

	var sub := "Act I — Complete. The Master is bones; Act II stirs..." if Levels.act1_complete() \
		else "Act I — spend Grave Bones on the sigil, then descend."
	_label(sub, 9, ACCENT if Levels.act1_complete() else DIMV.lerp(BONE, 0.4), Vector2(15, 30))

	_balance_label = _label("", 12, ACCENT, Vector2(346, 12))
	_balance_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	_balance_label.add_theme_constant_override("outline_size", 3)

	_build_level_bar()


## The Act I level chips along the bottom: click a cleared/available crypt to descend into it
## (M3 level framework). Cleared = accent, next-to-play = amber, locked = dim/disabled.
func _build_level_bar() -> void:
	var n := Levels.act1_count()
	var bw := 40.0
	var gap := 5.0
	var x0 := (480.0 - (n * bw + (n - 1) * gap)) / 2.0
	for i in n:
		var lvl: Level = Levels.act1_level(i)
		var cleared := MetaState.is_level_cleared(lvl.id)
		var unlocked := Levels.is_act1_unlocked(i)
		var accent := Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.7)
		var amber := Color(AMBER.r, AMBER.g, AMBER.b, 0.7)
		var border := accent if cleared else (amber if unlocked else HAIR_DIM)
		var fg := ACCENT if cleared else (AMBER if unlocked else DIMV)
		var b := Button.new()
		b.text = "B" if lvl.is_boss else str(i + 1)
		b.tooltip_text = "%s%s" % [lvl.name, "  ✓" if cleared else ("" if unlocked else "  (locked)")]
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(x0 + i * (bw + gap), 246)
		b.custom_minimum_size = Vector2(bw, 20)
		b.add_theme_font_size_override("font_size", 11)
		b.add_theme_color_override("font_color", fg)
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_color_override("font_disabled_color", Color(DIMV.r, DIMV.g, DIMV.b, 0.7))
		b.add_theme_stylebox_override("normal", _flat_box(VOID, border, cleared))
		b.add_theme_stylebox_override("hover", _flat_box(Color(0.09, 0.08, 0.15, 0.95), border, true))
		b.add_theme_stylebox_override("pressed", _flat_box(Color(0.09, 0.08, 0.15, 0.95), border, true))
		b.add_theme_stylebox_override("disabled", _flat_box(Color(0.04, 0.035, 0.07, 0.85), HAIR_DIM, false))
		if unlocked:
			b.pressed.connect(_enter_level.bind(i))
		else:
			b.disabled = true
		add_child(b)


func _label(text: String, size: int, color: Color, pos: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l


func _flat_box(bg: Color, border: Color, glow: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(1)
	s.set_border_width_all(1)
	s.border_color = border
	s.set_content_margin_all(4)
	if glow:
		s.shadow_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.28)
		s.shadow_size = 4
	return s


func _refresh() -> void:
	_balance_label.text = "Grave Bones  %d" % MetaState.grave_bones
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()   # only the pulses/glows animate


# ---------------------------------------------------------------- drawing (the sigil)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 480, 270), Color("0a0712"))   # background (painted here, not a child)
	# framing rings
	_ring(R_OUTER + 12.0, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.10), 1.0)
	_ring(R_OUTER, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.16), 1.0)
	_ring(R_INNER, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.16), 1.0)
	_ring(20.0, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.22), 1.0)
	# veins core→inner→outer, lit where the branch is owned
	for i in ROUTES.size():
		var ang := -PI / 2.0 + i * TAU / ROUTES.size()
		var dir := Vector2(cos(ang), sin(ang))
		var inner: Vector2 = CENTER + dir * R_INNER
		var outer: Vector2 = CENTER + dir * R_OUTER
		_vein(CENTER + dir * 14.0, inner, _vein_color(ROUTES[i]["nodes"][0]))
		_vein(inner, outer, _vein_color(ROUTES[i]["nodes"][1]))
	# route titles just past each outer card, aligned outward so they never overlap a card
	var font := get_theme_default_font()
	for i in ROUTES.size():
		var ang := -PI / 2.0 + i * TAU / ROUTES.size()
		var dir := Vector2(cos(ang), sin(ang))
		var title: String = ROUTES[i]["title"]
		var tw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		var tp: Vector2 = CENTER + dir * (R_OUTER + 24.0) + Vector2(0, 3)
		if dir.x < -0.3:
			tp.x -= tw                    # left spoke: text ends at the card, extends outward
		elif dir.x <= 0.3:
			tp.x -= tw / 2.0              # top/bottom spoke: centre
		draw_string(font, tp, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, DIMV.lerp(BONE, 0.45))
	# node cards
	for n in _sigil_nodes:
		_draw_node(n, font)
	# core + hovered info card (on top)
	_draw_core()
	if _hover != "":
		_draw_info_card(_hover, font)


func _ring(r: float, col: Color, width: float) -> void:
	draw_arc(CENTER, r, 0.0, TAU, 72, col, width, true)


## A gently-bowed vein between two points (quadratic bezier, offset perpendicular for the swirl).
func _vein(a: Vector2, b: Vector2, col: Color) -> void:
	var ctrl := (a + b) * 0.5 + (b - a).orthogonal().normalized() * 6.0
	var pts := PackedVector2Array()
	for i in 13:
		var t := i / 12.0
		pts.append(a.lerp(ctrl, t).lerp(ctrl.lerp(b, t), t))
	draw_polyline(pts, col, 1.6, true)


func _vein_color(id: String) -> Color:
	if MetaState.is_unlocked(id):
		return Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.75)   # lit
	return Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.14)       # dormant


## Node state → "owned" | "avail" | "poor" | "locked".
func _node_state(id: String) -> String:
	if MetaState.is_unlocked(id):
		return "owned"
	if SkillTree.can_purchase(id):
		return "avail"
	if SkillTree.prereqs_met(id):
		return "poor"   # reachable but can't afford yet
	return "locked"


## A compact rectangular card: cost when buyable, a gem when owned, dim when locked.
func _draw_node(n: Dictionary, font: Font) -> void:
	var pos: Vector2 = n["pos"]
	var st := _node_state(n["id"])
	var rect := Rect2(pos - CARD * 0.5, CARD)
	var pulse := 0.5 + 0.5 * sin(_t * 3.0)
	var bg := VOID
	var border: Color
	var txt := str(int(SkillTree.get_node_def(n["id"]).get("cost", 0)))
	var txt_col := BONE
	match st:
		"owned":
			_glow(pos, 15.0, ACCENT, 0.45)
			bg = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.22)
			border = Color.WHITE.lerp(ACCENT, 0.5)
			txt = ""   # the green gem conveys ownership
		"avail":
			_glow(pos, 12.0, AMBER, 0.14 + 0.14 * pulse)
			border = Color(AMBER.r, AMBER.g, AMBER.b, 0.55 + 0.45 * pulse)
			txt_col = AMBER
		"poor":
			border = Color(AMBER.r, AMBER.g, AMBER.b, 0.34)
			txt_col = Color(AMBER.r, AMBER.g, AMBER.b, 0.55)
		_:
			bg = Color(VOID.r, VOID.g, VOID.b, 0.85)
			border = Color(DIMV.r, DIMV.g, DIMV.b, 0.5)
			txt = ""
	draw_rect(rect, bg)
	draw_rect(rect, border, false, 1.0)
	if _hover == n["id"] and st != "locked":
		draw_rect(rect.grow(2.0), Color(1, 1, 1, 0.5), false, 1.0)
	if st == "owned":
		draw_circle(pos, 3.2, VOID)
		draw_circle(pos, 1.6, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.9))
	elif txt != "":
		var sz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		draw_string(font, pos + Vector2(-sz.x / 2.0, 3.5), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, txt_col)


func _glow(pos: Vector2, r: float, col: Color, intensity: float) -> void:
	for i in 5:
		var t := i / 5.0
		draw_circle(pos, r * (1.0 - t * 0.7), Color(col.r, col.g, col.b, intensity * (1.0 - t) * 0.5))


## The central skull-core: a dark cranium with an accent rim, glowing eyes, a hint of jaw.
func _draw_core() -> void:
	var pulse := 0.5 + 0.5 * sin(_t * 2.0)
	_glow(CENTER, 22.0, ACCENT, 0.26 + 0.10 * pulse)
	# cranium
	draw_circle(CENTER, 11.0, Color(0.08, 0.07, 0.11))
	draw_arc(CENTER, 11.0, PI, TAU, 24, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.75), 1.5, true)
	# jaw
	draw_rect(Rect2(CENTER.x - 4.5, CENTER.y + 7.0, 9.0, 5.0), Color(0.08, 0.07, 0.11))
	draw_rect(Rect2(CENTER.x - 4.5, CENTER.y + 7.0, 9.0, 5.0), Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.5), false, 1.0)
	for tx in [-2.5, 0.0, 2.5]:
		draw_line(CENTER + Vector2(tx, 7.0), CENTER + Vector2(tx, 12.0), Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.3), 1.0)
	# glowing eye sockets
	var eye := Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.8 + 0.2 * pulse)
	_glow(CENTER + Vector2(-3.5, -1.0), 4.5, ACCENT, 0.5)
	_glow(CENTER + Vector2(3.5, -1.0), 4.5, ACCENT, 0.5)
	draw_circle(CENTER + Vector2(-3.5, -1.0), 2.0, eye)
	draw_circle(CENTER + Vector2(3.5, -1.0), 2.0, eye)
	# nasal
	draw_colored_polygon(PackedVector2Array([CENTER + Vector2(0, 1.5), CENTER + Vector2(-1.3, 5.0),
		CENTER + Vector2(1.3, 5.0)]), Color(0.05, 0.04, 0.08))


## A small floating card with the hovered node's name, status and description.
func _draw_info_card(id: String, font: Font) -> void:
	var def := SkillTree.get_node_def(id)
	var node_name: String = def.get("name", id)
	var desc: String = def.get("desc", "")
	var st := _node_state(id)
	var status := "Owned" if st == "owned" else ("Cost  %d" % int(def.get("cost", 0)))
	if st == "locked":
		status = "Locked — needs its prerequisite"
	var status_col := ACCENT if st == "owned" else (AMBER if st != "locked" else DIMV)
	var card := Vector2(154, 54)
	# anchor beside the hovered card, clamped on-screen
	var pos := _node_pos(id) + Vector2(CARD.x * 0.5 + 6.0, -card.y / 2.0)
	pos.x = clampf(pos.x, 6.0, 480.0 - card.x - 6.0)
	pos.y = clampf(pos.y, 40.0, 270.0 - card.y - 26.0)
	draw_rect(Rect2(pos, card), Color(0.035, 0.03, 0.07, 0.97))
	draw_rect(Rect2(pos, card), HAIR, false, 1.0)
	draw_string(font, pos + Vector2(8, 15), node_name, HORIZONTAL_ALIGNMENT_LEFT, card.x - 16, 9, BONE)
	draw_string(font, pos + Vector2(8, 28), status, HORIZONTAL_ALIGNMENT_LEFT, card.x - 16, 8, status_col)
	draw_multiline_string(font, pos + Vector2(8, 40), desc, HORIZONTAL_ALIGNMENT_LEFT, card.x - 16, 8, 2,
		DIMV.lerp(BONE, 0.55))


# ---------------------------------------------------------------- interaction

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var h := _node_at(event.position)
		if h != _hover:
			_hover = h
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var id := _node_at(event.position)
		if id != "" and SkillTree.can_purchase(id):
			_on_buy(id)


## The node id whose card contains `p` (local coords), or "" if none.
func _node_at(p: Vector2) -> String:
	for n in _sigil_nodes:
		if Rect2(n["pos"] - CARD * 0.5, CARD).has_point(p):
			return n["id"]
	return ""


func _node_pos(id: String) -> Vector2:
	for n in _sigil_nodes:
		if n["id"] == id:
			return n["pos"]
	return CENTER


func _on_buy(id: String) -> void:
	if SkillTree.purchase(id):
		MetaState.save_game()   # autosave on tree purchase (M1 spec §4)
		_refresh()


## Descends into Act I level `index` (if it's unlocked): hands the level to the run scene.
func _enter_level(index: int) -> void:
	var lvl := Levels.act1_level(index)
	if lvl == null or not Levels.is_act1_unlocked(index):
		return
	RunContext.select(lvl, index)
	get_tree().change_scene_to_file(RUN_SCENE)
