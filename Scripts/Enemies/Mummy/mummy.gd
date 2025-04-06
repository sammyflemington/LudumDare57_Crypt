extends CharacterBody2D

@onready var aggro_state: State = $StateMachine/AggroState
@onready var state_machine: StateMachine = $StateMachine
@onready var waking_state: State = $StateMachine/WakingState
@onready var passive_state: Node = $StateMachine/PassiveState

var health = 30.0

func _ready():
	state_machine.enter_state(passive_state)

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		if state_machine.current_state != aggro_state:
			aggro_state.player = body
			state_machine.enter_state(waking_state)
			

func _physics_process(delta: float) -> void:
	move_and_slide()
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

func take_damage(amount : float, knockback: Vector2 = Vector2.ZERO):
	hurt_sound.play_rand()
	health -= amount
	if health <= 0:
		queue_free()
	velocity += knockback
