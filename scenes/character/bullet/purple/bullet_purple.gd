extends Bullet


@export var glow: PointLight2D
@export var particles: CPUParticles2D
var can_start: bool = false


func _ready() -> void:
	super()
	var delay_timer: Timer = $Delay
	delay_timer.start()
	

func setup(chrg_time):
	super(chrg_time)
	
	damage *= (chrg_time / 1000 + 1)
	speed *= (chrg_time / 1000 + 1)
	scale = Vector2(scale.x * (chrg_time / 2000) + 1, scale.y * (chrg_time / 2000) + 1)
	if scale < Vector2.ONE:
		scale = Vector2.ONE
	glow.energy *= (chrg_time / 30 + 1)
	particles.amount *= (chrg_time / 100 + 1)
	

func move(_delta: float):
	if can_start:
		return Vector2(speed, 0).rotated(dir)
	else:
		return Vector2.ZERO


func _on_delay_timeout() -> void:
	can_start = true
