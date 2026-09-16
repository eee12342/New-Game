extends CharacterBody2D
class_name Bullet


@export var speed := 600
@export var damage: float = 20
var pos: Vector2
var rot: float
var dir: float
@export var max_charge_time: float = 1000


func _ready() -> void:
	Messenger.connect("enemy_is_hit", _on_enemy_hit)
	global_position = pos
	global_rotation = rot


func setup(charge_time: float) -> void:
	if charge_time > max_charge_time:
		charge_time = max_charge_time
	


func _physics_process(delta: float) -> void:
	velocity = move(delta)
	move_and_slide()


func move(_delta: float):
	return Vector2(speed, 0).rotated(dir)


func begone() -> void:
	queue_free()


func _on_enemy_hit(projectile: CharacterBody2D, enemy: CharacterBody2D):
	if projectile == self:
		Messenger.damage_enemy(damage, enemy)
