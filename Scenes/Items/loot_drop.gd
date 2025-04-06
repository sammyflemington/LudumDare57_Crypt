extends CharacterBody2D
class_name LootDrop

var loot_id : WorldGenerated.Blocks

const loot_atlas_map : Dictionary = {
	WorldGenerated.Blocks.DIAMOND: Vector2(6, 6),
	WorldGenerated.Blocks.EMERALD: Vector2(12, 6),
	WorldGenerated.Blocks.RUBY: Vector2(18, 6),
	WorldGenerated.Blocks.HEALTHPACK: Vector2(0, 12)
}
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.texture = sprite.texture.duplicate()
	var tex = sprite.texture as AtlasTexture
	tex.region.position = loot_atlas_map[loot_id]

const friction = 1.0
const GRAV = 300
var t = 0.0
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
var can_pick_up = false

func _physics_process(delta: float) -> void:
	t += delta
	if t >= 0.5:
		can_pick_up = true
	# Add the gravity.
	if is_on_floor():
		velocity -= velocity * friction
	velocity.y += GRAV * delta
	var collision = move_and_collide(velocity * delta)
	
	if collision != null:
		velocity += collision.get_normal() * velocity.length() * .8
		
		if velocity.length() > 40:
			bounce_sound.play_rand()
		velocity *= .6
