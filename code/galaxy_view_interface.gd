extends Node2D

@export_group("References")
@export_file("*.tscn") var _galaxy_path:String
@export var _connections:Node2D
@export_group("Generator Settings")
@export_range(0, 200, 1) var _galaxy_quantity := 30
@export_range(0, 10, 1) var _galaxies_per_row := 5
@export_range(0, 1, 0.01) var _position_randomness := 0.15
# How much to enlarge the galaxy bounding box for the overlap check
@export_range(1, 50, 1) var _inflate_bounding_box:float = 8.0

var _Galaxy_connector := preload("res://scenes/navigation_menu/galaxy_group_view/generation/galaxy_connector.gd")
var _astar:AStar2D

func generate(amount:int, per_row:int, pos_rand:float, inflate:float) -> void:
	_galaxy_quantity = amount
	_galaxies_per_row = per_row
	_position_randomness = pos_rand
	_inflate_bounding_box = inflate
	
	for child in _connections.get_children():
		child.free()
	for child in get_children():
		child.free()
	_astar = null
	_create_galaxy_group()
	_remove_out_of_screen()
	_remove_overlaps()
	_create_connections()
	show_all_connections()

func check_connection(start_id:int, end_id:int) -> bool:
	return _astar.are_points_connected(start_id, end_id)

func get_point_connections(id:int) -> PackedInt64Array:
	return _astar.get_point_connections(id)

func get_point_position(id:int) -> Vector2:
	return _astar.get_point_position(id)

func get_point_at_position(pos:Vector2) -> int:
	return _astar.get_closest_point(pos)

func get_path_to_point(start_id:int, end_id:int) -> PackedVector2Array:
	clear_path()
	var path := _astar.get_point_path(start_id, end_id)
	for i in range(0, path.size() - 1): # last point is excluded
		var start_pos := path[i]
		var end_pos := path[i+1]
		_create_line(start_pos, end_pos)
	return path

func clear_path() -> void:
	for child in _connections.get_children():
		child.free()

func get_largest_constelation() -> Array[int]:
	return _astar.get_largest_constelation()

func show_all_connections() -> void:
	var connection_map:Dictionary = _astar.get_all_connections()
	for key in connection_map:
		var positions:Array[Vector2] = connection_map[key]
		var origin_pos := positions[0]
		for i in range(1, positions.size()): #Ignore origin point(0)
			var end_pos := positions[i]
			_create_line(origin_pos, end_pos)

func _create_galaxy_group() -> void:
	var rng := RandomNumberGenerator.new()
	var Galaxy := load(_galaxy_path)
	var grid := _create_grid()
	for column in grid.columns:
		for row in grid.rows:
			var galaxy:Node2D = Galaxy.instantiate()
			galaxy.position = Vector2(grid.x * column + grid.x / 2, grid.y * row + grid.y / 2)
			galaxy.position += Vector2(rng.randi_range(-1000, 1000) * _position_randomness, 
										rng.randi_range(-1000, 1000) * _position_randomness)
			add_child(galaxy)
			galaxy.update_rect(_inflate_bounding_box)

func _create_grid() -> Dictionary:
	var rect_size = get_viewport_rect().size
	@warning_ignore("integer_division")
	var row_amount := _galaxy_quantity / _galaxies_per_row
	var grid_info := {}
	@warning_ignore("integer_division")
	grid_info.columns = _galaxy_quantity / row_amount
	grid_info.rows = row_amount
	grid_info.x = rect_size.x / grid_info.columns
	grid_info.y = rect_size.y / grid_info.rows
	return grid_info

func _remove_out_of_screen() -> void:
	var viewport := get_viewport_rect()
	for child in get_children():
		if not viewport.encloses(child.rect):
			child.free()

func _remove_overlaps() -> void:
	var children:Array = get_children()
	children.shuffle()
	var children_to_delete:Array = []
	for i in get_child_count():
		var child:Node2D = get_child(i)
		for j in children:
			if child == j or children_to_delete.has(j):
				continue
			if child.rect.intersects(j.rect):
				children_to_delete.append(child)
				break
	for child in children_to_delete:
		child.free()

func _create_connections() -> void:
	var galaxies:Array[Node2D] = []
	for i in get_child_count():
		var galaxy:Node2D = get_child(i)
		galaxies.append(galaxy)
	_astar = _Galaxy_connector.new(galaxies)

func _create_line(start:Vector2, end:Vector2) -> void:
	var line := Line2D.new()
	line.set_default_color(Color.hex(0x66c6e78d))
	line.set_width(7)
	line.add_point(start)
	line.add_point(end)
	_connections.add_child(line)
