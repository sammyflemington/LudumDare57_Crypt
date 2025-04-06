extends CharacterBody2D
class_name Player


@onready var win_state: Node = $StateMachine/WinState

const glow_stick = preload("res://Scenes/Items/glow_stick.tscn")
var glow_sticks := 4
var ropes := 3
var health : float = 10.0
var max_health : float = 10.0
signal health_changed(hp, max)

signal ropes_changed(to: int)
signal glow_sticks_changed(to: int)
signal died()
@onready var dead_state: Node = $StateMachine/DeadState
var dead: bool = false
@onready var normal_state: Node = $StateMachine/NormalState

@onready var camera_2d: Camera2D = $Camera2D
@onready var state_machine: StateMachine = $StateMachine
@onready var mining_block_state: Node = $StateMachine/MiningBlockState
var falling := false
var last_fall_speed := 0.0
var invuln_timer = 3.0
var rope_bits : int = 0
var glow_bits : int = 0
@onready var hurt_sound_player: AudioStreamPlayer2D = $HurtSoundPlayer
@onready var pickup_sound_player: AudioStreamPlayer2D = $PickupSoundPlayer
var can_move = false
@onready var eyelid_player: AnimationPlayer = $CanvasLayer/EyelidPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blood_parts: GPUParticles2D = $Flipper/BloodParts
@onready var mining_parts: GPUParticles2D = $PickaxeRotator/MiningParts

func _ready():
	blood_parts.emitting = true
	mining_parts.emitting = true
	await get_tree().create_timer(0.1)
	blood_parts.emitting = false
	mining_parts.emitting = false
	eyelid_player.play("Wake")
	await get_tree().create_timer(2).timeout
	can_move = true
	

func _physics_process(dt: float) -> void:
	invuln_timer -= dt
	if not can_move:
		velocity.x = 0
		#animation_player.play("Idle")
	move_and_slide()
	if dead:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return
	handle_mining()
	
	if not is_on_floor():
		last_fall_speed = velocity.y
	elif last_fall_speed > 0:
		#print("Impact speed: %s" % last_fall_speed)
		if last_fall_speed > 120 and invuln_timer < 0:
			# Death
			get_hurt((last_fall_speed - 120) / 4.0)
		last_fall_speed = 0.0
	
	# Throw glow sticks
	if Input.is_action_just_pressed("glowstick") and glow_sticks > 0:
		var up_amount = 0
		if Input.is_action_pressed("up"):
			up_amount = -1
		glow_sticks -= 1
		glow_sticks_changed.emit(glow_sticks)
		# throw a glowstick
		var stick = glow_stick.instantiate()
		stick.global_position = global_position
		stick.velocity = Vector2(normal_state.facing, up_amount) * 50.0 + Vector2(0, -20)
		Globals.world.add_game_object(stick)

	
	

var can_mine : bool = true
@onready var mine_timer: Timer = $MineTimer
const loot_drop_scn = preload("res://Scenes/Items/loot_drop.tscn")
func handle_mining():
	var mine_dir : Vector2 = Input.get_vector("mine_left", "mine_right", "mine_up", "mine_down")
	
	if mine_dir.length() > 0.5:
		# mine a block
		if can_mine:
			var target_pos = global_position + (mine_dir * 6.0)
			if Globals.world.is_terrain_at_position(target_pos):
				var grid_pos = Globals.world.world_pos_to_cell(target_pos)
				var tile_type: WorldGenerated.Blocks = Globals.world.break_tile_at_position(global_position + (mine_dir * 6.0))
				
				# create loot
				create_loot(tile_type, grid_pos, mine_dir)
				
				
				# Snap player to the cell next to the place they mined
				position = (Vector2(grid_pos) - mine_dir) * 6.0 + Vector2(4,3)
				mining_block_state.mine_dir = mine_dir
				mining_block_state.old_state = state_machine.current_state
				state_machine.enter_state(mining_block_state)
				
				can_mine = false
				mine_timer.start()
			else:
				# Swing pickaxe as attack
				attack(mine_dir)

@onready var pickaxe_animator: AnimationPlayer = $PickaxeRotator/PickaxeSprite/PickaxeAnimator
@onready var pickaxe_rotator: Node2D = $PickaxeRotator
@onready var fake_pick_sprite: Sprite2D = $Flipper/Animator/FakePickSprite
@onready var damage_collision_shape: CollisionShape2D = $PickaxeRotator/PickaxeSprite/DamageArea/DamageCollisionShape
@onready var damage_area: Area2D = $PickaxeRotator/PickaxeSprite/DamageArea

