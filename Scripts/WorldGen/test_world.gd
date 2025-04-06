extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var world_generator: Node2D = $WorldGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start_point : Vector2i = world_generator.get_start_point()
	player.position = Vector2(start_point.x, start_point.y) * 6.0
	print(player.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
