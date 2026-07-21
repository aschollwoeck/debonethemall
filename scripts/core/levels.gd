extends Node
## Autoload singleton (Levels). The level registry (M3, docs/M3-act-one.md): Act I's ordered maps.
## Level 1 is the real, tuned content lifted out of the old hardcoded `main.gd` / `WaveManager`.
##
## Levels 2–5 and the boss are **placeholders** for now — they reuse Level 1's path/slots with
## escalating wave counts so the progression (Continue / replay / act clear) is fully playable
## end-to-end; the real crypt maps land in M3 slice 6 and the boss in slice 7.

const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const DOG := preload("res://scripts/enemies/skeletal_dog.gd")
const WRAITH := preload("res://scripts/enemies/wraith.gd")

# --- Level 1 geometry (the original prototype map) ---
# (PATH1 is a `var`, not `const`: a PackedVector2Array literal isn't a constant expression.)
var PATH1 := PackedVector2Array([
	Vector2(-20, 60), Vector2(100, 60), Vector2(100, 150), Vector2(200, 150),
	Vector2(200, 60), Vector2(300, 60), Vector2(300, 210), Vector2(440, 210),
])
const SLOTS1 := [
	Vector2(60, 110), Vector2(150, 105), Vector2(150, 190), Vector2(240, 110),
	Vector2(255, 30), Vector2(340, 120), Vector2(255, 165), Vector2(360, 175),
	Vector2(405, 160),
]

## Act I's ordered levels (built at boot). Index 0 = Level 1.
var act1: Array = []


func _ready() -> void:
	var base := _base_waves()
	act1 = [
		Level.new("act1_l1", "The Crypt Approach", PATH1, SLOTS1, base),
		Level.new("act1_l2", "The Ossuary", PATH1, SLOTS1, _scaled(base, 1.2)),
		Level.new("act1_l3", "The Flooded Vault", PATH1, SLOTS1, _scaled(base, 1.4)),
		Level.new("act1_l4", "The Reliquary", PATH1, SLOTS1, _scaled(base, 1.6)),
		Level.new("act1_l5", "The Master's Gate", PATH1, SLOTS1, _scaled(base, 1.8)),
		Level.new("act1_boss", "The Master", PATH1, SLOTS1, _scaled(base, 2.0), true),
	]


## The number of Act I levels (maps + boss).
func act1_count() -> int:
	return act1.size()


## Level at `index`, or null if out of range.
func act1_level(index: int) -> Level:
	return act1[index] if index >= 0 and index < act1.size() else null


## Index of the next uncleared Act I level (for the Hub's "Continue"); clamps to the last level
## once everything is cleared.
func act1_next_index() -> int:
	for i in act1.size():
		if not MetaState.is_level_cleared(act1[i].id):
			return i
	return act1.size() - 1


## True if the level at `index` is playable: the first level, or the previous one is cleared.
func is_act1_unlocked(index: int) -> bool:
	if index <= 0:
		return true
	if index >= act1.size():
		return false
	return MetaState.is_level_cleared(act1[index - 1].id)


# --- placeholder wave content (Level 1 is real; the rest scale until slice 6/7) ---

## Level 1's real wave schedule (the original prototype's five waves).
func _base_waves() -> Array:
	return [
		[ {"script": GRUNT, "count": 5, "interval": 0.9, "delay": 0.0} ],
		[ {"script": DOG, "count": 5, "interval": 0.6, "delay": 0.0} ],
		[ {"script": GRUNT, "count": 6, "interval": 0.8, "delay": 0.0},
		  {"script": DOG, "count": 3, "interval": 0.7, "delay": 3.0} ],
		[ {"script": DOG, "count": 7, "interval": 0.45, "delay": 0.0},
		  {"script": GRUNT, "count": 5, "interval": 0.9, "delay": 1.5},
		  {"script": WRAITH, "count": 2, "interval": 1.5, "delay": 5.0} ],
		[ {"script": GRUNT, "count": 10, "interval": 0.6, "delay": 0.0},
		  {"script": DOG, "count": 8, "interval": 0.4, "delay": 2.0},
		  {"script": WRAITH, "count": 4, "interval": 1.2, "delay": 4.0} ],
	]


## A copy of `base` with every group's count scaled by `mult` (placeholder escalation).
func _scaled(base: Array, mult: float) -> Array:
	var out: Array = []
	for wave in base:
		var groups: Array = []
		for g in wave:
			groups.append({
				"script": g["script"],
				"count": int(ceil(g["count"] * mult)),
				"interval": g["interval"],
				"delay": g["delay"],
			})
		out.append(groups)
	return out
