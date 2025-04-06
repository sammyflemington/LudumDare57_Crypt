extends Node2D

@onready var world_generator: WorldGenerated = $WorldGenerator
@onready var camera_2d: Camera2D = $Camera2D
@onready var texture_rect: TextureRect = $Camera2D/CanvasLayer/TextureRect

var spawned = false
var player_scn = preload("res://player.tscn")
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_gen_level"):
		world_generator.generate_level()
	
	var move = Input.get_vector("left", "right", "up", "down")
	camera_2d.position += delta * 500 * move * (1.0 - camera_2d.zoom.x)
	
	if Input.is_action_just_pressed("mine_up"):
		camera_2d.zoom += Vector2(.1,.1)
	if Input.is_action_just_pressed("mine_down"):
		camera_2d.zoom -= Vector2(.1,.1)
	camera_2d.zoom = clamp(camera_2d.zoom, Vector2(0.1, 0.1), Vector2(1.0, 1.0))
	if Input.is_action_just_pressed("rope") and not spawned:
		camera_2d.enabled = false
		var player = player_scn.instantiate()
		add_child(player)
		player.global_position = camera_2d.global_position
		spawned = true
		texture_rect.hide()
