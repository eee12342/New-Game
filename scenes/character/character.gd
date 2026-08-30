extends CharacterBody2D


var bullet_path := preload("res://scenes/character/bullet/bullet.tscn")
@onready var bullet_spawn: Marker2D = $BulletSpawn

@export var speed := 300.0


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2(0, 0)
		
	if Input.is_action_just_pressed("fire"):
		fire()

	move_and_slide()
	
# TODO: improve movement (make more floaty, add accel/decell properties


func fire() -> void:
	var bullet = bullet_path.instantiate()
	bullet.global_position = bullet_spawn.global_position
	get_parent().add_child(bullet)
