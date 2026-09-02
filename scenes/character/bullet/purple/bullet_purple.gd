extends Bullet


var can_start: bool = false


func _ready() -> void:
	super()
	var delay_timer: Timer = $Delay
	delay_timer.start()
	

func move(_delta: float):
	if can_start:
		return Vector2(speed, 0).rotated(dir)
	else:
		return Vector2.ZERO


func _on_delay_timeout() -> void:
	can_start = true
