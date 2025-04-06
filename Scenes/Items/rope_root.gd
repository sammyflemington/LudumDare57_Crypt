extends Node2D

@onready var ray: RayCast2D = $Sections/RayCast2D
@onready var sections: Node2D = $Sections
@onready var up_ray: RayCast2D = $Sections/UpRay

const rope_section = preload("res://Scenes/Items/rope_section.tscn")
var look_up = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if look_up:
		up_ray.force_raycast_update()
		if up_ray.is_colliding():
			sections.position.y = up_ray.get_collision_point().y - sections.global_position.y + 1
		else:
			global_position.y -= 32
	var dist = 96
	ray.force_raycast_update()
	if ray.is_colliding():
		dist = (ray.get_collision_point() - global_position).length() + 1
		print("DIST: %s" % dist)
		print("Collider: %s", ray.get_collider())
	var tiles = floor(dist / 6.0)
	
	for i in range(tiles):
		var section = rope_section.instantiate()
		if i > 0:
			section.get_node("Sprite2D").frame = 1
		if i >= tiles - 1:
			section.get_node("Sprite2D").frame = 2
		section.position = Vector2(0, i * 6.0)
		sections.add_child(section)
		await get_tree().create_timer(0.1).timeout
