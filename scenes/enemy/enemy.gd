extends CharacterBody2D
class_name Enemy


@export var speed: float = 300.0
@export var max_health: float = 100.0
@export var animations: AnimatedSprite2D

var player: CharacterBody2D
var health := max_health
var damage: float = 35


func _ready() -> void:
	player = Messenger.Player
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
		
		
func _on_death_finished():
	self.queue_free()
