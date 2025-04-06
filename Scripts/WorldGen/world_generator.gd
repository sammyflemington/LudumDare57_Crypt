extends Node2D
class_name WorldGenerated

@export var level_size : Vector2i = Vector2i(512, 512)
@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var bg_layer: TileMapLayer = $BGLayer
@export var steps : int = 100
@export var walker_count : int = 2
@export var diamond_noise: Noise
@export var other_noise : Noise
@export var structure_chance: float = 0.01
enum Blocks {
	STONE,
	DIAMOND,
	EMERALD,
	RUBY,
	CHEST,
	WOOD,
	HEALTHPACK,
	CHALICE
}
var ores : Dictionary = {
	Blocks.STONE: Vector2i(0,0),
	Blocks.DIAMOND: Vector2i(0, 1),
	Blocks.EMERALD: Vector2i(1, 1),
	Blocks.RUBY: Vector2i(2, 1),
	Blocks.CHEST: Vector2i(1,2),
	Blocks.WOOD: Vector2i(0,2),
	Blocks.CHALICE: Vector2i(2,3)
}

var replace_blocks : Dictionary = {
	Vector2i(0,3): preload("res://Scripts/Enemies/Mummy/mummy.tscn")
}
var chalice_scn = preload("res://Scenes/chalice_light.tscn")
var win_structure_idx: int = 4
var tile_set : TileSet
var structure_markers : Array[Vector2i] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_set = terrain_layer.tile_set
	Globals.world = self
	generate_level()


func generate_level():
	clear_game_objects()
	structure_markers.clear()
	terrain_layer.clear()
	print("Generating level")
	diamond_noise.seed = randi()
	other_noise.seed = randi()
	for i in range(level_size.x):
		for j in range(level_size.y + 64):
			var block = ores[Blocks.STONE]
			var sample_pos : Vector2 = Vector2(i,j) * 5.0
			if diamond_noise.get_noise_2d(sample_pos.x, sample_pos.y) > .3:
				block = ores[Blocks.DIAMOND]
			elif other_noise.get_noise_2d(sample_pos.x, sample_pos.y) > .3:
				block = ores[Blocks.EMERALD]
			terrain_layer.set_cell(Vector2i(i,j), 0, block)
	
	
	
	# Create walker
	var walker := get_start_point()
	
	for i in range(walker_count):
		walk_walker(walker, steps / walker_count, Vector2.ZERO, i > 0) # make a flat cave with structures
		walker = walk_walker(walker, steps / walker_count, Vector2(0, .05), false) # Move cave down
	
	# Place structures
	var used_structure_markers : Array[Vector2i] = [walker]
	for i in range(len(structure_markers)):
		var pos = structure_markers[i]
		var too_close = false
		for pos2 in used_structure_markers:
			if (pos2 - pos).length() < 32:
				too_close = true
				break
		if too_close:
			continue
		
		terrain_layer.set_pattern(pos, get_random_structure())
		
		used_structure_markers.append(pos)
	
	# Add win structure at the end of the walker
	terrain_layer.set_pattern(walker, tile_set.get_pattern(win_structure_idx))
	
	# Remove "air" blocks
	for i in range(level_size.x):
		for j in range(level_size.y + 64):
			var atlas_coords = terrain_layer.get_cell_atlas_coords(Vector2i(i,j))
			if atlas_coords == Vector2i(3,0):
				terrain_layer.erase_cell(Vector2i(i,j))
			elif atlas_coords in replace_blocks.keys():
				var scn = replace_blocks[atlas_coords].instantiate()
				scn.global_position = terrain_layer.map_to_local(Vector2i(i,j))
				add_game_object(scn)
				terrain_layer.erase_cell(Vector2i(i,j))
			elif atlas_coords == Vector2i(2,3): # Chalice!
				var chalice = chalice_scn.instantiate()
				chalice.global_position = terrain_layer.map_to_local(Vector2i(i,j))
				add_game_object(chalice)

func get_random_structure():
	var patterns = tile_set.get_patterns_count()
	var idx = randi() % patterns
	while idx == win_structure_idx:
		idx = randi() % patterns
	return tile_set.get_pattern(idx)

func get_start_point() -> Vector2i:
	return Vector2i(round(level_size.x/2), 16)

func walk_walker(walker : Vector2i, steps: int, direction_bias: Vector2 = Vector2.ZERO, leave_markers: bool = false) -> Vector2i:
	for i in range(steps):
		terrain_layer.erase_cell(walker)
		terrain_layer.erase_cell(walker + Vector2i(1, 0))
		terrain_layer.erase_cell(walker + Vector2i(1, 1))
		terrain_layer.erase_cell(walker + Vector2i(0, 1))
		walker.x += 1 if randf() < .5 + direction_bias.x else -1
		walker.y += 1 if randf() < .5 + direction_bias.y else -1
		
		walker.x = clamp(walker.x, 5, level_size.x - 5)
		walker.y = clamp(walker.y, 5, level_size.y - 5)
		
		if leave_markers:
			if randf() < structure_chance:
				structure_markers.append(walker)
		
	return walker



func is_terrain_at_position(pos: Vector2) -> bool:
	var pos_grid = world_pos_to_cell(pos)
	return terrain_layer.get_cell_source_id(pos_grid) != -1

func world_pos_to_cell(pos: Vector2) -> Vector2i:
	return terrain_layer.local_to_map(pos)

func break_tile_at_position(pos: Vector2) -> WorldGenerated.Blocks:
	if is_terrain_at_position(pos):
		var pos_grid = world_pos_to_cell(pos)
		var tile_atlas_pos = terrain_layer.get_cell_atlas_coords(pos_grid)
		var tile_type = ores.find_key(tile_atlas_pos)
		terrain_layer.erase_cell(pos_grid)
		if tile_type == null:
			return -1
		return tile_type
	return -1
@onready var game_objects: Node2D = $GameObjects

func add_game_object(obj: Node):
	game_objects.add_child(obj)

func clear_game_objects():
	for child in game_objects.get_children():
		child.queue_free()
