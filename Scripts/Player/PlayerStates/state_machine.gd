extends Node
class_name StateMachine

@export var current_state : State
@export var parent : CharacterBody2D

func _ready():
	for state in get_children():
		if state is State:
			state.parent = parent
			state.state_machine = self
	enter_state(current_state)

func enter_state(to: State):
	if current_state:
		current_state.on_exit()
	current_state = to
	current_state.on_enter()

func _physics_process(delta: float) -> void:
	current_state.process_physics(delta)
