extends Control
## Hub scene ("The Crypt") — the meta screen and the game's entry point (GDD §5/§10).
##
## The skill tree is a **necromantic sigil** (art-direction §10): a central glowing skull-core with
## vein-branches radiating to the route nodes, concentric sigil rings framing it. Node states read
## at a glance — owned (accent glow), available (amber pulse), locked (dim behind its gate), or
## met-but-unaffordable (amber dim). Veins light up as a branch is unlocked. Custom-drawn smooth
## (the UI is the smooth layer); clicking an available node buys it via SkillTree and autosaves.
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
const R_OUTER := 82.0
const NODE_R := 8.5

# --- palette (art-direction §3) ---
const ACCENT := Color(0.39, 0.89, 0.60)   # necrotic — owned / lit veins / core
const AMBER := Color(0.93, 0.66, 0.29)    # available (buyable)
const DIMV := Color(0.44, 0.42, 0.52)     # locked (violet-grey)
const BONE := Color(0.93, 0.89, 0.79)
const VOID := Color(0.045, 0.04, 0.075)
const HAIR := Color(0.39, 0.89, 0.60, 0.55)

var _balance_label: Label
var _sigil_nodes: Array = []   # {id, pos, route, tier}
var _hover: String = ""
var _t: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_sigil()
	_build_chrome()
	_refresh()


## Precomputes each node's position on its spoke (done once; states are read live in _draw).
func _build_sigil() -> void:
	_sigil_nodes.clear()
	for i in ROUTES.size():
		var ang := -PI / 2.0 + i * TAU / ROUTES.size()
		var dir := Vector2(cos(ang), sin(ang))
		var ids: Array = ROUTES[i]["nodes"]
		_sigil_nodes.append({"id": ids[0], "pos": CENTER + dir * R_INNER, "route": i, "tier": 0})
		_sigil_nodes.append({"id": ids[1], "pos": CENTER + dir * R_OUTER, "route": i, "tier": 1})


## Title / balance / Begin — real Controls (top & bottom), clear of the sigil. They ignore mouse
## so the sigil area's clicks reach this Control's `_gui_input` (the Begin button keeps its own).
func _build_chrome() -> void:
	# NB: the sigil is drawn in this Control's own _draw(); child Controls render on top of it, so
	# the background is painted in _draw() (not an opaque child, which would hide the sigil).
	var title := _label("THE CRYPT", 18, BONE, Vector2(14, 8))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("outline_size", 3)
	_label("Spend Grave Bones on the sigil, then rise.", 9, DIMV.lerp(BONE, 0.4), Vector2(15, 32))

	_balance_label = _label("", 12, ACCENT, Vector2(346, 12))
	_balance_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	_balance_label.add_theme_constant_override("outline_size", 3)

	var begin := Button.new()
	begin.text = "Begin Run  ›"
	begin.focus_mode = Control.FOCUS_NONE
	begin.position = Vector2(186, 244)
	begin.custom_minimum_size = Vector2(108, 20)
	begin.add_theme_font_size_override("font_size", 12)
	begin.add_theme_color_override("font_color", BONE)
	begin.add_theme_color_override("font_hover_color", Color.WHITE)
	begin.add_theme_stylebox_override("normal", _flat_box(VOID, HAIR, true))
	begin.add_theme_stylebox_override("hover", _flat_box(Color(0.09, 0.08, 0.15, 0.95), HAIR, true))
	begin.add_theme_stylebox_override("pressed", _flat_box(Color(0.09, 0.08, 0.15, 0.95), HAIR, true))
	begin.pressed.connect(_on_begin_run)
	add_child(begin)


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
	# route titles just past each outer node, aligned outward so they never overlap the node/cost
	var font := get_theme_default_font()
	for i in ROUTES.size():
		var ang := -PI / 2.0 + i * TAU / ROUTES.size()
		var dir := Vector2(cos(ang), sin(ang))
		var title: String = ROUTES[i]["title"]
		var tw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		var tp: Vector2 = CENTER + dir * (R_OUTER + NODE_R + 7.0) + Vector2(0, 3)
		if dir.x < -0.3:
			tp.x -= tw                    # left spoke: text ends at the node, extends outward
		elif dir.x <= 0.3:
			tp.x -= tw / 2.0              # top/bottom spoke: centre
		draw_string(font, tp, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, DIMV.lerp(BONE, 0.45))
	# nodes
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


