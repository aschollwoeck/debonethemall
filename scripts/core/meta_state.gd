extends Node
## Autoload singleton (MetaState).
##
## Persistent, cross-run state saved to disk (GDD §5/§10): the harvested **Grave Bones**
## currency and the set of unlocked skill-tree nodes. Loaded on boot; autosaved on run-end
## (`main._finish_run`) and on tree purchases (the Hub).
##
## Distinct from GameState, which holds run-scoped Bone Dust that resets each run.

signal grave_bones_changed(amount: int)

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

## Multiplier applied to a run's harvest when the run is a clear (GDD §5). Tuned later.
const SUCCESS_MULTIPLIER := 1.5

## Persistent meta currency. Never negative (clamped in the setter).
var grave_bones: int = 0:
	set(value):
		grave_bones = max(0, value)
		grave_bones_changed.emit(grave_bones)

## Unlocked skill-tree node ids. Dictionary used as a set: id (String) -> true.
var _unlocked: Dictionary = {}

## Cleared level ids (Act I progression, M3). Dictionary used as a set: level id (String) -> true.
var _cleared_levels: Dictionary = {}


func _ready() -> void:
	load_game()


# ---------------------------------------------------------------- currency

## Adds Grave Bones (ignores non-positive amounts).
func add_grave_bones(amount: int) -> void:
	if amount > 0:
		grave_bones += amount


## True if the current balance can cover `cost`.
func can_afford(cost: int) -> bool:
	return grave_bones >= cost


## Spend Grave Bones if affordable. Returns true on success, leaves balance untouched on failure.
func try_spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	grave_bones -= cost
	return true


## Banks a run's harvest, applying the success multiplier on a clear (GDD §5).
## Returns the amount actually added to the balance.
func bank_harvest(base_amount: int, cleared: bool) -> int:
	var base := maxi(0, base_amount)
	var banked := int(round(base * SUCCESS_MULTIPLIER)) if cleared else base
	add_grave_bones(banked)
	return banked


# ---------------------------------------------------------------- unlocks

## True if the given skill-tree node has been unlocked.
func is_unlocked(node_id: String) -> bool:
	return _unlocked.has(node_id)


## Marks a skill-tree node as unlocked (idempotent).
func unlock(node_id: String) -> void:
	_unlocked[node_id] = true


## All unlocked node ids.
func unlocked_ids() -> Array:
	return _unlocked.keys()


# ---------------------------------------------------------------- level progress (M3)

## True if the level with this id has been cleared at least once.
func is_level_cleared(level_id: String) -> bool:
	return _cleared_levels.has(level_id)


## Records a level as cleared (idempotent). Called on a run clear (main._finish_run).
func mark_level_cleared(level_id: String) -> void:
	_cleared_levels[level_id] = true


## All cleared level ids.
func cleared_level_ids() -> Array:
	return _cleared_levels.keys()


# ---------------------------------------------------------------- persistence

## Serializes persistent state to a plain Dictionary (the save-format contract).
func to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"grave_bones": grave_bones,
		"unlocked": _unlocked.keys(),
		"cleared_levels": _cleared_levels.keys(),
	}


## Restores state from a Dictionary, defensively (a hand-edited or partially-corrupt but
## still-parseable save must not corrupt state or inject junk unlocks).
func from_dict(data: Dictionary) -> void:
	# TODO: when SAVE_VERSION changes, branch on data.get("version", 1) to migrate old saves.
	var bones: Variant = data.get("grave_bones", 0)
	grave_bones = int(bones) if (bones is int or bones is float) else 0
	_unlocked.clear()
	var unlocked: Variant = data.get("unlocked", [])
	if unlocked is Array:
		for node_id in unlocked:
			_unlocked[str(node_id)] = true
	_cleared_levels.clear()
	var cleared: Variant = data.get("cleared_levels", [])
	if cleared is Array:
		for level_id in cleared:
			_cleared_levels[str(level_id)] = true


## Saves to the real save file (`SAVE_PATH`).
func save_game() -> void:
	save_to(SAVE_PATH)


## Loads from the real save file (`SAVE_PATH`).
func load_game() -> void:
	load_from(SAVE_PATH)


## Writes state to an explicit path (path-injectable so tests never touch the real save).
func save_to(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("MetaState: could not open save for writing: %s (%s)"
			% [path, error_string(FileAccess.get_open_error())])
		return
	f.store_string(JSON.stringify(to_dict(), "\t"))
	f.close()


## Loads state from an explicit path. Missing or corrupt files are ignored (fresh state).
func load_from(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("MetaState: could not open save for reading: %s" % path)
		return
	var text := f.get_as_text()
	f.close()
	# Instance API (not JSON.parse_string) so a corrupt file returns an error code instead of
	# printing an engine-level error — corrupt saves are handled quietly, never fatally.
	var json := JSON.new()
	if json.parse(text) == OK and json.data is Dictionary:
		from_dict(json.data)
	else:
		push_warning("MetaState: save file is not valid JSON, ignoring: %s" % path)


## Wipes all persistent progress (new game / tests).
func reset_all() -> void:
	grave_bones = 0
	_unlocked.clear()
	_cleared_levels.clear()
