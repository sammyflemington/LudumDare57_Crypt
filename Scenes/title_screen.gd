extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_scary_ambience()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var game_scn= preload("res://test_world.tscn")
var debug_scn = preload("res://Scripts/WorldGen/generator_test_world.tscn")
func _on_explore_pressed() -> void:
	get_tree().change_scene_to_packed(debug_scn)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_scn)
	