func _draw_node(n: Dictionary, font: Font) -> void:
	var pos: Vector2 = n["pos"]
	var st := _node_state(n["id"])
	var pulse := 0.5 + 0.5 * sin(_t * 3.0)
	match st:
		"owned":
			_glow(pos, 15.0, ACCENT, 0.5)
			draw_circle(pos, NODE_R, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.85))
			draw_arc(pos, NODE_R, 0.0, TAU, 28, Color.WHITE.lerp(ACCENT, 0.5), 1.5, true)
			draw_circle(pos, 2.4, VOID)
		"avail":
			_glow(pos, 13.0, AMBER, 0.18 + 0.16 * pulse)
			draw_circle(pos, NODE_R, VOID)
			draw_arc(pos, NODE_R, 0.0, TAU, 28, Color(AMBER.r, AMBER.g, AMBER.b, 0.55 + 0.45 * pulse), 1.5, true)
			draw_circle(pos, 2.2, Color(AMBER.r, AMBER.g, AMBER.b, 0.9))
			_cost_label(pos, n["id"], AMBER, font)
		"poor":
			draw_circle(pos, NODE_R, VOID)
			draw_arc(pos, NODE_R, 0.0, TAU, 28, Color(AMBER.r, AMBER.g, AMBER.b, 0.34), 1.0, true)
			draw_circle(pos, 2.0, Color(AMBER.r, AMBER.g, AMBER.b, 0.5))
			_cost_label(pos, n["id"], Color(AMBER.r, AMBER.g, AMBER.b, 0.55), font)
		_:
			draw_circle(pos, NODE_R, Color(VOID.r, VOID.g, VOID.b, 0.85))
			draw_arc(pos, NODE_R, 0.0, TAU, 28, Color(DIMV.r, DIMV.g, DIMV.b, 0.5), 1.0, true)
			draw_circle(pos, 2.0, Color(DIMV.r, DIMV.g, DIMV.b, 0.6))
	if _hover == n["id"] and st != "locked":
		draw_arc(pos, NODE_R + 2.5, 0.0, TAU, 30, Color(1, 1, 1, 0.5), 1.0, true)


func _cost_label(pos: Vector2, id: String, col: Color, font: Font) -> void:
	var cost := int(SkillTree.get_node_def(id).get("cost", 0))
	var txt := str(cost)
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	draw_string(font, pos + Vector2(-w / 2.0, NODE_R + 9.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, col)


func _glow(pos: Vector2, r: float, col: Color, intensity: float) -> void:
	for i in 5:
		var t := i / 5.0
		draw_circle(pos, r * (1.0 - t * 0.7), Color(col.r, col.g, col.b, intensity * (1.0 - t) * 0.5))


## The central skull-core: a dark cranium with an accent rim, glowing eyes, a hint of jaw.
func _draw_core() -> void:
	var pulse := 0.5 + 0.5 * sin(_t * 2.0)
	_glow(CENTER, 24.0, ACCENT, 0.28 + 0.10 * pulse)
	# cranium
	draw_circle(CENTER, 12.0, Color(0.08, 0.07, 0.11))
	draw_arc(CENTER, 12.0, PI, TAU, 24, Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.75), 1.5, true)
	# jaw
	draw_rect(Rect2(CENTER.x - 5.0, CENTER.y + 8.0, 10.0, 5.0), Color(0.08, 0.07, 0.11))
	draw_rect(Rect2(CENTER.x - 5.0, CENTER.y + 8.0, 10.0, 5.0), Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.5), false, 1.0)
	for tx in [-3.0, 0.0, 3.0]:
		draw_line(CENTER + Vector2(tx, 8.0), CENTER + Vector2(tx, 13.0), Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.3), 1.0)
	# glowing eye sockets
	var eye := Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.8 + 0.2 * pulse)
	_glow(CENTER + Vector2(-4.0, -1.0), 5.0, ACCENT, 0.5)
	_glow(CENTER + Vector2(4.0, -1.0), 5.0, ACCENT, 0.5)
	draw_circle(CENTER + Vector2(-4.0, -1.0), 2.2, eye)
	draw_circle(CENTER + Vector2(4.0, -1.0), 2.2, eye)
	# nasal
	draw_colored_polygon(PackedVector2Array([CENTER + Vector2(0, 2), CENTER + Vector2(-1.4, 6),
		CENTER + Vector2(1.4, 6)]), Color(0.05, 0.04, 0.08))


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
	# anchor beside the hovered node, clamped on-screen
	var pos := _node_pos(id) + Vector2(14, -card.y / 2.0)
	pos.x = clampf(pos.x, 6.0, 480.0 - card.x - 6.0)
	pos.y = clampf(pos.y, 44.0, 270.0 - card.y - 26.0)
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


## The node id whose disc contains `p` (local coords), or "" if none.
func _node_at(p: Vector2) -> String:
	for n in _sigil_nodes:
		if p.distance_to(n["pos"]) <= NODE_R + 2.0:
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


func _on_begin_run() -> void:
	get_tree().change_scene_to_file(RUN_SCENE)


