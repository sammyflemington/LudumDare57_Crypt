extends State

const SPEED = 30.0
const ACCEL = 500.0
const FRIC_FLOOR = 17.0
const JUMP_VELOCITY = -60.0
const GRAV = 300

@onready var right_ray: RayCast2D = $"../../RightRay"
@onready var middle_ray: RayCast2D = $"../../MiddleRay"
@onready var left_ray: RayCast2D = $"../../LeftRay"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var wall_hold_state: Node = $"../WallHoldState"
@onready var camera_2d: Camera2D = $"../../Camera2D"
var camera_look_down_pos : Vector2 = Vector2(0, 24)
@onready var flipper: Node2D = $"../../Flipper"

var coyote_timer : float = 0.1
var facing = 1

func process_physics(dt):
	check_for_ledge()

	
	## Add the gravity.
	parent.velocity += Vector2(0, GRAV) * dt
	
	if parent.is_on_floor():
		coyote_timer = 0.2
	else:
		coyote_timer -= dt
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_timer > 0:
		parent.velocity.y = JUMP_VELOCITY
		coyote_timer = -1

	var direction := Input.get_axis("left", "right")
	if direction and parent.is_on_floor():
		parent.velocity.x += direction * ACCEL * dt
	else:
		parent.velocity.x += direction * ACCEL * dt * .2
	
	var fric = -parent.velocity.x * FRIC_FLOOR
	if parent.is_on_floor():
		parent.velocity.x += fric * dt
	
	parent.velocity.limit_length(SPEED)

	if abs(parent.velocity.x) > 1 and parent.is_on_floor():
		animation_player.play("Run")
	else:
		animation_player.play("Idle")
	
	if Input.is_action_pressed("down") and parent.is_on_floor():
		camera_2d.position = lerp(camera_2d.position, camera_look_down_pos, dt * 4.0)
	else:
		camera_2d.position = lerp(camera_2d.position, Vector2.ZERO, dt * 6.0)
	
	if abs(parent.velocity.x) > 10:
		flipper.scale.x = sign(parent.velocity.x)
		facing = flipper.scale.x
	
	handle_rope()
	
	handle_rope_climb()

func check_for_ledge() -> bool:
	if not parent.is_on_floor():
		return false
	# ledge off the left
	if right_ray.is_colliding() and not middle_ray.is_colliding() and parent.velocity.x < 0:
		parent.velocity *= .3
		return true
	if left_ray.is_colliding() and not middle_ray.is_colliding() and parent.velocity.x > 0:
		parent.velocity *= .3
		return true
	return false

const ROPE_ROOT = preload("res://Scenes/Items/rope_root.tscn")
func handle_rope():
	if Input.is_action_just_pressed("rope") and parent.ropes > 0:
		var rope = ROPE_ROOT.instantiate()
		var player_grid_pos = Globals.world.world_pos_to_cell(parent.global_position)
		var target_pos = player_grid_pos + Vector2i(facing, 0)
		if Input.is_action_pressed("up"):
			rope.look_up = true
		
		parent.use_rope()
		rope.position = target_pos * 6.0
		Globals.world.add_child(rope)

@onready var rope_climb_state: Node = $"../RopeClimbState"
@onready var rope_detector: Area2D = $"../../RopeDetector"
func handle_rope_climb():
	if Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		if rope_detector.is_touching_rope():
			state_machine.enter_state(rope_climb_state)
