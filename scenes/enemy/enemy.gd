extends CharacterBody2D
class_name Enemy


@export var speed: float = 300.0
@export var max_health: float = 100.0
@export var animations: AnimatedSprite2D
@export var hitbox: Area2D

@export var colour_chance: int = 4

var colours: Array = ["colour1"] # TODO: add more colours
var current_colour: String

var player: CharacterBody2D
var health := max_health
var damage: float = 35
var damage_tween: Tween
var random = RandomNumberGenerator.new()


func _ready() -> void:
	print("Enemy ready, collision layer: ", collision_layer, " mask: ", collision_mask)
	player = Messenger.player
	Messenger.connect("damage_to_enemy", _on_damaged)
	animations.connect("animation_finished", _on_death_finished)


func _physics_process(_delta: float) -> void:
	check_dead()
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_projectiles"):
		print("I've been hit!")
		Messenger.enemy_hit(body, self)
		
		
func check_dead() -> void:
	if health <= 0:
		animations.visible = true
		animations.play("Death")


func _on_damaged(damage_taken: float, body: CharacterBody2D):
	if body == self:
		health -= damage_taken
		
		damage_tween = create_tween()
		damage_tween.tween_property(animations, "self_modulate", Color(18.892, 18.892, 18.892), 0.1)
		damage_tween.tween_property(animations, "self_modulate", Color("#ffffff"), 0.15)
		
		
func _on_death_finished():
	self.queue_free()
	

func set_random_colour():
	var will_change_colour = random.randi_range(0, colour_chance)
	if will_change_colour != 1:
		return
	
	var colour_choice_idx = random.randi_range(0, len(colours) - 1)
	var colour_chosen = colours[colour_choice_idx]
	tween_colour(colour_chosen)
	current_colour = colour_chosen
	
	
func tween_colour(chosen_colour: String):
	# TODO: add cases for each colour
	var end_colour
	if chosen_colour == "colour1":
		end_colour = Color(Color(0.477, 1.491, 4.416))
	var colour_change_tween: Tween = create_tween()
	colour_change_tween.tween_property(self, "modulate", end_colour, 0.5)


func reset_colour():
	var end_colour = Color("#ffffff")
	var colour_change_tween: Tween = create_tween()
	colour_change_tween.tween_property(self, "modulate", end_colour, 0.5)
	current_colour = ""
	

func set_collision():
	hitbox.collision_mask = 3
	hitbox.collision_layer = 4
