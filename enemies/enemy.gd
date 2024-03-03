extends CharacterBody2D

const speed: int = 2000
var current_path_index: int = 0
var current_path_point: Vector2
var movement_paused: bool = false
var path_to_follow

@onready var map: TileMap = get_node("../TileMap")
@onready var astargrid: AStarGrid2D = map.astargrid
@onready var grid_cell_size = astargrid.cell_size
@onready var pause_timer = $Timer

func _ready():
	set_target_to_clean_tile()

func _on_timer_timeout():
	resume_movement()

func _physics_process(delta) -> void:	
	if movement_paused == true:
		return

	#$Label.text = str(current_path_index)
	if path_to_follow.is_empty():
		set_target_to_clean_tile()
		return
	
	if current_path_point == Vector2():
		current_path_point = path_to_follow[current_path_index]
	
	var direction: Vector2 = (current_path_point - global_position).normalized()
	
	if reached_current_path_point(current_path_point):
		map.make_tile_rusty(global_to_grid_position(global_position))
		pause_movement()
		current_path_index += 1
		
		if reached_destination():
			pause_movement(1.0)
			path_to_follow = []
			current_path_index = 0
			current_path_point = Vector2()
			return
		
		current_path_point = path_to_follow[current_path_index]
		return
			
	velocity = direction * speed * delta
	move_and_slide()

func reached_current_path_point(path_point) -> bool:
	return global_transform.origin.distance_to(path_point) <= 0.5

func reached_destination():
	return current_path_index >= path_to_follow.size()

func pause_movement(wait_time: float = 0.2) -> void:	
	movement_paused = true
	
	pause_timer.wait_time = wait_time
	pause_timer.start()

func resume_movement():
	movement_paused = false
	
func set_target_to_clean_tile():
	var target = map.get_a_random_clean_tile()
	
	path_to_follow = astargrid.get_point_path(
		global_to_grid_position(global_position),
		target)

	for i in range(path_to_follow.size()):
		path_to_follow[i].x += grid_cell_size.x/2
		path_to_follow[i].y += grid_cell_size.y/2

func global_to_grid_position(globalpos: Vector2) -> Vector2i:
	# Subtract half the cell dimension (16/2 = 8), then divide by the cell dimension
	var x = ceil(globalpos.x - (grid_cell_size.x/2))/grid_cell_size.x
	var y = ceil(globalpos.y - (grid_cell_size.y/2))/grid_cell_size.y
	
	return Vector2i(x,y)
