extends Area2D


var i_frame : float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	i_frame -= delta


func _on_body_entered(body: Node2D) -> void:
	if i_frame < 0.0:
		if body is Player:
			var knockback_dir = (body.global_position - global_position).normalized()
			body.get_hurt(2, knockback_dir * 30.0 + (Vector2(0, -30)))
			i_frame = 1.0
