extends State

@onready var flipper: Node2D = $"../../Flipper"

const SPEED = 20.0
const ACCEL = 200.0
const FRIC_FLOOR = 17.0
const JUMP_VELOCITY = -60.0
const GRAV = 300
var coyote_timer = 0.2
var facing = 1

@onready var middle_ray: RayCast2D = $"../../MiddleRay"
@onready var right_ray: RayCast2D = $"../../RightRay"
@onready var left_ray: RayCast2D = $"../../LeftRay"

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var jump : bool = false
var direction : float = 0.0
@onready var wall_ray_right: RayCast2D = $"../../WallRayRight"
@onready var wall_ray_left: RayCast2D = $"../../WallRayLeft"

var player : Player = null

func process_physics(dt):
	check_for_ledge()
	
	do_ai_stuff()
	
	## Add the gravity.
	parent.velocity += Vector2(0, GRAV) * dt
	
	if parent.is_on_floor():
		coyote_timer = 0.2
	else:
		coyote_timer -= dt
	# Handle jump.
	if jump and coyote_timer > 0:
		parent.velocity.y = JUMP_VELOCITY
		jump = false


	if direction and parent.is_on_floor():
		parent.velocity.x += direction * ACCEL * dt
	else:
		parent.velocity.x += direction * ACCEL * dt * .1
	
	var fric = -parent.velocity.x * FRIC_FLOOR
	if parent.is_on_floor():
		parent.velocity.x += fric * dt
	
	parent.velocity.limit_length(SPEED)

	if abs(parent.velocity.x) > 1 and parent.is_on_floor():
		animation_player.play("Run")
	else:
		animation_player.play("Idle")
	
	if abs(parent.velocity.x) > 10:
		flipper.scale.x = sign(parent.velocity.x)
		facing = flipper.scale.x
	
	if abs(parent.velocity.x) > 10:
		if not chase_sound.playing:
			chase_sound.play()
	
@onready var chase_sound: AudioStreamPlayer2D = $"../../ChaseSound"

func check_for_ledge() -> bool:
	if not parent.is_on_floor():
		return false
	# ledge off the left
	if right_ray.is_colliding() and not middle_ray.is_colliding() and parent.velocity.x < 0:
		parent.velocity *= .3
		jump = true
		return true
	if left_ray.is_colliding() and not middle_ray.is_colliding() and parent.velocity.x > 0:
		parent.velocity *= .3
		jump = true
		return true
	return false

func do_ai_stuff():
	if player:
		direction = sign(player.global_position.x - parent.global_position.x)
	
	if wall_ray_right.is_colliding() and direction > 0:
		jump = true
	elif wall_ray_left.is_colliding() and direction < 0:
		jump = true

func on_enter():
	if player:
		player.lose_light()
		chase_sound.play()
