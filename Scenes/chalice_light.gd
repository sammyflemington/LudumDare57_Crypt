extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var light: PointLight2D = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_2d.play()
	light.base_scale = 0.0

var tween

func _process(dt):
	if audio_stream_player_2d:
		audio_stream_player_2d.volume_db = 0 - (1.0 - light.base_scale) * 60

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(light, "base_scale", 1.0, 1.0).from(0)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(light, "base_scale", 0.0, 2.0)
