extends Enemy


@export var rotation_speed_seconds: float = 1

@onready var pause_timer: Timer = $Pause

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
	tween.finished.connect(func(): pause_timer.start())


func _on_pause_timeout() -> void:
	finding_player = false
