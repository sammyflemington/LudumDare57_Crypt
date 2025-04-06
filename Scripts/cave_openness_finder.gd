extends Node2D
## Increases reverb when you're in a very open area

@onready var rays = [
	$RayCast2D,
	$RayCast2D2,
	$RayCast2D3
]
# Called when the node enters the scene tree for the first time.
var verb_effect
func _ready() -> void:
	var idx = AudioServer.get_bus_index("VerbBus")
	verb_effect = AudioServer.get_bus_effect(idx, 0)

var wideness : float = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
var jumpscare_timer : float = 0.0
func _process(delta: float) -> void:
	var total_dist = 0.0
	var distances = []
	for ray in rays:
		if not ray.is_colliding():
			distances.append(36)
		else:
			distances.append((ray.get_collision_point() - ray.global_position).length())
	
	var highest_dist = 0
	for dist in distances:
		if dist > highest_dist:
			highest_dist = dist
	
	distances.erase(highest_dist)
	for dist in distances:
		total_dist += dist
	
	wideness = lerp(wideness, total_dist / (36.0*2.0), delta * 2.0)
	
	if verb_effect is AudioEffectReverb:
		verb_effect.room_size = clamp(wideness, 0.0, 1.0)
		verb_effect.predelay_feedback = clamp(wideness / 2.0, 0.0, 0.5)
		verb_effect.wet = clamp(wideness / 2.0, 0.1, 0.5)
	
	if wideness > 0.9:
		if jumpscare_timer > 30.0:
			MusicManager.play_scary_ambience()
	else:
		jumpscare_timer += delta
	