func attack(dir: Vector2):
	fake_pick_sprite.hide()
	pickaxe_rotator.show()
	pickaxe_rotator.rotation = dir.angle()
	pickaxe_animator.play("Swing")
	damage_collision_shape.disabled = false
	damage_area.swing_dir = dir
	pickaxe_animator.animation_finished.connect(swing_finished)

func swing_finished(_anim):
	damage_collision_shape.disabled = true
	pickaxe_rotator.hide()
	fake_pick_sprite.show()
	
func recover_glowstick():
	glow_sticks += 1
	glow_sticks_changed.emit(glow_sticks)

func _on_mine_timer_timeout() -> void:
	can_mine = true

func use_rope():
	ropes -= 1
	ropes_changed.emit(ropes)

func gain_loot(type: WorldGenerated.Blocks):
	match type:
		WorldGenerated.Blocks.DIAMOND:
			rope_bits += 1
		WorldGenerated.Blocks.EMERALD:
			glow_bits += 1
		WorldGenerated.Blocks.HEALTHPACK:
			health += 2.5
			health = clamp(health, 0, max_health)
			health_changed.emit(health, max_health)
		_:
			pass
	
	pickup_sound_player.play_rand()
	if rope_bits >= 3:
		rope_bits = 0
		ropes += 1
		ropes_changed.emit(ropes)
	
	if glow_bits >= 3:
		glow_sticks += 1
		glow_bits = 0
		glow_sticks_changed.emit(glow_sticks)

func create_loot(tile_type, grid_pos, mine_dir):
	if tile_type in [WorldGenerated.Blocks.DIAMOND, WorldGenerated.Blocks.EMERALD]:
		var drop = loot_drop_scn.instantiate()
		drop.loot_id = tile_type
		drop.global_position = grid_pos * 6.0
		Globals.world.add_game_object(drop)
		drop.velocity = Vector2(randf_range(4 * -mine_dir.x, 20 * -mine_dir.x), randf_range(-40, -70))
	else:
		match tile_type:
			WorldGenerated.Blocks.CHEST:
				for i in range(6):
					var drop = loot_drop_scn.instantiate()
					drop.loot_id = WorldGenerated.Blocks.DIAMOND if randf() < .5 else WorldGenerated.Blocks.EMERALD
					drop.global_position = grid_pos * 6.0
					Globals.world.add_game_object(drop)
					drop.velocity = Vector2(randf_range(4 * -mine_dir.x, 20 * -mine_dir.x), randf_range(-40, -70))
					await get_tree().create_timer(0.1).timeout
				var drop = loot_drop_scn.instantiate()
				drop.loot_id = WorldGenerated.Blocks.HEALTHPACK
				drop.global_position = grid_pos * 6.0
				Globals.world.add_game_object(drop)
				drop.velocity = Vector2(randf_range(4 * -mine_dir.x, 20 * -mine_dir.x), randf_range(-40, -70))
			WorldGenerated.Blocks.CHALICE:
				for chalice in get_tree().get_nodes_in_group("chalice"):
					chalice.queue_free()
				can_move = false
				state_machine.enter_state(win_state)
				animation_player.play("Win")

func get_hurt(damage: float, knockback: Vector2 = Vector2.ZERO):
	if dead:
		return
	health -= damage
	hurt_sound_player.play_rand()
	health_changed.emit(health, max_health)
	if health <= 0:
		state_machine.enter_state(dead_state)
	velocity += knockback
@onready var light_timer: Timer = $LightTimer

@onready var lantern: PointLight2D = $PointLight2D
func lose_light():
	lantern.flicker = false
	create_tween().tween_property(lantern, "texture_scale", 0.4, 1.0)
	create_tween().tween_property(lantern, "energy", 0.3, 1.0)
	light_timer.start()

func _on_light_timer_timeout() -> void:
	create_tween().tween_property(lantern, "texture_scale", 1, 3.0).from(0.1)
	create_tween().tween_property(lantern, "energy", lantern.base_energy, 1.0).from(0.3)
	await get_tree().create_timer(3.0)
	lantern.flicker = true

@onready var fade_out_rect: ColorRect = $CanvasLayer/FadeOutRect

func win():
	create_tween().tween_property(fade_out_rect, "modulate", Color(1,1,1,1), 5.0)
	await(get_tree().create_timer(7.0).timeout)
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
