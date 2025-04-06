extends State

@onready var pickaxe_animator: AnimationPlayer = $"../../PickaxeRotator/PickaxeSprite/PickaxeAnimator"

@onready var normal_state: Node = $"../NormalState"
@onready var timer: Timer = $Timer
var mine_dir : Vector2 
@onready var pickaxe_rotator: Node2D = $"../../PickaxeRotator"
@onready var mining_parts: GPUParticles2D = $"../../PickaxeRotator/MiningParts"
@onready var fake_pick_sprite: Sprite2D = $"../../Flipper/Animator/FakePickSprite"
@onready var mine_sound: AudioStreamPlayer = $MineSound

@onready var old_state : State = normal_state
func _ready():
	pickaxe_rotator.hide()

func on_enter():
	pickaxe_rotator.show()
	pickaxe_animator.stop()
	pickaxe_rotator.rotation = mine_dir.angle()
	pickaxe_animator.play("Swing")
	mining_parts.emitting = true
	timer.start()
	fake_pick_sprite.hide()
	mine_sound.pitch_scale = randf_range(.9, 1.1)
	mine_sound.play()

func on_exit():
	pickaxe_rotator.rotation = 0
	fake_pick_sprite.show()
	pickaxe_rotator.hide()

func process_physics(dt):
	parent.velocity = Vector2.ZERO

func _on_timer_timeout() -> void:
	state_machine.enter_state(old_state)
