extends Resource
class_name NodeState

@export var node_definition_id: String
@export var position: Vector2i
@export var current_amount: int
@export var discovered: bool = false
# assigned_machines not used atm
@export var assigned_machines: Array[int] = []
