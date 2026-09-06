extends Node


signal enemy_is_hit(projectile: CharacterBody2D, enemy: CharacterBody2D)
signal damage_to_enemy(damage_value: float, enemy: CharacterBody2D)

var Player: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func enemy_hit(projectile: CharacterBody2D, enemy: CharacterBody2D) -> void:
	enemy_is_hit.emit(projectile, enemy)


func damage_enemy(damage_value: float, enemy: CharacterBody2D):
	damage_to_enemy.emit(damage_value, enemy)
