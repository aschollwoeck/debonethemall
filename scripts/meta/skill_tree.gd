extends Node
## Autoload singleton (SkillTree).
##
## The data-driven meta skill tree (GDD §7/§10): node definitions plus the logic to purchase
## nodes (spending Grave Bones via MetaState) and to aggregate unlocked nodes into a
## RunModifiers the run applies at start. No UI here — the Hub (M1-F3) renders this data.
##
## Each node's `effect` holds exactly one key:
##   "unlock": <minion_id>     — makes a minion placeable
##   "phylactery_life": <int>  — +phylactery max life
##   "starting_dust": <int>    — +starting Bone Dust
##   "minion_damage": <float>  — additive to the global damage multiplier (0.10 = +10%)

## Minions available without any unlock (the starter — GDD §7: "start with ~1").
const STARTER_MINIONS: Array[String] = ["archer"]

## Valid effect keys (guards data integrity; enforced by tests).
const EFFECT_KEYS := ["unlock", "phylactery_life", "starting_dust", "minion_damage"]

## Node definitions keyed by id. Costs escalate and prereqs form routes, so the full roster is
## unaffordable early → the player specializes (GDD §7). Tuned in the M1 balance pass.
const NODES := {
	# --- minion unlock routes ---
	"unlock_golem": {
		"name": "Raise the Bone-Mill",
		"desc": "Unlock the Bone-Mill Golem (Blunt AoE — shatters bone).",
		"cost": 60, "prereqs": [], "effect": {"unlock": "golem"},
	},
	"golem_might": {
		"name": "Grinding Fury",
		"desc": "+10% minion damage.",
		"cost": 90, "prereqs": ["unlock_golem"], "effect": {"minion_damage": 0.10},
	},
	"unlock_wraith": {
		"name": "Bind a Wraith",
		"desc": "Unlock the Bound Wraith (Necrotic — the answer to ethereal foes).",
		"cost": 120, "prereqs": [], "effect": {"unlock": "wraith"},
	},
	"wraith_might": {
		"name": "Deathly Focus",
		"desc": "+10% minion damage.",
		"cost": 140, "prereqs": ["unlock_wraith"], "effect": {"minion_damage": 0.10},
	},
	# --- phylactery route ---
	"phylactery_1": {
		"name": "Warded Phylactery I",
		"desc": "+5 phylactery max life.",
		"cost": 50, "prereqs": [], "effect": {"phylactery_life": 5},
	},
	"phylactery_2": {
		"name": "Warded Phylactery II",
		"desc": "+5 phylactery max life.",
		"cost": 100, "prereqs": ["phylactery_1"], "effect": {"phylactery_life": 5},
	},
	# --- economy route ---
	"hoard_1": {
		"name": "Grave Hoard I",
		"desc": "+50 starting Bone Dust.",
		"cost": 40, "prereqs": [], "effect": {"starting_dust": 50},
	},
	"hoard_2": {
		"name": "Grave Hoard II",
		"desc": "+50 starting Bone Dust.",
		"cost": 80, "prereqs": ["hoard_1"], "effect": {"starting_dust": 50},
	},
	# --- power route ---
	"malice_1": {
		"name": "Malice I",
		"desc": "+10% minion damage.",
		"cost": 70, "prereqs": [], "effect": {"minion_damage": 0.10},
	},
	"malice_2": {
		"name": "Malice II",
		"desc": "+15% minion damage.",
		"cost": 120, "prereqs": ["malice_1"], "effect": {"minion_damage": 0.15},
	},
}


## True if a node with this id exists in the tree.
func has_node_def(id: String) -> bool:
	return NODES.has(id)


## The node definition for `id`, or `{}` if unknown. The result is a read-only reference into
## the const `NODES` — duplicate it before mutating (e.g. in UI code).
func get_node_def(id: String) -> Dictionary:
	return NODES.get(id, {})


## All node ids in the tree.
func all_node_ids() -> Array:
	return NODES.keys()


## True if every prerequisite of `id` is unlocked.
func prereqs_met(id: String) -> bool:
	if not NODES.has(id):
		return false
	for prereq in NODES[id]["prereqs"]:
		if not MetaState.is_unlocked(prereq):
			return false
	return true


## True if the node exists, isn't already owned, its prereqs are met, and it's affordable.
func can_purchase(id: String) -> bool:
	if not NODES.has(id) or MetaState.is_unlocked(id):
		return false
	if not prereqs_met(id):
		return false
	return MetaState.can_afford(NODES[id]["cost"])


## Attempts to buy a node: spends Grave Bones and unlocks it. Returns true on success.
func purchase(id: String) -> bool:
	if not can_purchase(id):
		return false
	if not MetaState.try_spend(NODES[id]["cost"]):
		return false   # defensive: can_purchase already checked affordability
	MetaState.unlock(id)
	return true


## Aggregates all currently-unlocked nodes into the effects a run applies at start.
func build_run_modifiers() -> RunModifiers:
	var mods := RunModifiers.new()
	for m in STARTER_MINIONS:
		mods.unlocked_minions.append(m)
	for id in MetaState.unlocked_ids():
		if not NODES.has(id):
			continue   # skip unknown/legacy ids defensively
		var effect: Dictionary = NODES[id]["effect"]
		if effect.has("unlock"):
			var minion: String = effect["unlock"]
			if minion not in mods.unlocked_minions:
				mods.unlocked_minions.append(minion)
		if effect.has("phylactery_life"):
			mods.phylactery_bonus += int(effect["phylactery_life"])
		if effect.has("starting_dust"):
			mods.starting_dust_bonus += int(effect["starting_dust"])
		if effect.has("minion_damage"):
			mods.minion_damage_mult += float(effect["minion_damage"])
	return mods
