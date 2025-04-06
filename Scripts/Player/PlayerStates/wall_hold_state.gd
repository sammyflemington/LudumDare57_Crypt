extends State

var wall_dir = 1
@onready var wall_ray_right: RayCast2D = $"../../WallRayRight"
@onready var wall_ray_left: RayCast2D = $"../../WallRayLeft"
@onready var normal_state: Node = $"../NormalState"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func on_enter():
	# snap parent down wall
	var tile_to_snap = Globals.world.world_pos_to_cell(parent.global_position) + Vector2i(0, 2)
	parent.position = tile_to_snap * 6.0
	parent.velocity = Vector2(-wall_dir * 10.0, 0)
	parent.move_and_slide()
	parent.velocity = Vector2.ZERO
	animation_player.play("Idle")

func process_physics(dt):
	parent.velocity.x = wall_dir * 10.0
	
	if Input.is_action_pressed("down"):
		parent.velocity.y += dt * 10.0
		parent.velocity.y = clamp(parent.velocity.y, 0, 50)
	else:
		parent.velocity.y = 0
	if wall_dir > 0:
		if not wall_ray_right.is_colliding():
			state_machine.enter_state(normal_state)
	elif wall_dir < 0:
		if not wall_ray_left.is_colliding():
			state_machine.enter_state(normal_state)
	
	if Input.is_action_just_pressed("jump"):
		state_machine.enter_state(normal_state)
		parent.velocity = Vector2(-wall_dir * 20, -50)
