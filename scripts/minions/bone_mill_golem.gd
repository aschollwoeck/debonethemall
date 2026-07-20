extends Minion
## Bone-Mill Golem — Blunt, AoE, slow and short-ranged, pricey.
## Shatters bone (skeleton hordes); mediocre vs. fast soft targets that slip past its grind.

const STONE := Color("8a8f7a")   # projectile/dust tint

var _pulse: float = 0.0   # >0 while the grind visual plays


func _ready() -> void:
	display_name = "Bone-Mill Golem"
	damage = 14.0
	damage_type = CombatTypes.Damage.BLUNT
	attack_rate = 0.7
	attack_range = 52.0
	cost = 80
	projectile_color = STONE


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _pulse > 0.0:
		_pulse = max(0.0, _pulse - delta * 3.0)
		queue_redraw()


## AoE: grind every enemy currently in range (ignores the target list — hits all).
func _fire(_target_list: Array) -> void:
	var hit_any := false
	for e in get_tree().get_nodes_in_group("enemies"):
		var enemy := e as Enemy
		if enemy == null:
			continue
		if global_position.distance_to(enemy.global_position) <= attack_range:
			enemy.take_damage(damage, damage_type)
			hit_any = true
	if hit_any:
		_pulse = 1.0
		queue_redraw()


## Wider Grind — bigger AoE radius · Bone Crusher — heavier damage & cadence.
func _branches() -> Dictionary:
	return {
		"a": {"name": "Wider Grind", "cost1": 90, "cost2": 140},
		"b": {"name": "Bone Crusher", "cost1": 90, "cost2": 140},
	}


func _apply_branch(id: String, t: int) -> void:
	if id == "a":            # Wider Grind: radius (and a little damage at II)
		attack_range *= 1.3
		if t == 2:
			damage *= 1.2
	else:                    # Bone Crusher: damage (and faster grind at II)
		damage *= 1.8 if t == 1 else 1.6
		if t == 2:
			attack_rate *= 1.25


func _draw() -> void:
	# grind shockwave first (under body), then range ring + body via base
	if _pulse > 0.0:
		draw_arc(Vector2.ZERO, attack_range * (1.0 - _pulse), 0, TAU, 40,
			Color(0.9, 0.85, 0.7, 0.35 * _pulse), 2.0)
	super._draw()


## Fine pixel art (art-direction §6): a hunched stone grinder, bone-toothed maw, necrotic cracks.
func _author_body() -> Image:
	var out := Color("100e15")
	var lo := Color("26242c")
	var mid := Color("3c3a45")
	var hi := Color("55535f")
	var bone := Color("d8cdae")
	var crack := Color("63e39a")
	var img := PixelArt.canvas(44, 38)
	# arms + fists
	PixelArt.rect(img, 5, 16, 6, 12, lo); PixelArt.rect(img, 5, 25, 6, 4, out)
	PixelArt.rect(img, 33, 16, 6, 12, mid); PixelArt.rect(img, 33, 25, 6, 4, out)
	PixelArt.hline(img, 5, 16, 6, hi); PixelArt.hline(img, 33, 16, 6, hi)
	# stubby feet
	PixelArt.rect(img, 14, 33, 6, 4, lo); PixelArt.rect(img, 24, 33, 6, 4, lo)
	PixelArt.hline(img, 14, 36, 16, out)
	# hunched stone torso
	PixelArt.rect(img, 11, 6, 22, 27, mid)
	PixelArt.rect(img, 11, 6, 5, 27, lo)          # shadowed left
	PixelArt.hline(img, 11, 6, 22, hi)            # lit top edge
	PixelArt.vline(img, 11, 6, 27, out)           # outline: left / right / bottom
	PixelArt.vline(img, 32, 6, 27, out)
	PixelArt.hline(img, 11, 32, 22, out)
	# grinding maw with bone teeth
	PixelArt.rect(img, 16, 20, 13, 7, Color("161219"))
	for tx in [17, 20, 23, 26]:
		PixelArt.vline(img, tx, 20, 3, bone)      # upper teeth
		PixelArt.vline(img, tx + 1, 24, 3, bone)  # lower teeth
	# glowing necrotic eyes + cracks
	PixelArt.rect(img, 15, 12, 2, 2, crack); PixelArt.rect(img, 27, 12, 2, 2, crack)
	PixelArt.line(img, 16, 9, 18, 15, crack)
	PixelArt.line(img, 28, 8, 26, 14, crack)
	PixelArt.line(img, 22, 15, 21, 19, crack)
	# embedded bone shards
	PixelArt.rect(img, 13, 17, 3, 1, bone); PixelArt.rect(img, 29, 15, 3, 1, bone)
	return img
