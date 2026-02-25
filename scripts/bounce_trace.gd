extends Line2D
class_name BounceTrace

var head: ArrowHead
var is_tracing: bool
var initial_target: Vector2 = Vector2.ZERO		# This is in local coords
var length: float						# Total distance to cast
const MAX_BOUNCES: int = 5
const EPSILON: float = 0.1


func _ready() -> void:
	width = 5.0


func _physics_process(_delta: float) -> void:
	if is_tracing:
		var t_remaining_distance = length
		var t_bounce_count: int = 0
		var t_points: Array[Vector2] = [Vector2.ZERO]
		var t_target: Vector2 = initial_target
		while t_remaining_distance > 0.0 and t_bounce_count <= MAX_BOUNCES:
			var t_ray: RayCast2D = RayCast2D.new()
			t_ray.collide_with_areas = true
			add_child(t_ray)
			t_ray.position = t_points.back()
			t_ray.target_position = t_target
			t_ray.position += epsilon_vector(t_ray.position, t_ray.target_position)
			t_ray.force_raycast_update()
			if t_ray.is_colliding():
				var t_hit_point: Vector2 = to_local(t_ray.get_collision_point())
				t_points.append(t_hit_point)
				var t_normal: Vector2 = t_ray.get_collision_normal()
				var t_vector: Vector2 = t_hit_point - t_ray.position
				var t_bounce_dir: Vector2 = t_vector.bounce(t_normal).normalized()
				var t_len: float = t_vector.length()
				t_len = minf(t_len, t_remaining_distance)
				t_remaining_distance -= t_len
				t_target = t_remaining_distance * t_bounce_dir.normalized()
				t_bounce_count += 1
				t_ray.queue_free()
			else:
				t_points.append(t_remaining_distance * t_target.normalized())
				print(t_points)
				t_ray.queue_free()
				break
		clear_points()
		for i_index: int in range(t_points.size()):
			t_points[i_index] = t_points[i_index]
		points = t_points
		is_tracing = false


# Small vector in direction described by start and end
func epsilon_vector(a_start: Vector2, a_end: Vector2) -> Vector2:
	var t_vector: Vector2 = a_end - a_start
	t_vector = t_vector.normalized()
	t_vector *= EPSILON
	return t_vector

func go(a_direction: Vector2, a_length: float) -> void:
	length = a_length
	initial_target = length * a_direction.normalized()
	is_tracing = true


func setup_arrowhead() -> void:
	head = ArrowHead.new()
	head.width = 20.0
	head.height = 20.0
	head.offset = Vector2(0.0, 20.0)
	add_child(head)
