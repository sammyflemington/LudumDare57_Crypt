extends AudioStreamPlayer2D

@export var randomness : float = 0.1
var base_pitch
func _ready():
	base_pitch = pitch_scale

func play_rand():
	pitch_scale = randf_range(base_pitch - randomness, base_pitch + randomness)
	play()
