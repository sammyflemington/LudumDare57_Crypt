extends PointLight2D

var base_energy : float
var base_scale : float
var base_pos : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_energy = energy
	base_scale = texture_scale
	base_pos = position

var timer : float = 0.0
@export var speed : float = 0.2
var flicker = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if flicker and timer > speed:
		energy = randf_range(base_energy * .9, base_energy * 1.1)
		texture_scale = randf_range(base_scale * .95, base_scale * 1.05)
		timer = 0.0
		#position = Vector2(randi_range(-1, 1), randi_range(-1, 1)) + base_pos
