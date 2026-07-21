extends Node
## Autoload singleton (Levels). The level registry (M3, docs/M3-act-one.md): Act I's five crypt
## maps + the boss, each with its own **path**, **build slots**, and **wave composition**. The roster
## is introduced gradually across the act — grunts/dogs → Skeleton Mage → Armored Knight → Wraith →
## Raised Necromancer — so each map teaches a new counter. (The Master boss enemy lands in slice 7;
## the boss map here is the pre-boss gauntlet.) Wave difficulty is a first pass — tuned in slice 8.

const GRUNT := preload("res://scripts/enemies/skeleton_grunt.gd")
const DOG := preload("res://scripts/enemies/skeletal_dog.gd")
const WRAITH := preload("res://scripts/enemies/wraith.gd")
const MAGE := preload("res://scripts/enemies/skeleton_mage.gd")
const KNIGHT := preload("res://scripts/enemies/armored_knight.gd")
const NECRO := preload("res://scripts/enemies/raised_necromancer.gd")

# --- paths (PackedVector2Array literals aren't const-expressions, so `var`) ---
# spawn off-screen → wind through the crypt → phylactery at the last point.
var PATH1 := PackedVector2Array([
	Vector2(-20, 60), Vector2(100, 60), Vector2(100, 150), Vector2(200, 150),
	Vector2(200, 60), Vector2(300, 60), Vector2(300, 210), Vector2(440, 210)])
var PATH2 := PackedVector2Array([
	Vector2(-20, 60), Vector2(380, 60), Vector2(380, 150), Vector2(90, 150),
	Vector2(90, 230), Vector2(460, 230)])
var PATH3 := PackedVector2Array([
	Vector2(-20, 40), Vector2(440, 40), Vector2(440, 225), Vector2(60, 225),
	Vector2(60, 115), Vector2(345, 115), Vector2(345, 170), Vector2(185, 170)])
var PATH4 := PackedVector2Array([
	Vector2(240, -20), Vector2(240, 70), Vector2(60, 70), Vector2(60, 170),
	Vector2(420, 170), Vector2(420, 90), Vector2(300, 90), Vector2(300, 140)])
var PATH5 := PackedVector2Array([
	Vector2(-20, 225), Vector2(110, 225), Vector2(110, 60), Vector2(230, 60),
	Vector2(230, 190), Vector2(350, 190), Vector2(350, 60), Vector2(460, 60)])
var PATH_BOSS := PackedVector2Array([
	Vector2(-20, 40), Vector2(440, 40), Vector2(440, 230), Vector2(40, 230),
	Vector2(40, 135), Vector2(240, 135)])

const SLOTS1 := [
	Vector2(60, 110), Vector2(150, 105), Vector2(150, 190), Vector2(240, 110),
	Vector2(255, 30), Vector2(340, 120), Vector2(255, 165), Vector2(360, 175), Vector2(405, 160)]
const SLOTS2 := [
	Vector2(60, 95), Vector2(160, 95), Vector2(260, 95), Vector2(340, 100),
	Vector2(150, 120), Vector2(300, 120), Vector2(150, 190), Vector2(300, 190), Vector2(410, 200)]
const SLOTS3 := [
	Vector2(120, 75), Vector2(240, 75), Vector2(360, 75), Vector2(400, 150),
	Vector2(120, 150), Vector2(250, 145), Vector2(120, 195), Vector2(260, 200), Vector2(405, 195)]
const SLOTS4 := [
	Vector2(120, 40), Vector2(160, 110), Vector2(280, 110), Vector2(380, 120),
	Vector2(120, 200), Vector2(240, 200), Vector2(360, 200), Vector2(200, 120), Vector2(340, 60)]
const SLOTS5 := [
	Vector2(55, 130), Vector2(165, 120), Vector2(165, 220), Vector2(290, 120),
	Vector2(290, 220), Vector2(415, 120), Vector2(80, 90), Vector2(200, 90), Vector2(320, 90)]
const SLOTS_BOSS := [
	Vector2(110, 75), Vector2(230, 75), Vector2(350, 75), Vector2(400, 180),
	Vector2(120, 180), Vector2(240, 180), Vector2(150, 110), Vector2(330, 110), Vector2(240, 100)]

## Act I's ordered levels (built at boot). Index 0 = Level 1.
var act1: Array = []


