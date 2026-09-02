extends Bullet


@export var frequency: float = 100
@export var amplitude: float = 200
var time_passed: float = 0

const MAX_CHARGE_TIME: float = 1000


func setup(chrg_time: float) -> void:
	if chrg_time > MAX_CHARGE_TIME:
		chrg_time = MAX_CHARGE_TIME
	
	amplitude *= (chrg_time / 100 + 1)
	frequency *= (chrg_time / 1000 + 1)
	scale = Vector2(scale.x * (chrg_time / 1000) + 1.5, scale.y * (chrg_time / 1000) + 1.5)
	if scale < Vector2.ONE:
		scale = Vector2.ONE


func move(delta: float) -> Vector2:
	time_passed += delta * frequency
	var vel_x = speed
	var vel_y = sin(time_passed) * amplitude
	
	return Vector2(vel_x, vel_y).rotated(dir)
