extends Area2D

var swing_dir : Vector2 = Vector2.RIGHT
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(5, (swing_dir + Vector2(0, 1)) * 30.0)
