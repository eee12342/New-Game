extends Enemy


@export var rotation_speed_seconds: float = 0.5

@onready var pause_timer: Timer = $Pause
@onready var raycast: RayCast2D = $RayCast2D
@onready var charge_progress: TextureProgressBar = $ArrowProgress

var dying: bool = false
var finding_player: bool = false
var paused: bool = false
var target: float

var momentum_tween: Tween
var attack_tween: Tween
var tween: Tween
var charge_tween: Tween
var tweens: Array


func _ready() -> void:
	tweens = [momentum_tween, attack_tween, tween, charge_tween]
	super()


func _process(_delta: float) -> void:
	if not Messenger.player_dead:
		if not finding_player:
			find_player()
	

func find_player():
	finding_player = true
	var raw_target = global_position.direction_to(player.global_position).angle()
	var delta = angle_difference(global_rotation, raw_target)
	target = global_rotation + delta

	#momentum_tween = create_tween()
	#momentum_tween.set_ease(Tween.EASE_OUT)
	#var momentum_target: Vector2 = to_global(raycast.target_position / 8)
	#momentum_tween.tween_property(self, "global_position", momentum_target, 2)
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_rotation", target, rotation_speed_seconds)
	tween.finished.connect(func(): start_attack())


func _on_pause_timeout() -> void:
	attack()
	
	
func start_attack():
	pause_timer.start()
	charge_progress.visible = true
	charge_tween = create_tween()
	charge_tween.set_ease(Tween.EASE_IN)
	charge_tween.set_trans(Tween.TRANS_CUBIC)
	charge_tween.tween_property(charge_progress, "value", 100, 1)


func attack():
	if momentum_tween:
		momentum_tween.kill()
	if charge_tween:
		charge_tween.kill()
	charge_progress.visible = false
	charge_progress.value = 0
		
	attack_tween = create_tween()
	attack_tween.set_ease(Tween.EASE_IN_OUT)
	attack_tween.set_trans(Tween.TRANS_QUAD)
	attack_tween.tween_property(self, "global_position", to_global(raycast.target_position), 0.5)
	attack_tween.finished.connect(func(): attack_finished())
	
	
func attack_finished():
	finding_player = false
	charge_tween.kill()
	

func check_dead() -> void:
	if health <= 0:
		death_tween()
		super()
		
		
func death_tween() -> void:
	for tw in tweens:
		if tw:
			tw.kill()
			
	var dth = create_tween()
	var momentum_target: Vector2 = to_global(raycast.target_position / 10)
	dth.tween_property(self, "global_position", momentum_target, 1)
