extends Resource
class_name CraftingJob

@export var id: int
@export var recipe_id: int
@export var started_at: float   # timestamp o engine.get_ticks_msec()
@export var finish_at: float    # timestamp calculado
@export var machine_id: int
@export var progress: float = 0.0   # opcional, 0.0 a 1.0
@export var inputs_reserved: Dictionary = {}  # opcional: items bloqueados para este job
