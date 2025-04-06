extends CharacterBody2D
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound

const friction = 1.0
const GRAV = 300
var t = 0.0
func _physics_process(delta: float) -> void:
	t += delta
	# Add the gravity.
	if is_on_floor():
		velocity -= velocity * friction
	velocity.y += GRAV * delta
	var collision = move_and_collide(velocity * delta)
	
	if collision != null:
		velocity += collision.get_normal() * velocity.length() * .8
		if velocity.length() > 40:
			bounce_sound.play_rand()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if t < 1.0:
		return
	if body is Player:
		body.recover_glowstick()
		queue_free()

@onready var light: PointLight2D = $PointLight2D

func _on_timer_timeout() -> void:
	create_tween().tween_property(light, "energy", 0, 4.0).finished.connect(queue_free)
