extends Resource
class_name PlayerState

@export var position: Vector2i = Vector2i.ZERO
@export var discovery_radius: int = 16
@export var movement_speed: float = 100.0
@export var interact_radius: int = 2
@export var manual_mine_amount: int = 1

func move_to(new_position: Vector2i) -> void:
	position = new_position
