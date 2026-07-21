extends Node2D
class_name Enemy
## Base enemy: moves along the fixed path, carries HP + an armor type (for the counter
## matrix), advances through debone stages at HP thresholds (GDD §6), and either dies
## (granting Bone Dust) or reaches the phylactery (dealing damage to it).
##
## Visuals (art-direction restyle): the enemy is fine pixel art — the only pixelated layer on the
## smooth world. Subclasses author each debone stage via `_author_stage()`; the base blits it
## NEAREST-filtered over a soft (smooth) cast shadow, with a white-flash overlay when hit.

signal died(reward: int, bones: int)
signal reached_end(damage: int)

@export var max_hp: float = 30.0
@export var armor_type: CombatTypes.Armor = CombatTypes.Armor.BONE
@export var move_speed: float = 40.0            ## pixels/sec along the path
@export var reward: int = 8                     ## Bone Dust (in-run) granted on death
@export var bones_harvest: int = 1              ## Grave Bones (meta) harvested on death
@export var leak_damage: int = 1                ## phylactery life lost if it reaches the end

## Debone stage thresholds as fractions of max HP. Two thresholds → three stages.
## e.g. [0.66, 0.33]: stage 0 above 66%, stage 1 between, stage 2 below 33%.
@export var stage_thresholds: Array[float] = [0.66, 0.33]
## Optional per-stage speed multiplier (mechanical debone). Defaults to no change.
@export var stage_speed_mult: Array[float] = [1.0, 1.0, 1.0]

## Pixel-art body (see class docstring). Each debone stage's texture is authored once and cached;
## `BODY_SCALE` is logical px per source texel (matches the minions' fine grid).
const BODY_SCALE := 0.5

var hp: float
var stage: int = 0
## The phylactery this enemy marches on (set by the WaveManager on spawn). Melee walkers ignore it
## and just leak at the path's end; ranged casters (Skeleton Mage, boss) attack it directly (M3).
var target_phylactery: Phylactery = null
var _path: PackedVector2Array
var _target_index: int = 1
var _hit_flash: float = 0.0
var _dead: bool = false
var _stage_cache: Dictionary = {}   # stage:int → {tex, mask} (or null once authored as empty)


func _enter_tree() -> void:
	# Units are the pixel layer on the smooth world: sample the body texture NEAREST. Only the
	# textured blit is affected — the soft cast shadow is a geometry primitive and stays smooth.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")


## Called by the wave manager right after instancing. Places the enemy at the path start.
func setup(path_points: PackedVector2Array) -> void:
	_path = path_points
	if _path.size() > 0:
		global_position = _path[0]
	_target_index = 1


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_advance_along_path(delta)
	if _hit_flash > 0.0:
		_hit_flash = max(0.0, _hit_flash - delta * 6.0)
		queue_redraw()


func _advance_along_path(delta: float) -> void:
	if _path.is_empty() or _target_index >= _path.size():
		_leak()
		return
	var target: Vector2 = _path[_target_index]
	var speed := move_speed * _stage_speed()
	var step := speed * delta
	var to_target := target - global_position
	var dist := to_target.length()
	if dist <= step:
		global_position = target
		_target_index += 1
		if _target_index >= _path.size():
			_leak()
	else:
		global_position += to_target / dist * step


func _stage_speed() -> float:
	if stage < stage_speed_mult.size():
		return stage_speed_mult[stage]
	return 1.0


## Progress toward the phylactery (higher = further along). Used by minion targeting so
## towers can prefer the enemy closest to leaking.
func get_progress() -> float:
	if _path.size() < 2:
		return 0.0
	var seg_start := _path[max(0, _target_index - 1)]
	var seg_end := _path[min(_target_index, _path.size() - 1)]
	var seg_len := seg_start.distance_to(seg_end)
	var done := 0.0 if seg_len <= 0.0 else seg_start.distance_to(global_position) / seg_len
	return float(_target_index) + clampf(done, 0.0, 1.0)


func take_damage(base_damage: float, damage_type: CombatTypes.Damage) -> void:
	if _dead:
		return
	var dealt := CombatTypes.resolve_damage(base_damage, damage_type, armor_type)
	hp -= dealt
	_hit_flash = 1.0
	_update_stage()
	queue_redraw()
	if hp <= 0.0:
		_die()


func _update_stage() -> void:
	var frac := hp / max_hp
	var new_stage := 0
	for t in stage_thresholds:
		if frac < t:
			new_stage += 1
	if new_stage != stage:
		stage = new_stage
		_on_stage_changed()


## Hook for subclasses/behaviour when a debone threshold is crossed. Default: none.
func _on_stage_changed() -> void:
	pass


## Soft cast shadow under the enemy (shared grounding). Stays smooth (geometry primitive).
func _shadow(alpha: float = 0.35) -> void:
	var pts := PackedVector2Array()
	for i in 12:
		var a := i * TAU / 12.0
		pts.append(Vector2(cos(a) * 6.0, 8.0 + sin(a) * 2.4))
	draw_colored_polygon(pts, Color(0, 0, 0, alpha))


func _draw() -> void:
	_shadow(_shadow_alpha())
	_blit_stage()


## Blits the current debone stage's pixel art (authored once, cached), NEAREST + upscaled, with a
## white-flash overlay while `_hit_flash` decays.
func _blit_stage() -> void:
	if not _stage_cache.has(stage):
		var img := _author_stage(stage)
		if img == null:
			_stage_cache[stage] = null
		else:
			_stage_cache[stage] = {
				"tex": ImageTexture.create_from_image(img),
				"mask": ImageTexture.create_from_image(PixelArt.white_mask(img)),
			}
	var entry: Variant = _stage_cache[stage]
	if entry == null:
		return
	var tex: Texture2D = entry["tex"]
	var w := tex.get_width() * BODY_SCALE
	var h := tex.get_height() * BODY_SCALE
	var rect := Rect2(-w / 2.0, _feet_y() - h, w, h)
	draw_texture_rect(tex, rect, false)
	if _hit_flash > 0.0:
		draw_texture_rect(entry["mask"], rect, false, Color(1, 1, 1, _hit_flash * 0.7))


## Shadow opacity — floating enemies (wraiths) barely touch the ground. Override in subclasses.
func _shadow_alpha() -> float:
	return 0.35


## The local-space y where the sprite's bottom sits. Override for floaters (hover above ground).
func _feet_y() -> float:
	return 8.0


## Override: author the enemy's fine pixel art for debone `stage` (feet at bottom-centre). Each
## stage is authored once and cached. Returning null draws nothing for that stage.
func _author_stage(_stage: int) -> Image:
	return null


func _die() -> void:
	if _dead:
		return
	_dead = true
	died.emit(reward, bones_harvest)
	queue_free()


func _leak() -> void:
	if _dead:
		return
	_dead = true
	reached_end.emit(leak_damage)
	queue_free()
