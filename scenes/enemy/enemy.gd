extends CharacterBody2D


@export var speed: float = 300.0
@export var max_health: float = 100.0


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_projectiles"):
		print("I've been hit!")
