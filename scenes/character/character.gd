extends CharacterBody2D
class_name Player


@onready var sprite: AnimatedSprite2D = $Sprite
var bullet_path := preload("res://scenes/character/bullet/bullet.tscn")
@onready var bullet_spawn: Marker2D = $BulletSpawn

@export var speed := 300.0

var colours: Array = ["colour1", "colour2", "colour3", "colour4"]
var current_colour: String = "colour1"
var in_colour_change_mode: bool = false


func _physics_process(_delta: float) -> void:
	var shift_held := Input.is_action_pressed("colour_change_mode")
	if shift_held:
		handle_colour()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2(0, 0)
		
	if Input.is_action_just_pressed("fire"):
		fire()
	if Input.is_action_pressed("colour_change_mode"):
		in_colour_change_mode = true
	else:
		in_colour_change_mode = false
		
	handle_rotation()

	move_and_slide()
	
# TODO: improve movement (make more floaty, add accel/decell properties


func fire() -> void:
	var bullet = bullet_path.instantiate()
	bullet.pos = bullet_spawn.global_position
	bullet.dir = rotation
	bullet.rot = global_rotation
	get_parent().add_child(bullet)
	

func handle_rotation() -> void:
	look_at(get_global_mouse_position())


func handle_colour() -> void:
	for colour in colours:
		if Input.is_action_pressed(colour) and current_colour != colour:
			sprite.animation = colour
			current_colour = colour
