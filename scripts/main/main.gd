extends Node2D
## Run orchestrator. Builds the world (fixed path, phylactery, build slots), spawns the HUD
## and wave manager, handles minion placement/upgrades via clicks, and resolves win/lose.
## Entered from the Hub's level bar (the chosen Level arrives via RunContext); returns via
## "Return to Crypt". The level's intro/outro dialogue (M3) plays on entry and on a clear.

const HUB_SCENE := "res://scenes/hub/hub.tscn"
const DIALOGUE_CARD := preload("res://scripts/ui/dialogue_card.gd")
const ACT_CLEAR_BONUS := 200   # flat Grave Bones for the first Act I clear (on top of the harvest)

## Minion id → scene script + short display name. Which are *available* in a run is decided by
## the meta skill tree (RunModifiers.unlocked_minions); cost is read from the instance (_ready).
const MINION_REGISTRY := {
	"archer": {"script": preload("res://scripts/minions/bone_archer.gd"), "name": "Archer"},
	"golem": {"script": preload("res://scripts/minions/bone_mill_golem.gd"), "name": "Golem"},
	"wraith": {"script": preload("res://scripts/minions/bound_wraith.gd"), "name": "Wraith"},
}

const SLOT_RADIUS := 8.0
const SLOT_CLICK_RADIUS := 12.0

## The level being played (chosen in the Hub via RunContext; defaults to Act I · Level 1 if the
## run scene is launched directly). Its path/slots/waves drive the run (M3 level framework).
var _level: Level
var _path: PackedVector2Array           ## enemy path (from the level)
var _slots: Array = []                  ## build slots beside the path (from the level)
var _slot_minions: Array = []           # parallel to _slots; Minion or null

var _phylactery: Phylactery
var _waves: WaveManager
var _hud: HUD
var _selected_kind: String = ""
var _game_over: bool = false
var _upgrading_idx: int = -1   # slot whose upgrade popup is open, or -1

## Effects from the meta skill tree, applied at run start (GDD §7/§10).
var _mods: RunModifiers
var _damage_mult: float = 1.0
var _minion_cost: Dictionary = {}   # id → cost, for available minions this run


func _ready() -> void:
	# Resolve the level to play (Hub sets RunContext; default to Act I · Level 1 when launched direct).
	_level = RunContext.current_level if RunContext.current_level != null else Levels.act1[0]
	_path = _level.path
	_slots = _level.slots
	_slot_minions.resize(_slots.size())
	_mods = SkillTree.build_run_modifiers()
	_damage_mult = _mods.minion_damage_mult

	# Atmospheric backdrop + stone road (draws behind gameplay).
	var backdrop := Backdrop.new()
	add_child(backdrop)
	backdrop.setup(_path)

	# Apply meta buffs: starting Bone Dust bonus on top of the base.
	GameState.reset_run()
	GameState.add(_mods.starting_dust_bonus)

	_phylactery = Phylactery.new()
	_phylactery.max_life += _mods.phylactery_bonus   # before add_child, so _ready sets life correctly
	_phylactery.global_position = _path[_path.size() - 1]
	_phylactery.life_changed.connect(_on_life_changed)
	_phylactery.destroyed.connect(_on_phylactery_destroyed)
	add_child(_phylactery)

	# Lighting pass (additive glows) + heavy vignette. M2 slice 2.
	var lighting := Lighting.new()
	add_child(lighting)
	lighting.setup(_phylactery.global_position, backdrop)
	add_child(Vignette.new())

	_waves = WaveManager.new()
	add_child(_waves)
	_waves.setup(_path, self, _phylactery, _level.waves)
	_waves.wave_started.connect(_on_wave_started)
	_waves.wave_cleared.connect(_on_wave_cleared)
	_waves.all_waves_cleared.connect(_on_all_cleared)
	_waves.harvest_changed.connect(_on_harvest_changed)

	_hud = HUD.new()
	add_child(_hud)
	_hud.minion_selected.connect(_on_minion_selected)
	_hud.start_wave_pressed.connect(_on_start_wave)
	_hud.return_to_hub_pressed.connect(_on_return_to_hub)
	_hud.upgrade_chosen.connect(_on_upgrade_chosen)

	_populate_available_minions()

	GameState.bone_dust_changed.connect(_on_dust_changed)
	_on_dust_changed(GameState.bone_dust)
	_on_life_changed(_phylactery.life, _phylactery.max_life)
	_on_harvest_changed(0)
	_update_wave_hud()
	queue_redraw()

	# The level's opening dialogue (the Master's orders / your inner voice) — M3 slice 2.
	if not _level.intro.is_empty():
		_play_dialogue(_level.intro)


