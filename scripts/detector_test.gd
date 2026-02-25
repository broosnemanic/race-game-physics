extends Node2D

@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	var t_detector: Dectector = Dectector.new(100.0, Color.GREEN)
	add_child(t_detector)
