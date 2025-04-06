extends State
@onready var rope_detector: Area2D = $"../../RopeDetector"

@onready var normal_state: Node = $"../NormalState"
@onready var middle_ray: RayCast2D = $"../../MiddleRay"

func on_enter():
	if rope_detector.get_rope():
		var rope_pos_grid = Globals.world.world_pos_to_cell(rope_detector.get_rope().global_position)
		parent.position.x = rope_pos_grid.x * 6.0
		parent.position.x += 3
	

func process_physics(dt):
	if not rope_detector.is_touching_rope():
		state_machine.enter_state(normal_state)
	
	parent.velocity.x = 0
	parent.velocity.y = 30 if Input.is_action_pressed("down") else 0
	if Input.is_action_pressed("up"):
		parent.velocity.y = -30
	
	if Input.is_action_just_pressed("jump"):
		var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
		parent.velocity = Vector2(dir * 30, -30)
		state_machine.enter_state(normal_state)
	
	if middle_ray.is_colliding():
		state_machine.enter_state(normal_state)
