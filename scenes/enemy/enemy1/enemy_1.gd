extends Enemy


@export var rotation_speed_seconds: float = 1

@onready var pause_timer: Timer = $Pause
@onready var raycast: RayCast2D = $RayCast2D

var finding_player: bool = false
var paused: bool = false
var target: float


func _process(_delta: float) -> void:
	if not finding_player:
		find_player()


func find_player():
	finding_player = true
	var raw_target = global_position.direction_to(player.global_position).angle()
	var delta = angle_difference(global_rotation, raw_target)
	target = global_rotation + delta
	
	var tween = create_tween()
	tween.tween_property(self, "global_rotation", target, rotation_speed_seconds)
	tween.finished.connect(func(): attack())


func _on_pause_timeout() -> void:
	finding_player = false
	
	
func attack():
	var attack_tween = create_tween()
	attack_tween.tween_property(self, "global_position", to_global(raycast.target_position), 1)
	attack_tween.finished.connect(func(): pause_timer.start())
