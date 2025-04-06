extends ColorRect
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready():
	hide()

func _input(event):
	if Input.is_action_just_pressed("pause"):
		if not visible:
			show()
			resume_button.grab_focus()
			get_tree().paused = true
		else:
			hide()
			get_tree().paused = false
		

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
	hide()
