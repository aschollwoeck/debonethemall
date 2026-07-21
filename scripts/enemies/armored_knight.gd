extends Enemy
## Armored Knight — HEAVY armor, tanky (GDD §6, M3 slice 4). The mechanical debone: its plate
## **shatters off** at the first threshold → it becomes a **fast, exposed skeleton** (armor
## HEAVY → BONE, speed jumps) → then it collapses to a bone pile. HEAVY resists Pierce and Holy,
## so crack it with Blunt/Fire; once stripped it's a quick BONE runner the Golem shreds. Reaching
## the phylactery in plate hurts more (higher leak).

func _ready() -> void:
	max_hp = 92.0
	armor_type = CombatTypes.Armor.HEAVY
	move_speed = 30.0
	reward = 14
	bones_harvest = 3
	leak_damage = 2
	stage_thresholds = [0.6, 0.25]           # armored → stripped (fast) → collapsing
	stage_speed_mult = [0.85, 1.7, 0.7]      # lumbers in plate, sprints once exposed, then falls apart
	super._ready()


## Crossing the first threshold shatters the plate: the exposed skeleton is BONE, not HEAVY —
## Pierce still rattles through bone, but the Golem's Blunt now shatters it (1.5×).
func _on_stage_changed() -> void:
	if stage >= 1:
		armor_type = CombatTypes.Armor.BONE


## Fine pixel art per debone stage: armored knight → stripped fast skeleton → bone pile + helm.
func _author_stage(st: int) -> Image:
	var out := Color("14141c")
	var iron_lo := Color("2b2f3a")
	var iron := Color("4a4f5e")
	var iron_hi := Color("727a8c")
	var bone_lo := Color("8f856a")
	var bone := Color("c8bd9c")
	var bone_hi := Color("efe6cd")
	var eye := Color("c8434a")   # a dull red glimmer behind the visor
	match st:
		0:
			# bulky armoured knight
			var img := PixelArt.canvas(34, 44)
			# greaves + feet
			PixelArt.rect(img, 13, 34, 4, 9, iron); PixelArt.vline(img, 13, 34, 9, iron_lo)
			PixelArt.rect(img, 17, 34, 4, 9, iron); PixelArt.vline(img, 17, 34, 9, iron_lo)
			PixelArt.rect(img, 12, 42, 5, 2, iron_lo); PixelArt.rect(img, 17, 42, 5, 2, iron_lo)
			# tasset (skirt)
			PixelArt.rect(img, 11, 30, 12, 5, iron_lo); PixelArt.hline(img, 11, 30, 12, iron)
			# breastplate
			PixelArt.rect(img, 9, 16, 16, 15, iron)
			PixelArt.rect(img, 9, 16, 4, 15, iron_lo)          # shadowed left
			PixelArt.hline(img, 9, 16, 16, iron_hi)            # lit collar
			PixelArt.vline(img, 16, 18, 12, iron_hi)           # centre ridge
			PixelArt.vline(img, 9, 16, 15, out); PixelArt.vline(img, 24, 16, 15, out)   # side outline
			# pauldrons
			PixelArt.rect(img, 5, 14, 6, 6, iron_hi); PixelArt.rect(img, 23, 14, 6, 6, iron_hi)
			PixelArt.hline(img, 5, 14, 6, iron); PixelArt.hline(img, 23, 14, 6, iron)
			# helmet
			PixelArt.rect(img, 11, 4, 12, 12, iron)
			PixelArt.hline(img, 11, 4, 12, iron_hi)
			PixelArt.vline(img, 11, 4, 12, iron_lo)
			PixelArt.rect(img, 16, 3, 2, 3, iron_hi)           # crest
			PixelArt.rect(img, 12, 10, 10, 2, out)             # visor slit
			PixelArt.px(img, 14, 10, eye); PixelArt.px(img, 19, 10, eye)
			# shield (left arm)
			PixelArt.rect(img, 2, 19, 5, 12, iron_lo); PixelArt.hline(img, 2, 19, 5, iron)
			PixelArt.vline(img, 4, 20, 10, iron_hi)
			return img
		1:
			# plate shattered — a lean, forward-lunging skeleton (fast), a few iron shards flying
			var img := PixelArt.canvas(32, 42)
			PixelArt.px(img, 4, 14, iron); PixelArt.px(img, 27, 12, iron_hi)   # falling shards
			PixelArt.px(img, 6, 22, iron_lo); PixelArt.px(img, 25, 24, iron)
			# lunging legs (mid-stride)
			PixelArt.line(img, 15, 28, 11, 40, bone); PixelArt.line(img, 17, 28, 22, 39, bone)
			PixelArt.rect(img, 10, 39, 3, 2, bone); PixelArt.rect(img, 21, 38, 3, 2, bone)
			# forward-leaning spine + ribs
			PixelArt.line(img, 12, 16, 18, 28, bone_lo); PixelArt.line(img, 13, 16, 19, 28, bone)
			for k in 4:
				PixelArt.line(img, 11 - k, 18 + k * 3, 17 - k, 20 + k * 3, bone_lo)
			# outstretched arms (charging)
			PixelArt.line(img, 13, 18, 6, 15, bone); PixelArt.line(img, 15, 18, 23, 14, bone)
			# skull, tilted forward
			PixelArt.rect(img, 8, 10, 7, 6, bone); PixelArt.hline(img, 8, 10, 7, bone_hi)
			PixelArt.rect(img, 9, 12, 2, 2, out); PixelArt.rect(img, 12, 12, 2, 2, out)
			PixelArt.hline(img, 9, 15, 4, out)                 # jaw
			return img
		_:
			# a heap of bones under a dented helm
			var img := PixelArt.canvas(30, 18)
			PixelArt.line(img, 5, 13, 20, 14, bone_lo)
			PixelArt.line(img, 7, 15, 22, 12, bone_lo)
			PixelArt.line(img, 12, 11, 17, 15, bone_lo)
			PixelArt.rect(img, 17, 9, 8, 5, iron)              # dented helm
			PixelArt.hline(img, 17, 9, 8, iron_hi)
			PixelArt.rect(img, 19, 11, 4, 1, out)              # visor
			PixelArt.px(img, 20, 11, eye)
			PixelArt.rect(img, 9, 11, 4, 3, bone); PixelArt.hline(img, 9, 11, 4, bone_hi)   # a skull
			PixelArt.px(img, 10, 12, out); PixelArt.px(img, 11, 12, out)
			return img
