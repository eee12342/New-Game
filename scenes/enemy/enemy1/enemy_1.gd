extends Enemy


@onready var pause_timer: Timer = $Pause

var finding_player: bool = false
var paused: bool = false
var target: float


func _process(_delta: float) -> void:
	print(target)
	if not finding_player:
		find_player()
	else:
		if global_rotation == target:
			paused = true
			finding_player = false


func find_player():
	finding_player = true
	target = get_angle_to(player.global_position)
	var tween = create_tween()
	tween.tween_property(self, "global_rotation", target, 2)
	rotation_degrees += 180


func _on_pause_timeout() -> void:
	pass