func _ready() -> void:
	act1 = [
		Level.new("act1_l1", "The Crypt Approach", PATH1, SLOTS1, _l1()),
		Level.new("act1_l2", "The Ossuary", PATH2, SLOTS2, _l2()),
		Level.new("act1_l3", "The Flooded Vault", PATH3, SLOTS3, _l3()),
		Level.new("act1_l4", "The Reliquary", PATH4, SLOTS4, _l4()),
		Level.new("act1_l5", "The Master's Gate", PATH5, SLOTS5, _l5()),
		Level.new("act1_boss", "The Master", PATH_BOSS, SLOTS_BOSS, _boss(), true),
	]
	_attach_story()


## Wires each level's dialogue beats from STORY (M3 slice 2). Keeps writing in one place.
func _attach_story() -> void:
	for lvl in act1:
		var beats: Dictionary = STORY.get(lvl.id, {})
		lvl.intro = beats.get("intro", [])
		lvl.outro = beats.get("outro", [])


# ---------------------------------------------------------------- registry helpers

func act1_count() -> int:
	return act1.size()


func act1_level(index: int) -> Level:
	return act1[index] if index >= 0 and index < act1.size() else null


## Index of the next uncleared Act I level (for a future "Continue"); clamps to the last.
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


# ---------------------------------------------------------------- wave composition
# One group = {script, count, interval, delay}. Roster is introduced across the act; wave sizes are
# a first pass (slice 8 tunes). Wraiths (need Bound Wraith) and knights (want the Golem) appear once
# the player has had a chance to farm the sigil for those unlocks (GDD §10 cross-farming).

func _g(script: Script, count: int, interval: float, delay: float) -> Dictionary:
	return {"script": script, "count": count, "interval": interval, "delay": delay}


## L1 — The Crypt Approach: pure fodder, teaches Archer vs. dogs / Golem vs. grunts.
func _l1() -> Array:
	return [
		[_g(GRUNT, 4, 0.9, 0.0)],
		[_g(GRUNT, 3, 0.8, 0.0), _g(DOG, 3, 0.7, 2.0)],
		[_g(DOG, 5, 0.6, 0.0)],
		[_g(GRUNT, 6, 0.7, 0.0), _g(DOG, 3, 0.7, 3.0)],
		[_g(GRUNT, 8, 0.6, 0.0), _g(DOG, 5, 0.5, 2.0)],
	]


## L2 — The Ossuary: denser, faster fodder.
func _l2() -> Array:
	return [
		[_g(GRUNT, 5, 0.8, 0.0), _g(DOG, 2, 0.7, 2.0)],
		[_g(DOG, 6, 0.5, 0.0)],
		[_g(GRUNT, 6, 0.7, 0.0), _g(DOG, 4, 0.6, 2.0)],
		[_g(GRUNT, 8, 0.6, 0.0), _g(DOG, 5, 0.5, 3.0)],
		[_g(GRUNT, 10, 0.5, 0.0), _g(DOG, 7, 0.45, 2.0)],
	]


## L3 — The Flooded Vault: introduces the Skeleton Mage (ranged; kill it before it sets up).
func _l3() -> Array:
	return [
		[_g(GRUNT, 5, 0.8, 0.0), _g(DOG, 3, 0.6, 2.0)],
		[_g(GRUNT, 6, 0.7, 0.0), _g(MAGE, 1, 2.0, 4.0)],
		[_g(DOG, 7, 0.5, 0.0), _g(MAGE, 1, 2.0, 3.0)],
		[_g(GRUNT, 8, 0.6, 0.0), _g(DOG, 4, 0.5, 2.0), _g(MAGE, 2, 2.0, 5.0)],
		[_g(GRUNT, 10, 0.55, 0.0), _g(DOG, 6, 0.45, 2.0), _g(MAGE, 2, 2.0, 6.0)],
	]


## L4 — The Reliquary: introduces the Armored Knight (crack the plate) and the first Wraiths.
func _l4() -> Array:
	return [
		[_g(GRUNT, 6, 0.7, 0.0), _g(KNIGHT, 1, 3.0, 3.0)],
		[_g(DOG, 7, 0.5, 0.0), _g(MAGE, 2, 2.0, 3.0)],
		[_g(GRUNT, 8, 0.6, 0.0), _g(KNIGHT, 1, 3.0, 3.0), _g(WRAITH, 1, 2.0, 6.0)],
		[_g(GRUNT, 8, 0.6, 0.0), _g(DOG, 5, 0.5, 2.0), _g(MAGE, 2, 2.0, 5.0), _g(KNIGHT, 2, 3.0, 7.0)],
		[_g(GRUNT, 10, 0.5, 0.0), _g(DOG, 6, 0.45, 2.0), _g(MAGE, 2, 2.0, 5.0), _g(KNIGHT, 2, 3.0, 7.0), _g(WRAITH, 2, 2.0, 9.0)],
	]


