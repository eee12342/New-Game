extends CharacterBody2D


@export var speed := 600
var pos: Vector2
var rot: float
var dir: float


func _ready() -> void:
	global_position = pos
	global_rotation = rot


func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	

func begone() -> void:
	pass
