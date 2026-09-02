extends Bullet


@export var frequency: float = 30
@export var amplitude: float = 600
var time_passed: float = 0


func move(delta: float):
	time_passed += delta * frequency
	var vel_x = speed
	var vel_y = sin(time_passed) * amplitude
	
	return Vector2(vel_x, vel_y).rotated(dir)
