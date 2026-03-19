extends Line2D
class_name Arrow

## 2D line with arrowhead and some utility functions ##


var head: ArrowHead				# Triangle which points in direction of last segment
var head_factor: float = 4.0	# Scale factor of head size vs line width

const MORPH_DURATION: float = 1.0

# Default appearance
func _ready() -> void:
	#points = [Vector2.ZERO, Vector2(100.0, 100.0)]
	self_modulate = Color.RED
	width = 5
	setup_arrowhead()


# Only call after _ready (or `head` will be null)
func set_color(a_color: Color) -> void:
	modulate = a_color
	head.color = a_color


# Calls `Line2D.add_point` and also moves and aligns `head`
func add_path_point(a_point: Vector2) -> void:
	points.append(a_point)
	head.position = a_point
	align_arrowhead()


# Calls `Line2D.set_points` and also moves and aligns `head`
func set_path(a_points: Array[Vector2]) -> void:
	points = a_points
	align_arrowhead()


# Move last point to `a_pos` and align `head`
func point_at_position(a_pos: Vector2) -> void:
	if points.is_empty(): return
	points[-1] = a_pos
	align_arrowhead()


# Set `head` rotation to align with direction of last segment
# Ensure `head` is at position of last point
func align_arrowhead() -> void:
	if points.size() < 2: return
	head.position = points[-1]
	head.point_along_coords(points[-2], points[-1])


# Default arrowhead appearance
func setup_arrowhead() -> void:
	head = ArrowHead.new()
	head.width = head_factor * width
	head.height = head_factor * width
	head.offset = Vector2(0.0, head.height)
	add_child(head)
	align_arrowhead()



# Move points (merge and create new points as needed) to match `a_points`
func morph_to(a_points: Array[Vector2], a_duration: float) -> void:
	var t_path_pos: Array[float] = path_positions(points)
	t_path_pos.append_array(path_positions(a_points))
	t_path_pos.sort()
	t_path_pos = unique_float_array(t_path_pos)
	var t_start_points: Array[Vector2] = []
	var t_target_points: Array[Vector2] = []
	for i_pos: float in t_path_pos:
		var t_point: Vector2 = coords_from_path_position(i_pos, points)
		t_start_points.append(t_point)
		t_point = coords_from_path_position(i_pos, a_points)
		t_target_points.append(t_point)
	points = t_start_points
	for i_index: int in range(t_path_pos.size()):
		var t_tween: Tween = create_tween()
		t_tween.tween_method(update_point.bind(i_index), points[i_index], t_target_points[i_index], a_duration)
	get_tree().create_timer(a_duration + 0.1).timeout.connect(func(): points = a_points)


# Target for tween_method
func update_point(a_value: Vector2, a_index: float) -> void:
	points[a_index] = a_value
	if a_index == points.size() - 1:
		align_arrowhead()


# Returns sorted copy of `a_floats` with duplicates removed
func unique_float_array (a_floats: Array[float]) -> Array[float]:
	var t_dict: Dictionary[float, float]
	var t_array: Array[float] = []
	for i_float: float in a_floats:
		t_dict[i_float] = i_float
	for i_float: float in t_dict.keys():
		t_array.append(i_float)
	t_array.sort()
	return t_array


# Returns array of size `a_size` with start and end points from `a_points`
# Note this is a utility func for `morph_to`
func stretched_points(a_points: Array[Vector2], a_size: int) -> Array[Vector2]:
	var t_points: Array[Vector2] = []
	t_points.resize(a_size)
	t_points[0] = a_points[0]
	t_points[-1] = a_points[-1]
	return t_points


# Normalized distance along path traced by `a_points` to point at `a_index`
func path_position(a_points: Array[Vector2], a_index: int) -> float:
	var t_total: float = length_to(a_points, a_points.size() - 1)
	var t_target: float = length_to(a_points, a_index)
	return t_target / t_total


# Path distance from start of line to point at `a_index`
func length_to(a_points: Array[Vector2], a_index: int) -> float:
	var t_total: float = 0.0
	for i_index: int in range(1, a_index + 1):
		var t_vec: Vector2 = a_points[i_index] - a_points[i_index - 1]
		var t_length = t_vec.length()
		t_total += t_length
	return t_total


#
func total_length(a_points: Array[Vector2]) -> float:
	return length_to(a_points, a_points.size() - 1)


# Value at i in returned array = fraction of total length at `a_points[i]`
func path_positions(a_points: Array[Vector2]) -> Array[float]:
	var t_positions: Array[float] = []
	t_positions.resize(a_points.size())
	t_positions[0] = 0.0
	t_positions[-1] = 1.0
	for i_index: int in range(1, a_points.size() - 1):
		t_positions[i_index] = path_position(a_points, i_index)
	return t_positions


# New point on existing segment at distance `a_path_pos`
func coords_from_path_position(a_path_pos: float, a_points: Array[Vector2]) -> Vector2:
	var t_positions: Array[float] = path_positions(a_points)
	var t_length: float = 0.0
	var t_vec: Vector2
	var t_start_index: int = - 1
	for i_index: int in range(0, t_positions.size() - 1):
		if is_between(t_positions[i_index], t_positions[i_index + 1], a_path_pos):
			t_start_index = i_index
			break
	if t_start_index < 0: return Vector2.ZERO
	t_length = a_path_pos * total_length(a_points)				# Path distance to target point
	t_length = t_length - length_to(a_points, t_start_index)	# Path distance from start of segment to target point
	t_vec = a_points[t_start_index + 1] - a_points[t_start_index]
	t_vec = t_length * t_vec.normalized()
	t_vec += a_points[t_start_index]
	if t_vec == Vector2.ZERO:
		pass
	return t_vec


# Closed, closed interval
func is_between(a_start: float, a_end: float, a_value: float) -> bool:
	if a_value < a_start: return false
	if a_value > a_end: return false
	return true
