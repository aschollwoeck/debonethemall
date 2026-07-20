extends Node2D
class_name Projectile
## A homing bolt fired by a single-target minion (e.g. Bone Archer). Tracks its target enemy
## and applies typed damage on contact. If the target dies first, the bolt fizzles.

var _target: Enemy
var _damage: float
var _damage_type: CombatTypes.Damage
var _speed: float = 220.0
var _color: Color = Color("f2e9c8")
var _life: float = 2.0   # seconds before self-destruct if it never connects


func setup(target: Enemy, damage: float, damage_type: CombatTypes.Damage, color: Color) -> void:
	_target = target
	_damage = damage
	_damage_type = damage_type
	_color = color


func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0 or not is_instance_valid(_target):
		queue_free()
		return
	var to_target := _target.global_position - global_position
	var dist := to_target.length()
	var step := _speed * delta
	if dist <= step + 4.0:
		_target.take_damage(_damage, _damage_type)
		queue_free()
		return
	global_position += to_target / dist * step
	rotation = to_target.angle()
	queue_redraw()


func _draw() -> void:
	draw_line(Vector2(-3, 0), Vector2(3, 0), _color, 1.5)
	draw_circle(Vector2(3, 0), 1.2, _color)
