extends Node2D

@onready var ship: Ship
@onready var camera_2d: Camera2D = $Camera2D


var is_paused: bool = true
var ships: Array[Ship] = []
var turn_order: Array[int] = []						# List of players in movement order
var active_player: int								# Player to move
var current_ghost: Ghost							# To ensure only one exists at a time

const SHIP_COUNT: int = 1
const DOT: Texture2D = preload("uid://bfx53rcnq1uik")


#
#func _input(event: InputEvent) -> void:
	#return
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#set_all_ships_go(true)
		#elif event.button_index == MOUSE_BUTTON_RIGHT:
			#set_all_ships_go(false)



#
func _ready() -> void:
	Engine.time_scale = 1.0
	var t_size: Vector2 = get_viewport_rect().size
	setup_borders(t_size)
	for i_index: int in range(SHIP_COUNT):
		add_ship(i_index)
		#ships[i_index].go(true)
	camera_2d.offset = 0.5 * t_size
	await get_tree().create_timer(1.0).timeout
	start_turn()


func add_ship(a_player: int) -> void:
	var t_ship: Ship = Constants.SHIP_PREFAB.instantiate()
	add_child(t_ship)
	t_ship.player = a_player
	t_ship.position = start_position(a_player)
	print_debug(t_ship.position)
	t_ship.set_frozen(true)
	ships.append(t_ship)
	turn_order.append(a_player)


#func new_ghost(a_ship: Ship)


#
func start_position(a_player: int) -> Vector2:
	var t_size: Vector2 = get_viewport_rect().size
	return 0.5 * t_size + Vector2(200.0 * a_player as float, 0.0)


#
func start_turn() -> void:
	# Ships should start inactive
	for i_player: int in turn_order:
		var t_ship: Ship = ships[i_player]
		t_ship.show_detector(true)
		t_ship.set_detector_active(true)
		#t_ship.detector.octant_changed.connect(create_ghost.bind(t_ship))
		t_ship.detector_position_changed.connect(create_ghost.bind(t_ship))
		t_ship.acc_selected.connect(mark_ship_destination.bind(t_ship))
		await t_ship.acc_selected
		t_ship.acc_selected.disconnect(mark_ship_destination)
		t_ship.detector_position_changed.disconnect(create_ghost)
		t_ship.show_detector(false)
		t_ship.set_detector_active(false)
		if not t_ship.player == turn_order[turn_order.size() - 1]:
			await get_tree().create_timer(0.5).timeout	# To prevent click being doulbe-counted
	for i_ship: Ship in ships:
		i_ship.go(true)
	await get_tree().create_timer(Constants.TURN_DURATION).timeout
	for i_ship: Ship in ships:
		i_ship.go(false)
	# Do actions that happen between turns
	# Or just call start_turn()
	start_turn()



func create_ghost(a_ship: Ship) -> void:
	if current_ghost == null:
		a_ship.line.clear_points()
		a_ship.line.add_point(Vector2.ZERO)
		current_ghost = Ghost.new(a_ship)
		current_ghost.bounce_registered.connect(a_ship.add_line_point)
		current_ghost.lifetime_completed.connect(a_ship.add_line_point)
		add_child(current_ghost)
		current_ghost.go(true)


#
func set_all_ships_go(a_is_go: bool) -> void:
	for i_ship: Ship in ships:
		i_ship.go(a_is_go)



func place_dot(a_position: Vector2) -> void:
	var t_sprite: Sprite2D = Sprite2D.new()
	add_child(t_sprite)
	t_sprite.texture = DOT
	t_sprite.modulate = Color.RED
	t_sprite.global_position = a_position
	t_sprite.z_index = 100
	t_sprite.scale = 5.0 * Vector2.ONE
	var t_tween: Tween = get_tree().create_tween()
	t_tween.tween_property(t_sprite, "modulate", Color(1.0, 0.0, 0.0, 0.0), 5.0)
	get_tree().create_timer(5.0).timeout.connect(t_sprite.queue_free)



func mark_ship_destination(_a_acc: Vector2,  a_ship: Ship) -> void:
	var t_point: Vector2 = a_ship.line.points[-1]
	t_point = a_ship.to_global(t_point)
	place_dot(t_point)



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
	t_collider.set_collision_layer_value(2, true)
	t_collider.set_collision_mask_value(2, true)
