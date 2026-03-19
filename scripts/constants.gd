extends Node

const TURN_DURATION: float = 1.0
const DEFAULT_ACC: float = 50.0
const PELLET_RAY_LENGTH: float = 1000.0
const SHIP_PREFAB = preload("uid://baeb4us65g8f3")
const PHYSICS_TICKS_PER_SECOND_DEFAULT: int = 60
const PHYSICS_SIM_MULTIPLIER: float = 100.0
const SQRT2_2: float = 0.5 * sqrt(2.0)
const OCTANTS: Array[Vector2] = [Vector2(1.0, 0.0),
								Vector2(SQRT2_2, SQRT2_2),
								Vector2(0.0, 1.0),
								Vector2(-SQRT2_2, SQRT2_2),
								Vector2(-1.0, 0.0),
								Vector2(-SQRT2_2, -SQRT2_2),
								Vector2(0.0, -1.0),
								Vector2(SQRT2_2,  -SQRT2_2)]
const SHIP_TEXTURES: Array[Texture2D] = [preload("res://textures/hoovercraft00.png"),
										preload("res://textures/hoovercraft01.png")]
