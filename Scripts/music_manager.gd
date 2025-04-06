extends Node

var playing = false
@onready var music_player: AudioStreamPlayer = $MusicPlayer

@export var scary_ambiences: Array[AudioStream] = []
func play_scary_ambience():
	if not playing:
		music_player.volume_db = -8
		playing = true
		music_player.stream = scary_ambiences[randi() % len(scary_ambiences)]
		music_player.play()
		music_player.finished.connect(on_music_finished)
	
func on_music_finished():
	playing = false
