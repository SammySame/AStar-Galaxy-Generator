extends AStar2D

var _max_distance:float = 600.0
var _close_distance:float = 350.0
var _previous_amount:int = 3
var _max_stray_galaxies:int = 6
var _max_connections:int = 4

var _constellations:Array[Array] = []
# Key - astar2D id number
# Value - array with first value as origin point
# and the rest as points connecting to it
# might use something more sophisticated later on :D
var _connection_map:Dictionary = {}

func _init(galaxies:Array[Node2D]):
	var Galaxy_Group := load("res://resources/galaxy_group_data.gd")
	var galaxy_group := Galaxy_Group.new() as GalaxyGroupData
	for i in galaxies.size():
		var galaxy := galaxies[i]
		add_point(i, galaxy.position)
		galaxy_group.id_map[i] = galaxy
	Globals.current_galaxy_group = galaxy_group
	_create_connections()

func get_largest_constelation() -> Array[int]:
	if not _constellations.is_empty():
		return _get_largest()
	_get_all_constelations()
	return _get_largest()

func get_all_connections() -> Dictionary:
	if not _connection_map.is_empty():
		return _connection_map
	var point_ids := get_point_ids()
	for i in get_point_count():
		var point := point_ids[i]
		var start_pos := get_point_position(point)
		var vector_container:Array[Vector2] = []
		vector_container.append(start_pos)
		for end_id in get_point_connections(point):
			var end_pos := get_point_position(end_id)
			vector_container.append(end_pos)
			_connection_map[point] = vector_container
	return _connection_map

func _create_connections() -> void:
	var stray_galaxies:Array[int]
	stray_galaxies.append_array(get_point_ids())
	# Creates connection paths
	# can be multiple at a time
	# if lots of stray galaxies loop
	while true:
		var no_connections := _connect_paths(stray_galaxies)
		_enable_all_points()
		if no_connections:
			break
		stray_galaxies = _get_stray()
		if stray_galaxies.size() < _max_stray_galaxies:
			break
	# Connects stray galaxies
	if stray_galaxies.size() > 0:
		_connect_stray(stray_galaxies)
	# Makes connections with close enough points
	_connect_close()

func _connect_paths(points:Array[int]) -> bool:
	var start_point := points[randi() % points.size()]
	var previous_points:Array[int] = []
	var cycles:int = 0  #safety check for infinite loop
	while true:
		previous_points.append(start_point)
		var target_point = _get_next_in_path(start_point)
		if target_point == -1:
			if cycles == 0:
				return true
			break
		
		var start_pos := get_point_position(start_point)
		var target_pos := get_point_position(target_point)
		var dist := start_pos.distance_to(target_pos)
		var distances:Dictionary = {}
		distances[start_point] = dist
		for i in range(0, _previous_amount):
			var prev_index := previous_points.size() - 1 - i
			if prev_index < 0:
				break
			var prev_point := previous_points[prev_index]
			var prev_dist := get_point_position(prev_point).distance_to(target_pos)
			distances[prev_point] = prev_dist
		
		if distances.values().any(func(num): return num > _max_distance):
			if cycles == 0:
				return true
			break
		@warning_ignore("static_called_on_instance")
		var closest_point := _get_smallest_value(distances)
		connect_points(closest_point, target_point)
		start_point = target_point
		cycles += 1
	return false

func _connect_stray(points:Array[int]) -> void:
	for point in points:
		set_point_disabled(point, true)
		var point_pos := get_point_position(point)
		var closest_point := get_closest_point(point_pos)
		set_point_disabled(point, false)
		connect_points(point, closest_point)

func _connect_close() -> void:
	var point_ids := get_point_ids()
	for i in get_point_count():
		var rand_index := randi() % point_ids.size()
		var point := point_ids[rand_index]
		if get_point_connections(point).size() >= _max_connections:
			continue
		
		var ignored_points := get_point_connections(point)
		for j in ignored_points.size():
			var ign_point := ignored_points[j]
			ignored_points.append_array(get_point_connections(ign_point))
		@warning_ignore("static_called_on_instance")
		ignored_points = _remove_duplicates(ignored_points)
		_disable_points(ignored_points)
		
		var point_pos := get_point_position(point)
		for _i in _max_connections:
			var close_point := get_closest_point(point_pos)
			if close_point == -1:
				break
			var close_point_pos := get_point_position(close_point)
			if point_pos.distance_to(close_point_pos) > _close_distance:
				break
			if get_point_connections(point).size() >= _max_connections:
				continue
			if get_point_connections(close_point).size() >= _max_connections:
				continue
			connect_points(point, close_point)
			set_point_disabled(close_point)
			ignored_points.append(close_point)
		_disable_points(ignored_points, false)

func _get_next_in_path(point) -> int:
	var next_point := -1
	var point_pos := get_point_position(point)
	set_point_disabled(point)
	next_point = get_closest_point(point_pos)
	return next_point

func _get_stray() -> Array[int]:
	var arr:Array[int] = []
	for point in get_point_ids():
		if get_point_connections(point).size() == 0:
			arr.append(point)
	return arr

func _enable_all_points() -> void:
	for point in get_point_ids():
		set_point_disabled(point, false)

func _disable_points(points:PackedInt64Array, disabled := true) -> void:
	for point in points:
		set_point_disabled(point, disabled)

func _get_largest() -> Array[int]:
	var size := 0
	var largest:Array[int] = []
	for c in _constellations:
		if c.size() > size:
			largest = c
			size = c.size()
	return largest

func _get_all_constelations() -> void:
	var used_points:Array[int] = []
	for point in get_point_ids():
		if used_points.has(point):
			continue
		var constelation:Array[int] = []
		_get_constelation(constelation, point)
		used_points.append_array(constelation)
		_constellations.append(constelation)

func _get_constelation(group:Array[int], id:int) -> void:
	group.append(id)
	var point_connections := get_point_connections(id)
	for point in point_connections:
		if group.has(point):
			continue
		_get_constelation(group, point)


static func _get_smallest_value(dict:Dictionary) -> int:
	var id:int = -1
	var smallest:float = INF
	for key in dict:
		var value:float = dict[key]
		if value < smallest:
			smallest = value
			id = key
	return id

static func _remove_duplicates(array:Array) -> Array[int]:
	var no_duplicates:Array[int] = []
	for i in array:
		if not no_duplicates.has(i):
			no_duplicates.append(i)
	return no_duplicates
