extends Resource
class_name NodeState

@export var id: int
@export var node_definition_id: int
@export var position: Vector2
@export var current_amount: int
@export var discovered: bool = false
@export var assigned_machines: Array[int] = []
