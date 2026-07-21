extends RefCounted
class_name Level
## One playable map (M3 level framework, docs/M3-act-one.md). Data-driven: the enemy `path`, the
## build `slots`, and the `waves` schedule that were hardcoded in `main.gd` / `WaveManager` now live
## here, so adding or reordering a map is data, not code.
##
## `waves` uses the same group format the WaveManager consumes: an Array of waves, each an Array of
## groups `{script: Script, count: int, interval: float, delay: float}`.

var id: String                    ## stable id (used for save/progress); e.g. "act1_l1"
var name: String                  ## display name, e.g. "The Crypt Approach"
var path: PackedVector2Array      ## enemy path (spawn → phylactery)
var slots: Array                  ## Array[Vector2] — build slots beside the path
var waves: Array                  ## wave schedule (see class docstring)
var is_boss: bool = false         ## an act-boss setpiece (M3 slice 7)
var intro: Array = []             ## dialogue beats shown on entering the level (M3 slice 2)
var outro: Array = []             ## dialogue beats shown on clearing the level
## A beat is {who: "master"|"you", name: String, line: String}.


func _init(p_id: String, p_name: String, p_path: PackedVector2Array, p_slots: Array,
		p_waves: Array, p_is_boss: bool = false) -> void:
	id = p_id
	name = p_name
	path = p_path
	slots = p_slots
	waves = p_waves
	is_boss = p_is_boss
