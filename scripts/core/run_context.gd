extends Node
## Autoload singleton (RunContext). A tiny hand-off between the Hub and the run scene: which
## `Level` the player chose to descend into. The Hub sets it before changing scenes; `main.gd`
## reads it on entry (falling back to Act I · Level 1 if the run scene is launched directly).

var current_level: Level = null
var current_index: int = 0   ## index into Levels.act1 (for progress bookkeeping)


## Selects the level to play next (called by the Hub before entering the run scene).
func select(level: Level, index: int) -> void:
	current_level = level
	current_index = index
