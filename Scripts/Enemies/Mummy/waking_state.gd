extends State


@onready var sprite: Sprite2D = $"../../Flipper/Animator/Sprite2D"
@onready var aggro_state: Node = $"../AggroState"
@onready var wake_sound: AudioStreamPlayer2D = $"../../WakeSound"

var frame_timer : float = 0.0
func on_enter():
	sprite.frame = 0
	parent.velocity = Vector2.ZERO
	wake_sound.play_rand()

func process_physics(dt):
	frame_timer += dt
	if frame_timer >= .1:
		if sprite.frame == 3:
			state_machine.enter_state(aggro_state)
			return
		sprite.frame += 1
		frame_timer = 0.0
		
