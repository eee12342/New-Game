extends Enemy


var finding_player: bool


func _process(_delta: float) -> void:
	find_player()


func find_player():
	finding_player = true
	var point = get_angle_to(player.global_position)
	var tween = create_tween()
	var time_spent = abs(rotation_degrees - point) / 100
	tween.tween_property(self, "rotation_degrees", point, time_spent)
	rotation_degrees += 180
	await tween.finished
