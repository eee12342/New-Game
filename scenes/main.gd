extends Node2D


const enemy1_scene := preload("res://scenes/enemy/enemy1/enemy1.tscn")
@onready var enemies_container: Node2D = $Enemies
@onready var enemies_spawn_timer: Timer = $Enemies/SpawnTimer
@onready var enemies_spawn_points: Node2D = $Enemies/EnemySpawnPoints

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	spawner()
	

func _process(_delta: float) -> void:
	pass
	

func spawner():
	var delay = rng.randf_range(1, 5)
	enemies_spawn_timer.wait_time = delay
	enemies_spawn_timer.start()
	
	
func spawn_enemy():
	var spawn_points = enemies_spawn_points.get_children()
	var spawn_index = rng.randi_range(0, len(spawn_points) - 1)
	var spawn_node = spawn_points[spawn_index]
	var start = spawn_node.get_child(0)
	var end = spawn_node.get_child(1)
	
	var enemy = enemy1_scene.instantiate()
	enemy.global_position = start.global_position
	enemy.set_collision()
	add_child(enemy)
	
	tween_spawn(enemy, end)
	

func tween_spawn(entity: CharacterBody2D, final_pos: Marker2D):
	var spawn_tween: Tween = create_tween()
	spawn_tween.tween_property(entity, "global_position", final_pos.global_position, 1)
	spawner()
