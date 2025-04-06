extends Area2D

var ropes = []


func _on_area_entered(area: Area2D) -> void:
	ropes.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area in ropes:
		ropes.erase(area)

func is_touching_rope() -> bool:
	return not ropes.is_empty()

func get_rope() -> Node2D:
	if len(ropes) > 0:
		return ropes[0].get_parent()
	return null
