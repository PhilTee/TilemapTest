extends TileMap

var astargrid: AStarGrid2D = AStarGrid2D.new()
var clean_tiles :Dictionary = {}

const main_layer = 0
const floor_source = 0
const wall_atlas_id = 2
const clean_atlas_coords = Vector2i(0,0)
const rusty_atlas_coords = Vector2i(1,0)

func _ready():
	setup_grid()

func setup_grid():
	var first_cell = get_used_cells(main_layer).front()
	var last_cell  = get_used_cells(main_layer).back()
	
	astargrid.region = Rect2i(first_cell.x, first_cell.y, last_cell.x+1, last_cell.y+1)
	astargrid.cell_size = Vector2i(16, 16)
	# No diagonal movements!
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	
	# Remove walls from navigable map, clean some floor tiles
	for cell in get_used_cells(main_layer):
		if is_wall(cell):
			astargrid.set_point_solid(cell, true)
		else:
			if randi_range(1, 5) % 2 == 0:
				make_tile_clean(cell)

func is_wall(cell) -> bool:
	return get_cell_atlas_coords(main_layer, cell).x == wall_atlas_id
	
func make_tile_rusty(cell: Vector2i) -> void:
	if clean_tiles.has(cell):
		clean_tiles.erase(cell)

	set_cell(main_layer, cell, floor_source, rusty_atlas_coords)
	
func make_tile_clean(cell: Vector2i) -> void:
	clean_tiles[cell] = null
	set_cell(main_layer, cell, floor_source, clean_atlas_coords)

func get_a_random_clean_tile() -> Vector2i:
	var keysArray = clean_tiles.keys()
	
	if keysArray.is_empty():
		return Vector2i()
	else:
		return keysArray[randi() % (keysArray.size())]
