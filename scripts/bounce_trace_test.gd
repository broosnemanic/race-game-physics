extends Node2D

@onready var bounce_trace: BounceTrace = $BounceTrace



func _ready() -> void:
	var t_size: Vector2 = get_viewport_rect().size
	setup_borders(t_size)
	bounce_trace.position = 0.5 * t_size


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var t_pos: Vector2 = get_global_mouse_position()
			t_pos = bounce_trace.to_local(t_pos)
			print(t_pos)
			bounce_trace.go(t_pos, 10000.0)


#region Setup
# As it says
func setup_borders(a_viewport_size: Vector2) -> void:
	var t_thickness: float = 10.0
	add_collider(Vector2(a_viewport_size.x, t_thickness), Vector2(0.5 * a_viewport_size.x, 0.5 * t_thickness))
	add_collider(Vector2(a_viewport_size.x, t_thickness), Vector2(0.5 * a_viewport_size.x, a_viewport_size.y + -0.5 * t_thickness))
	add_collider(Vector2(t_thickness, a_viewport_size.y), Vector2(0.5 * t_thickness, 0.5 * a_viewport_size.y))
	add_collider(Vector2(t_thickness, a_viewport_size.y), Vector2(-0.5 * t_thickness + a_viewport_size.x, 0.5 * a_viewport_size.y))


# As it says
func add_collider(a_size: Vector2, a_position: Vector2) -> void:
	var t_collider: StaticBody2D = StaticBody2D.new()
	var t_cshape: CollisionShape2D = CollisionShape2D.new()
	var t_shape: RectangleShape2D = RectangleShape2D.new()
	t_shape.size = a_size
	t_collider.add_child(t_cshape)
	t_cshape.shape = t_shape
	add_child(t_collider)
	t_collider.position = a_position
