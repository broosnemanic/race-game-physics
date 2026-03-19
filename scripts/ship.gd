extends RigidBody2D
class_name Ship

signal acc_selected(a_acc: Vector2)
signal detector_position_changed()

@onready var ship_sprite: Sprite2D = $ShipSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var arrow: Arrow					# Points to next location
var base_arrow: Arrow				# Points to next location with physic prediction
#var trace: BounceTrace				# Points to next location with bounces
var velocity_saved: Vector2			# Stores velocity when freeze == true
var velocity_saved_saved: Vector2	# Stores velocity when selecting new acc when freeze == true
var detector: Dectector				# For setting accelaration
var player: int:					# Index of player
	set(a_player):
		player = a_player
		ship_sprite.texture = Constants.SHIP_TEXTURES[a_player]
var line: Line2D
var current_acc: Vector2 = Vector2.ZERO
#var velocity_saved: Vector2:
	#set(a_velocity):
		#velocity_saved = a_velocity
		#if player == 1:
			#prints(player, velocity_saved)


#
func _ready() -> void:
	add_to_group("ship")
	arrow = Arrow.new()
	add_child(arrow)
	arrow.visible = false
	base_arrow = Arrow.new()
	add_child(base_arrow)
	base_arrow.set_color(Color(0.0, 1.0, 0.0, 0.5)) 
	arrow.visible = true
	line = Line2D.new()
	line.width = 7.0
	add_child(line)
	ship_sprite.scale = 0.125 * Vector2.ONE

	contact_monitor = true
	max_contacts_reported = 3
	body_entered.connect(on_body_entered)
	detector = Dectector.new(Constants.DEFAULT_ACC, Color.GREEN)
	detector.point_selected.connect(on_acc_selected)
	detector.mouse_moved.connect(on_detector_pos_change)
	add_child(detector)
	detector.visible = false
	detector.is_active = false


#
func _process(_delta: float) -> void:
	if not detector.is_active: return
	#arrow.point_at_position(velocity_saved)
	arrow.point_at_position(velocity_saved_saved)


func on_body_entered(_a_body: Node) -> void:
	velocity_saved = linear_velocity
	arrow.point_at_position(velocity_saved)
	#trace.go(velocity_saved, velocity_saved.length())


#
func on_acc_selected(a_acc: Vector2) -> void:
	velocity_saved = velocity_saved_saved + a_acc
	current_acc = a_acc
	acc_selected.emit(a_acc)


#
func on_detector_pos_change(a_pos: Vector2) -> void:
	velocity_saved = velocity_saved_saved + a_pos
	set_sprite_rotation(a_pos)
	detector_position_changed.emit()


#
func set_sprite_rotation(a_acc: Vector2) -> void:
	var t_rot: float = ship_sprite.rotation
	t_rot = a_acc.angle()
	ship_sprite.rotation = t_rot



# Process turn for this ship 
func go(a_is_go: bool) -> void:
	set_frozen(not a_is_go)
	show_detector(not a_is_go)
	if a_is_go:
		linear_velocity = velocity_saved
	else:
		velocity_saved_saved = velocity_saved


#
func show_detector(a_is_show: bool) -> void:
	detector.visible = a_is_show
	#detector.position = velocity_saved


#
func set_detector_active(a_is_active: bool) -> void:
	detector.is_active = a_is_active


#
func set_frozen(a_is_frozen: bool) -> void:
	# Preserve velocity value
	if not freeze:
		velocity_saved = linear_velocity
	freeze = a_is_frozen
	if not freeze:
		linear_velocity = velocity_saved


func add_line_point(a_global_point: Vector2) -> void:
	var t_point: Vector2 = to_local(a_global_point)
	line.add_point(t_point)


#
func set_saved_velocity(a_velocity: Vector2) -> void:
	velocity_saved_saved = a_velocity
	velocity_saved = velocity_saved_saved
	
	
	
