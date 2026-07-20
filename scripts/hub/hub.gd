extends Control
## Hub scene ("The Crypt") — the meta screen and the game's entry point (GDD §5/§10).
##
## Shows the Grave Bones balance and the skill tree; buying a node spends currency (via
## SkillTree) and autosaves. "Begin Run" routes into the run scene. Built with Godot
## containers (auto-layout) rather than absolute positions, so it survives resizes.
##
## Note: this feature is Hub + routing + purchasing only. Applying the tree's effects to a
## run (buffs, minion-unlock gating) is wired by later M1 features.

const RUN_SCENE := "res://scenes/main/main.tscn"

## Display grouping of nodes into visual routes (columns). Display concern, so it lives here
## rather than in SkillTree's data.
const ROUTES := [
	{"title": "Golem", "nodes": ["unlock_golem", "golem_might"]},
	{"title": "Wraith", "nodes": ["unlock_wraith", "wraith_might"]},
	{"title": "Phylactery", "nodes": ["phylactery_1", "phylactery_2"]},
	{"title": "Hoard", "nodes": ["hoard_1", "hoard_2"]},
	{"title": "Malice", "nodes": ["malice_1", "malice_2"]},
]

const COL_OWNED := Color(0.50, 0.90, 0.55)   # green — owned
const COL_AVAIL := Color(0.96, 0.93, 0.80)   # bone — affordable now
const COL_LOCKED := Color(0.48, 0.46, 0.52)  # grey — prereq missing
const COL_POOR := Color(0.90, 0.70, 0.35)    # amber — available but can't afford

var _balance_label: Label
var _tree_row: HBoxContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	_refresh()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color("120d16")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 10)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "THE CRYPT"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Reclaim your power. Spend Grave Bones on the sigil, then rise."
	subtitle.add_theme_font_size_override("font_size", 9)
	vbox.add_child(subtitle)

	_balance_label = Label.new()
	_balance_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_balance_label)

	_tree_row = HBoxContainer.new()
	_tree_row.add_theme_constant_override("separation", 6)
	_tree_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_tree_row)

	var begin := Button.new()
	begin.text = "Begin Run  >"
	begin.focus_mode = Control.FOCUS_NONE
	begin.custom_minimum_size = Vector2(0, 28)
	begin.pressed.connect(_on_begin_run)
	vbox.add_child(begin)


## Rebuilds the balance readout and the tree columns to reflect current MetaState.
func _refresh() -> void:
	_balance_label.text = "Grave Bones: %d" % MetaState.grave_bones
	for child in _tree_row.get_children():
		_tree_row.remove_child(child)   # detach now so only the new columns remain this frame
		child.queue_free()
	for route in ROUTES:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_tree_row.add_child(col)
		var header := Label.new()
		header.text = route["title"]
		header.add_theme_font_size_override("font_size", 10)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(header)
		for id in route["nodes"]:
			col.add_child(_make_node_button(id))


func _make_node_button(id: String) -> Button:
	var node := SkillTree.get_node_def(id)
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 44)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size", 8)
	b.tooltip_text = node.get("desc", "")
	var cost := int(node.get("cost", 0))
	var node_name: String = node.get("name", id)

	if MetaState.is_unlocked(id):
		b.text = "%s\n(owned)" % node_name
		b.disabled = true
		b.modulate = COL_OWNED
	elif SkillTree.can_purchase(id):
		b.text = "%s\n%d" % [node_name, cost]
		b.modulate = COL_AVAIL
		b.pressed.connect(_on_buy.bind(id))
	elif not SkillTree.prereqs_met(id):
		b.text = "%s\n(locked)" % node_name
		b.disabled = true
		b.modulate = COL_LOCKED
	else:   # prereqs met but can't afford
		b.text = "%s\n%d" % [node_name, cost]
		b.disabled = true
		b.modulate = COL_POOR
	return b


func _on_buy(id: String) -> void:
	if SkillTree.purchase(id):
		MetaState.save_game()   # autosave on tree purchase (M1 spec §4)
		_refresh()


func _on_begin_run() -> void:
	get_tree().change_scene_to_file(RUN_SCENE)
