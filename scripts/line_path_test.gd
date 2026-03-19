extends Node2D

@onready var dot: Sprite2D = $Arrow/Dot
@onready var arrow: Arrow = $Arrow

var progress: float = 0.0

const POINTS: Array[Vector2] = [Vector2.ZERO,
								Vector2(100.0, 0),
								Vector2(100.0, 100),
								Vector2(120.0, 130.0),
								Vector2(140.0, 160.0),
								Vector2(160.0, 190.0),
								]
#const POINTS: Array[Vector2] = [Vector2.ZERO,
								#Vector2(100.0, 0),
								#Vector2(100.0, 100),
								#Vector2(120.0, 130.0),
								#Vector2(140.0, 160.0),
								#Vector2(160.0, 190.0),
								#]
var circle_points: Array[Vector2]
var spiral_points: Array[Vector2]
var random_line: Array[Vector2]
var start_points: Array[Vector2]
var point_sets: Array[Array] = []


func _ready() -> void:
	dot.scale = 2.5 * Vector2.ONE
	dot.modulate = Color.GREEN
	setup_pointsets()
	cylcle_pointsets()


#
func cylcle_pointsets() -> void:
	for i_points: Array[Vector2] in point_sets:
		arrow.morph_to(i_points, arrow.MORPH_DURATION)
		await get_tree().create_timer(arrow.MORPH_DURATION + 0.5).timeout
	cylcle_pointsets()





func _process(_delta: float) -> void:
	return
	progress = sin(Time.get_ticks_msec() as float / 1000.0)
	progress = 0.5 * (progress + 1.0)
	dot.position = arrow.coords_from_path_position(progress, arrow.points)


#
func setup_circle() -> void:
	circle_points = []
	var t_slice_size: float = 2.0 * PI / 20.0
	for i_index: int in range(21):
		var t_index: float = i_index as float * t_slice_size
		var t_point: Vector2 = 200.0 * Vector2(cos(t_index), sin(t_index))
		circle_points.append(t_point)


#
func setup_spiral() -> void:
	spiral_points = []
	var t_slice_size: float = 2.0 * PI / 20.0
	for i_index: int in range(21):
		var t_index: float = i_index as float * t_slice_size
		var t_point: Vector2 = (i_index as float / 21.0) * 200.0  * Vector2(cos(t_index), sin(t_index))
		spiral_points.append(t_point)


#
func setup_random_line() -> void:
	random_line = [Vector2.ZERO]
	var t_offset: Vector2 = Vector2(20.0, 0.0)
	for i_index: int in range(20):
		var t_x: float = 1.0 - 2.0 * randf()
		t_x *= 20.0
		var t_y: float = 1.0 - 2.0 * randf()
		t_y *= 20.0
		var t_point: Vector2 = Vector2(t_x, t_y) + t_offset + random_line[-1]
		random_line.append(t_point)


#
func setup_start_points() -> void:
	start_points = []
	for i_vec: Vector2 in arrow.points:
		start_points.append(i_vec)



#
func setup_pointsets() -> void:
	setup_circle()
	setup_spiral()
	setup_random_line()
	setup_start_points()
	point_sets.append(circle_points)
	point_sets.append(spiral_points)
	point_sets.append(random_line)
	point_sets.append(start_points)
