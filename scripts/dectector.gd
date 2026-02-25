extends Area2D
class_name Dectector

signal mouse_moved(a_position: Vector2)
signal octant_changed(a_position: Vector2)
signal point_selected(a_point: Vector2)

var arrow: Arrow
var shape: CollisionShape2D
var is_mouse: bool		# Is mouse pointer over this?
var radius: float		# Radius of detection and visible area
var color: Color
var point: Vector2
var is_active: bool		# Should this react to mouse actions?

const ZERO_RADIUS: float = 25.0
const SQRT2_2: float = 0.5 * sqrt(2.0)
const OCTANTS: Array[Vector2] = [Vector2(1.0, 0.0),
								Vector2(SQRT2_2, SQRT2_2),
								Vector2(0.0, 1.0),
								Vector2(-SQRT2_2, SQRT2_2),
								Vector2(-1.0, 0.0),
								Vector2(-SQRT2_2, -SQRT2_2),
								Vector2(0.0, -1.0),
								Vector2(SQRT2_2,  -SQRT2_2)]

#
func _init(a_radius: float, a_color: Color) -> void:
	radius = a_radius
	color = a_color
	arrow = Arrow.new()
	add_child(arrow)


#
func _ready() -> void:
	shape = CollisionShape2D.new()
	add_child(shape)
	shape.shape = CircleShape2D.new()
	set_radius(radius)
	mouse_entered.connect(func(): is_mouse = true)
	mouse_exited.connect(func(): is_mouse = false)



#
func _input(event: InputEvent) -> void:
	#if not is_mouse: return
	if not is_active: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		point_selected.emit(point)
		is_active = false


#
func _process(_delta: float) -> void:
	if is_active:
		#point = point_truncated_to_radius(get_local_mouse_position())
		var t_mouse_pos: Vector2 = get_local_mouse_position()
		var t_point: Vector2
		if t_mouse_pos.length() <= ZERO_RADIUS:
			t_point = Vector2.ZERO
		else:
			t_point = radius * point_restricted_to_octant(get_local_mouse_position())
		if t_point != point:
			point = t_point
			arrow.point_at_position(point)
			octant_changed.emit(point)
			mouse_moved.emit(point)


# Returns a_point if inside radius, else point on radius that intersects line to a_point
func point_truncated_to_radius(a_point: Vector2) -> Vector2:
	var t_length: float = a_point.length()
	if t_length <= radius:
		return a_point
	else:
		var t_point: Vector2 = pow(t_length, -1.0) * a_point
		t_point *= radius
		return t_point


#
func point_restricted_to_octant(a_point: Vector2) -> Vector2:
	var t_angle: float = a_point.angle()
	t_angle = positive_angle(t_angle)
	return octant_from_angle(t_angle)


#
func positive_angle(a_angle: float) -> float:
	var t_angle: float = a_angle
	while t_angle < 0.0:
		t_angle += 2.0 * PI
	return t_angle



#
func octant_from_angle(a_angle: float) -> Vector2:
	var t_PI8: float = PI / 8.0
	var t_angle: float = 0.0
	for i_index: int in range(8):
		if is_between(t_angle - t_PI8, t_angle + t_PI8, a_angle):
			return OCTANTS[i_index]
		t_angle += PI / 4.0
	return OCTANTS[0]


#
func is_between(a_start: float, a_end: float, a_value: float) -> bool:
	if a_value < a_start: return false
	if a_value >= a_end: return false
	return true

#
func set_radius(a_radius: float) -> void:
	radius = a_radius
	var t_circle: CircleShape2D = shape.shape
	t_circle.radius = radius


#
func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color, false, 2.0, true)
	draw_circle(Vector2.ZERO, 2.0, color, true)
