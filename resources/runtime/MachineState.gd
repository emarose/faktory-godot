extends Resource
class_name MachineState

@export var id: int
@export var machine_definition_id: int
@export var position: Vector2
@export var assigned_node_id: int = -1
@export var current_recipe_id: int = -1
@export var paused: bool = false
@export var efficiency: float = 1.0
@export var internal_queue: Array = []   # opcional: lista de CraftingJob ids o estructuras