## Offers only the minions the meta tree has unlocked (GDD §7). Reads each minion's cost from
## a probe instance (cost is set in _ready), keeping cost authoritative — no duplicated numbers.
func _populate_available_minions() -> void:
	var offered := []
	for id in _mods.unlocked_minions:
		if not MINION_REGISTRY.has(id):
			continue
		var probe: Minion = MINION_REGISTRY[id]["script"].new()
		add_child(probe)          # _ready() sets the real cost
		var cost := probe.cost
		probe.queue_free()
		_minion_cost[id] = cost
		offered.append({"id": id, "name": MINION_REGISTRY[id]["name"], "cost": cost})
	_hud.set_minions(offered)


# ---------------------------------------------------------------- input / placement

func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_click(get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_selected_kind = ""
		_hud.clear_selection()
		_close_upgrade()
		queue_redraw()


func _try_click(world_pos: Vector2) -> void:
	var idx := _nearest_slot(world_pos)
	if idx < 0:
		_close_upgrade()   # clicked empty ground
		return
	if _slot_minions[idx] == null:
		_close_upgrade()
		_try_place(idx)
	else:
		_open_upgrade(idx)


func _nearest_slot(world_pos: Vector2) -> int:
	for i in _slots.size():
		if world_pos.distance_to(_slots[i]) <= SLOT_CLICK_RADIUS:
			return i
	return -1


func _try_place(idx: int) -> void:
	# Gating: only place a minion this run has actually unlocked (offered by the HUD).
	if not _minion_cost.has(_selected_kind):
		return
	var minion: Minion = MINION_REGISTRY[_selected_kind]["script"].new()
	# Subclasses set their stats (cost, damage, …) in _ready(), which fires synchronously on
	# add_child — so cost/damage must be read and the buff applied AFTER mounting, not before.
	add_child(minion)
	if not GameState.try_spend(minion.cost):
		minion.queue_free()   # can't afford — un-place
		return
	minion.damage *= _damage_mult   # meta damage buff, applied after _ready set the base
	minion.global_position = _slots[idx]
	_slot_minions[idx] = minion
	queue_redraw()


## Opens the branch-upgrade popup for a placed minion (or hides it if the minion is maxed).
func _open_upgrade(idx: int) -> void:
	var minion: Minion = _slot_minions[idx]
	if minion == null:
		return
	var options := minion.upgrade_options()
	if options.is_empty():
		_close_upgrade()   # maxed — nothing to offer
		return
	_upgrading_idx = idx
	_hud.show_upgrades(minion.display_name, options)


func _close_upgrade() -> void:
	_upgrading_idx = -1
	_hud.hide_upgrades()


func _on_upgrade_chosen(id: String) -> void:
	if _upgrading_idx < 0:
		return
	var minion: Minion = _slot_minions[_upgrading_idx]
	if minion == null:
		_close_upgrade()
		return
	var cost := minion.cost_of(id)
	if not GameState.can_afford(cost):
		return   # can't afford — leave the popup open
	if not minion.apply_upgrade_choice(id):
		return   # invalid choice — don't charge
	GameState.try_spend(cost)
	queue_redraw()
	# reopen for the next tier, or close if now maxed
	_open_upgrade(_upgrading_idx)


# ---------------------------------------------------------------- signal handlers

func _on_minion_selected(kind: String) -> void:
	_selected_kind = kind
	queue_redraw()


func _on_start_wave() -> void:
	if not _game_over:
		_waves.start_next_wave()
		_update_wave_hud()


func _on_return_to_hub() -> void:
	get_tree().change_scene_to_file(HUB_SCENE)


func _on_dust_changed(amount: int) -> void:
	_hud.set_dust(amount)
	queue_redraw()   # slot affordability tint


func _on_life_changed(current: int, max_life: int) -> void:
	_hud.set_life(current, max_life)


func _on_harvest_changed(total: int) -> void:
	_hud.set_harvest(total)


func _on_wave_started(_index: int, _total: int) -> void:
	_update_wave_hud()


func _on_wave_cleared(_index: int) -> void:
	_update_wave_hud()


func _on_all_cleared() -> void:
	_finish_run(true)


func _on_phylactery_destroyed() -> void:
	if not _game_over:
		get_tree().call_group("enemies", "queue_free")
	_finish_run(false)


## Ends the run once: banks the harvested Grave Bones (×multiplier on a clear), saves, and
## shows the end screen. Harvest is kept whether you win or lose (GDD §5).
func _finish_run(cleared: bool) -> void:
	if _game_over:
		return
	_game_over = true
	_waves.stop()   # no more spawns behind the end panel
	var act_complete := cleared and _level.is_boss
	var first_act_clear := act_complete and not MetaState.is_level_cleared(_level.id)
	if cleared:
		MetaState.mark_level_cleared(_level.id)   # unlocks the next Act I level (M3)
	var banked := MetaState.bank_harvest(_waves.total_harvest(), cleared)
	if first_act_clear:
		MetaState.add_grave_bones(ACT_CLEAR_BONUS)   # one-time act-finale reward
		banked += ACT_CLEAR_BONUS
	MetaState.save_game()
	# On a clear, the level's closing dialogue plays before the end screen (M3 slice 2).
	if cleared and not _level.outro.is_empty():
		_play_dialogue(_level.outro, _show_end_panel.bind(cleared, banked, act_complete))
	else:
		_show_end_panel(cleared, banked, act_complete)


func _show_end_panel(cleared: bool, banked: int, act_complete: bool = false) -> void:
	_hud.show_end(cleared, banked, act_complete)


## Plays a dialogue-card sequence over the run; `on_finished` (optional) fires after the last beat.
func _play_dialogue(beats: Array, on_finished := Callable()) -> void:
	var card := DIALOGUE_CARD.new()
	add_child(card)
	if on_finished.is_valid():
		card.finished.connect(on_finished)
	card.play(beats)


func _update_wave_hud() -> void:
	_hud.set_wave(_waves.current_wave_number(), _waves.total_waves(), _waves.is_active())


# ---------------------------------------------------------------- drawing (path + slots)

func _draw() -> void:
	# The stone road is now drawn by the Backdrop (behind gameplay). Here we draw only the
	# build-slot markers (the gameplay overlay), which sit above the road but below minions.
	var can_afford_selected := _selected_affordable()
	for i in _slots.size():
		var p: Vector2 = _slots[i]
		if _slot_minions[i] != null:
			continue   # occupied: the minion draws itself
		var fill := Color(1, 1, 1, 0.05)
		var edge := Color(1, 1, 1, 0.22)
		if _selected_kind != "":
			edge = Color(0.5, 0.95, 0.6, 0.7) if can_afford_selected else Color(0.9, 0.4, 0.4, 0.6)
		draw_circle(p, SLOT_RADIUS, fill)
		draw_arc(p, SLOT_RADIUS, 0, TAU, 24, edge, 1.0)


func _selected_affordable() -> bool:
	if not _minion_cost.has(_selected_kind):
		return false
	return GameState.can_afford(_minion_cost[_selected_kind])

