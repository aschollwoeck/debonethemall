extends Node
## Autoload singleton (GameState).
##
## Holds run-scoped state for the M0 prototype: the in-run currency (Bone Dust) and simple
## signals other systems listen to. Kept deliberately thin — meta progression (skill tree,
## act-gated currencies) is out of scope for M0 (see docs/M0-prototype.md).

signal bone_dust_changed(amount: int)

## In-run currency spent to place and upgrade minions. Resets each run.
var bone_dust: int = 0:
	set(value):
		bone_dust = max(0, value)
		bone_dust_changed.emit(bone_dust)

## Starting Bone Dust for an M0 run. Tune during playtest.
const STARTING_BONE_DUST := 150


func reset_run() -> void:
	bone_dust = STARTING_BONE_DUST


func can_afford(cost: int) -> bool:
	return bone_dust >= cost


## Spend currency if affordable. Returns true on success.
func try_spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	bone_dust -= cost
	return true


func add(amount: int) -> void:
	bone_dust += amount
