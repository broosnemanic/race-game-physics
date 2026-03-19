extends RefCounted
class_name BigBool

## Array of bools with signals to report changes

signal bool_updated(a_index: int, a_value: bool)
signal bool_changed(a_index: int, a_value: bool)
signal all_bools_match(a_bool: bool)				# Only triggered when a bool changes


var bools: Array[bool]

#
func _init(a_count: int) -> void:
	bools = []
	bools.resize(a_count)


# Set value and trigger signals
func set_bool(a_index: int, a_value: bool) -> void:
	var t_is_changed: bool = bools[a_index] != a_value
	bools[a_index] = a_value
	bool_updated.emit(a_index, a_value)
	if t_is_changed:
		bool_changed.emit(a_index, a_value)
		if is_all_bools_match():
			all_bools_match.emit(bools[0])


# As it says
func is_all_bools_match() -> bool:
	var t_key: bool = bools[0]
	for i_bool: bool in bools:
		if i_bool != t_key:
			return false
	return true
