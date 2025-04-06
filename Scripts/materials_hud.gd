extends VBoxContainer
@onready var health_bar: TextureProgressBar = $HealthBar

@export var player : Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.glow_sticks_changed.connect(on_glow_sticks_changed)
	player.ropes_changed.connect(on_ropes_changed)
	
	on_glow_sticks_changed(player.glow_sticks)
	on_ropes_changed(player.ropes)
	health_bar.on_health_changed(player.health, player.max_health)
	player.health_changed.connect(health_bar.on_health_changed)
	
@onready var sticks_container: HBoxContainer = $SticksContainer
const GLOWSTICK_TEXTURE = preload("res://Scenes/Items/glowstick_texture.tres")

func on_glow_sticks_changed(to: int):
	to = clamp(to, 0, 6)
	for child in sticks_container.get_children():
		child.queue_free()
	for i in range(to):
		var rect = TextureRect.new()
		rect.texture = GLOWSTICK_TEXTURE
		sticks_container.add_child(rect)

@onready var ropes_container: HBoxContainer = $RopesContainer
const ROPE_TEXTURE = preload("res://Art/rope_icon.png")

func on_ropes_changed(to: int):
	to = clamp(to, 0, 6)
	for child in ropes_container.get_children():
		child.queue_free()
	for i in range(to):
		var rect = TextureRect.new()
		rect.texture = ROPE_TEXTURE
		ropes_container.add_child(rect)
