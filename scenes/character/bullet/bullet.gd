extends CharacterBody2D


@export var speed := 600
var pos: Vector2


func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0)
	move_and_slide()