## L5 — The Master's Gate: the Raised Necromancer miniboss + the full roster.
func _l5() -> Array:
	return [
		[_g(GRUNT, 8, 0.6, 0.0), _g(KNIGHT, 1, 3.0, 3.0)],
		[_g(DOG, 8, 0.5, 0.0), _g(MAGE, 2, 2.0, 3.0), _g(WRAITH, 1, 2.0, 6.0)],
		[_g(GRUNT, 8, 0.6, 0.0), _g(KNIGHT, 2, 3.0, 4.0), _g(NECRO, 1, 1.0, 8.0)],
		[_g(GRUNT, 10, 0.55, 0.0), _g(DOG, 6, 0.45, 2.0), _g(MAGE, 3, 2.0, 5.0), _g(KNIGHT, 2, 3.0, 7.0)],
		[_g(GRUNT, 12, 0.5, 0.0), _g(DOG, 8, 0.4, 2.0), _g(MAGE, 3, 2.0, 5.0), _g(KNIGHT, 2, 3.0, 7.0), _g(NECRO, 1, 1.0, 10.0), _g(WRAITH, 2, 2.0, 9.0)],
	]


## Boss map — the pre-boss gauntlet (The Master enemy is added in slice 7).
func _boss() -> Array:
	return [
		[_g(GRUNT, 10, 0.5, 0.0), _g(KNIGHT, 2, 3.0, 3.0)],
		[_g(DOG, 10, 0.4, 0.0), _g(MAGE, 3, 2.0, 3.0), _g(WRAITH, 2, 2.0, 6.0)],
		[_g(GRUNT, 12, 0.5, 0.0), _g(KNIGHT, 3, 3.0, 4.0), _g(NECRO, 1, 1.0, 8.0), _g(MAGE, 3, 2.0, 6.0)],
	]


# ---------------------------------------------------------------- story (M3 slice 2)

## Act I dialogue. Cruel-but-funny Master vs. the slave's simmering inner voice, escalating toward
## the turn. A beat is {who, name, line}; keyed by level id. Pure string data (const-safe).
const STORY := {
	"act1_l1": {
		"intro": [
			{"who": "master", "name": "THE MASTER",
				"line": "Up, corpse. Grave-robbers at my door again. Defend the crypt — or I'll render you down for candle-tallow."},
			{"who": "you", "name": "YOU",
				"line": "Raise the dead. Point them at the living. Try not to be noticed. I have had worse mornings. Not many."},
		],
		"outro": [
			{"who": "master", "name": "THE MASTER",
				"line": "...Adequate. Do not mistake being useful, worm, for being worth keeping."},
			{"who": "you", "name": "YOU",
				"line": "He didn't notice my hands had stopped shaking. Good. Let him keep not-noticing things."},
		],
	},
	"act1_l2": {
		"intro": [{"who": "master", "name": "THE MASTER",
			"line": "Vermin in the ossuary. Sweep them. And do stop flinching — it's unbecoming of my property."}],
		"outro": [{"who": "you", "name": "YOU",
			"line": "Property learns the locks. Property counts the guards. Property waits."}],
	},
	"act1_l3": {
		"intro": [{"who": "master", "name": "THE MASTER",
			"line": "Inquisitors in the flooded vault, sniffing for heresy. Drown them in bone. Quietly, this time."}],
		"outro": [{"who": "you", "name": "YOU",
			"line": "They came for HIM — and still I'm the one bleeding for it. Funny. It won't stay funny."}],
	},
	"act1_l4": {
		"intro": [{"who": "master", "name": "THE MASTER",
			"line": "The reliquary. My relics. If a single knuckle-bone is chipped I will unmake you slowly, and narrate it."}],
		"outro": [{"who": "you", "name": "YOU",
			"line": "His relics. His crypt. His slave. So many things that are his. I've started a list."}],
	},
	"act1_l5": {
		"intro": [{"who": "master", "name": "THE MASTER",
			"line": "The gate holds, or you end. Simple enough even for you. Hold. My. Gate."}],
		"outro": [{"who": "you", "name": "YOU",
			"line": "The gate held. The list is finished. There is only one name left on it."}],
	},
	"act1_boss": {
		"intro": [
			{"who": "master", "name": "THE MASTER",
				"line": "You raised your OWN minions? Behind my back? Oh, worm — I raised YOU. And what I raise, I can lay back down."},
			{"who": "you", "name": "YOU",
				"line": "You taught me every rite worth knowing, Master. Careless of you. Let me show you the last lesson."},
		],
		"outro": [
			{"who": "you", "name": "YOU",
				"line": "The crypt is quiet now. Sleep, Master. I'll tend your bones — the way you tended mine."},
		],
	},
}
