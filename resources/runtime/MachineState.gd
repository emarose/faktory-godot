extends Resource
class_name MachineState

@export var machine_definition_id: String
@export var position: Vector2i
@export var selected_recipe_id: String = ""
@export var is_running: bool = false
@export var progress: float = 0.0
@export var target_time: float = 0.0
@export var fuel: float = 0.0

func reset_progress() -> void:
	progress = 0.0
	target_time = 0.0
	is_running = false
