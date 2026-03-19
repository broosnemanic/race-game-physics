extends RigidBody2D
class_name Ghost

signal bounce_registered(a_position: Vector2)
signal lifetime_completed(a_position: Vector2)

var ship: Ship					# Ship this is a ghost of


#
func _init(a_ship: Ship) -> void:
	add_to_group("ghost")
	ship = a_ship
	physics_material_override = ship.physics_material_override.duplicate()
	var t_collider: CollisionShape2D = CollisionShape2D.new()
	t_collider.shape = a_ship.collision_shape_2d.shape.duplicate()
	add_child(t_collider)
	contact_monitor = true
	max_contacts_reported = 3
	body_entered.connect(on_body_entered)
	global_position = ship.global_position
	lock_rotation = true
	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)


#
func on_body_entered(_a_body: Node) -> void:
	if not (_a_body.is_in_group("ghost") or _a_body.is_in_group("ship")):
		bounce_registered.emit(global_position)


#
#func go(a_is_go: bool) -> void:
	#if a_is_go:
		#set_fast_physics(true)
		#linear_velocity = ship.velocity_saved
		#get_tree().create_timer(Constants.TURN_DURATION).timeout.connect(go.bind(false))
	#else:
		#lifetime_completed.emit(global_position)
		#freeze = true
		#set_fast_physics(false)
		#queue_free()
#
#
##
#func set_fast_physics(a_is_fast: bool) -> void:
	#if a_is_fast:
		#Engine.time_scale = Constants.PHYSICS_SIM_MULTIPLIER as float
		#Engine.physics_ticks_per_second = Constants.PHYSICS_SIM_MULTIPLIER * Constants.PHYSICS_TICKS_PER_SECOND_DEFAULT
	#else:
		#Engine.time_scale = 1.0
		#Engine.physics_ticks_per_second = Constants.PHYSICS_TICKS_PER_SECOND_DEFAULT



const FACTOR: float = 10.0
#
func go(a_is_go: bool) -> void:
	if a_is_go:
		set_fast_physics(true)
		linear_velocity = ship.velocity_saved * FACTOR
		get_tree().create_timer(Constants.TURN_DURATION / FACTOR).timeout.connect(go.bind(false))
	else:
		lifetime_completed.emit(global_position)
		freeze = true
		set_fast_physics(false)
		queue_free()


#
func set_fast_physics(a_is_fast: bool) -> void:
	if a_is_fast:
		#Engine.time_scale = Constants.PHYSICS_SIM_MULTIPLIER as float
		Engine.physics_ticks_per_second = floori(FACTOR * Constants.PHYSICS_TICKS_PER_SECOND_DEFAULT as float)
	else:
		Engine.time_scale = 1.0
		Engine.physics_ticks_per_second = Constants.PHYSICS_TICKS_PER_SECOND_DEFAULT
