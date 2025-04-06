extends State
@onready var sprite: Sprite2D = $"../../Flipper/Animator/Sprite2D"

func on_enter():
	sprite.frame = 0
