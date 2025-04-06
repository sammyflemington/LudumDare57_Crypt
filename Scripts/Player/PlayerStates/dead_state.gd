extends State
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var blood_parts: GPUParticles2D = $"../../Flipper/BloodParts"
@onready var restart_layer: Control = $"../../CanvasLayer/RestartLayer"

func _ready():
	restart_layer.modulate = Color(1,1,1,0)
func on_enter():
	parent.velocity = Vector2.ZERO
	parent.died.emit()
	animation_player.stop()
	animation_player.play("Die")
	blood_parts.emitting = true
	parent.dead = true
	create_tween().tween_property(restart_layer, "modulate", Color(1,1,1,1), 1.0).from(Color(1,1,1,0)).set_delay(1.0)
