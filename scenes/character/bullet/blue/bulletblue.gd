extends Bullet


@export var frequency: float = 10
@export var amplitude: float = 25
var time_passed: float = 0


func setup(chrg_time: float) -> void:
	super(chrg_time)
	
	damage *= (chrg_time / 1000 + 1)
	amplitude *= (chrg_time / 1000 + 1)
	frequency *= (chrg_time / 200 + 1)
	scale = Vector2(scale.x * (chrg_time / 600) + 1.5, scale.y * (chrg_time / 600) + 1.5)
	if scale < Vector2.ONE:
		scale = Vector2.ONE


func move(delta: float) -> Vector2:
	time_passed += delta * frequency
	var vel_x = speed
	var vel_y = cos(time_passed) * amplitude * frequency
	
	return Vector2(vel_x, vel_y).rotated(dir)
