extends Line2D
class_name Arrow

var head: ArrowHead


func _ready() -> void:
	points = [Vector2.ZERO, Vector2.ZERO]
	modulate = Color.RED
	width = 5
	setup_arrowhead()


# 
func point_at_position(a_pos: Vector2) -> void:
	points[1] = a_pos
	head.position = a_pos
	head.point_along_coords(Vector2.ZERO, a_pos)


#
func setup_arrowhead() -> void:
	head = ArrowHead.new()
	head.width = 20.0
	head.height = 20.0
	head.offset = Vector2(0.0, 20.0)
	add_child(head)
