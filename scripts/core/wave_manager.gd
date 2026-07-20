extends Node
class_name WaveManager
## Drives the scripted wave sequence: spawns enemies along the path on a schedule, wires each
## enemy's death (→ Bone Dust + Grave Bones harvest) and leak (→ phylactery damage), and
## reports when a wave is cleared and when all waves are done.

signal wave_started(index: int, total: int)
signal wave_cleared(index: int)
signal all_waves_cleared
signal enemy_count_changed(alive: int)
signal harvest_changed(total: int)

const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const DOG := preload("res://scripts/enemies/skeletal_dog.gd")

## Each wave is a list of groups: {script, count, interval, delay}.
## Mixed grunts (want Blunt) and dogs (want Pierce) so neither minion alone suffices.
var _waves := [
	[ {"script": GRUNT, "count": 5, "interval": 0.9, "delay": 0.0} ],
	[ {"script": DOG, "count": 5, "interval": 0.6, "delay": 0.0} ],
	[ {"script": GRUNT, "count": 6, "interval": 0.8, "delay": 0.0},
	  {"script": DOG, "count": 3, "interval": 0.7, "delay": 3.0} ],
	[ {"script": DOG, "count": 7, "interval": 0.45, "delay": 0.0},
	  {"script": GRUNT, "count": 5, "interval": 0.9, "delay": 1.5} ],
	[ {"script": GRUNT, "count": 10, "interval": 0.6, "delay": 0.0},
	  {"script": DOG, "count": 8, "interval": 0.4, "delay": 2.0} ],
]

var _path: PackedVector2Array
var _spawn_parent: Node
var _phylactery: Phylactery

var _current_wave: int = -1
var _active: bool = false
var _schedule: Array = []      # sorted [{time, script}]
var _elapsed: float = 0.0
var _spawned: int = 0
var _alive: int = 0
var _harvest: int = 0          # Grave Bones harvested from kills this run


func setup(path_points: PackedVector2Array, spawn_parent: Node, phylactery: Phylactery) -> void:
	_path = path_points
	_spawn_parent = spawn_parent
	_phylactery = phylactery


## Total Grave Bones harvested from kills so far this run.
func total_harvest() -> int:
	return _harvest


## Halts spawning and wave progression (called when the run ends).
func stop() -> void:
	_active = false


func total_waves() -> int:
	return _waves.size()


func current_wave_number() -> int:
	return _current_wave + 1   # 1-based for display


func is_active() -> bool:
	return _active


func has_more_waves() -> bool:
	return _current_wave + 1 < _waves.size()


func can_start_next() -> bool:
	return not _active and has_more_waves()


## Begins the next wave. Returns false if it can't start right now.
func start_next_wave() -> bool:
	if not can_start_next():
		return false
	_current_wave += 1
	_build_schedule(_waves[_current_wave])
	_elapsed = 0.0
	_spawned = 0
	_active = true
	wave_started.emit(_current_wave, _waves.size())
	return true


func _build_schedule(wave: Array) -> void:
	_schedule.clear()
	for group in wave:
		var t: float = group["delay"]
		for i in group["count"]:
			_schedule.append({"time": t, "script": group["script"]})
			t += group["interval"]
	_schedule.sort_custom(func(a, b): return a["time"] < b["time"])


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	while _spawned < _schedule.size() and _schedule[_spawned]["time"] <= _elapsed:
		_spawn(_schedule[_spawned]["script"])
		_spawned += 1
	if _spawned >= _schedule.size() and _alive <= 0:
		_active = false
		wave_cleared.emit(_current_wave)
		if not has_more_waves():
			all_waves_cleared.emit()


func _spawn(enemy_script: Script) -> void:
	var enemy: Enemy = enemy_script.new()
	_spawn_parent.add_child(enemy)
	enemy.setup(_path)
	enemy.died.connect(_on_enemy_died)
	enemy.reached_end.connect(_on_enemy_leaked)
	_alive += 1
	enemy_count_changed.emit(_alive)


func _on_enemy_died(reward: int, bones: int) -> void:
	GameState.add(reward)          # in-run Bone Dust
	_harvest += bones              # meta Grave Bones harvest (banked at run end)
	harvest_changed.emit(_harvest)
	_dec_alive()


func _on_enemy_leaked(damage: int) -> void:
	if _phylactery != null:
		_phylactery.take_damage(damage)
	_dec_alive()


func _dec_alive() -> void:
	_alive = max(0, _alive - 1)
	enemy_count_changed.emit(_alive)
