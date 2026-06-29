extends Node

# =====================================================
# RUNTIME MACHINE STORAGE
# =====================================================

var machine_states: Array[MachineState] = []

func _process(delta: float) -> void:

	for machine in machine_states:

		update_machine(
			machine,
			delta
		)
# =====================================================
# MACHINE CREATION
# =====================================================

func create_machine(machine_definition_id: String, position: Vector2i = Vector2i.ZERO) -> MachineState:

	var definition = DataManager.get_machine(
		machine_definition_id
	)

	if definition == null:
		push_error(
			"MachineManager: Invalid machine '%s'"
			% machine_definition_id
		)
		return null

	var machine := MachineState.new()

	machine.machine_definition_id = (
		machine_definition_id
	)

	machine.position = position

	machine_states.append(machine)

	if EventBus:
		EventBus.emit_signal(
			"machine_created",
			machine
		)

	return machine

# =====================================================
# REMOVAL
# =====================================================

func remove_machine(machine: MachineState) -> bool:

	if machine == null:
		return false

	if not machine_states.has(machine):
		return false

	machine_states.erase(machine)

	if EventBus:
		EventBus.emit_signal(
			"machine_removed",
			machine
		)

	return true

# =====================================================
# LOOKUPS
# =====================================================

func get_machine_definition(machine: MachineState):

	if machine == null:
		return null

	return DataManager.get_machine(
		machine.machine_definition_id
	)

func get_machine_at_position(pos: Vector2i) -> MachineState:

	for machine in machine_states:

		if machine.position == pos:
			return machine

	return null

# =====================================================
# RECIPE ASSIGNMENT
# =====================================================

func assign_recipe(machine: MachineState,recipe_id: String) -> bool:

	if machine == null:
		return false

	var recipe = DataManager.get_recipe(
		recipe_id
	)

	if recipe == null:
		push_error(
			"MachineManager: Recipe not found '%s'"
			% recipe_id
		)
		return false

	var definition = get_machine_definition(
		machine
	)

	if definition == null:
		return false

	if not definition.allowed_recipes.has(
		recipe_id
	):
		push_error(
			"MachineManager: Recipe '%s' not allowed on machine '%s'"
			% [
				recipe_id,
				definition.id
			]
		)
		return false

	machine.selected_recipe_id = recipe_id

	if EventBus:
		EventBus.emit_signal(
			"machine_recipe_assigned",
			machine,
			recipe_id
		)

	return true

# =====================================================
# PROCESSING
# =====================================================

func process_machine(machine: MachineState) -> bool:

	if machine == null:
		return false

	if machine.selected_recipe_id.is_empty():
		return false

	var success = (
		ProductionManager.craft_recipe(
			machine.selected_recipe_id
		)
	)

	if success:

		if EventBus:
			EventBus.emit_signal(
				"machine_processed",
				machine
			)

	return success

func start_machine(machine: MachineState) -> bool:

	if machine == null:
		return false

	if machine.is_running:
		return false

	if machine.selected_recipe_id.is_empty():
		return false

	if not ProductionManager.consume_recipe_inputs(
		machine.selected_recipe_id
	):
		return false

	machine.progress = 0.0

	machine.target_time = (
		ProductionManager.get_processing_time(
			machine.selected_recipe_id
		)
	)

	machine.is_running = true

	if EventBus:
		EventBus.emit_signal(
			"machine_started",
			machine
		)

	return true

func update_machine(machine: MachineState,delta: float) -> void:

	if machine == null:
		return

	if not machine.is_running:
		return

	machine.progress += delta

	if machine.progress >= machine.target_time:

		finish_machine(machine)

func finish_machine(machine: MachineState) -> void:

	if machine == null:
		return

	if machine.selected_recipe_id.is_empty():
		return

	ProductionManager.grant_recipe_outputs(
		machine.selected_recipe_id
	)

	machine.is_running = false

	machine.progress = 0.0

	machine.target_time = 0.0

	if EventBus:
		EventBus.emit_signal(
			"machine_completed",
			machine
		)

# =====================================================
# SAVE SUPPORT
# =====================================================

func get_save_data() -> Array:

	var save_data := []

	for machine in machine_states:

		save_data.append({
			"machine_definition_id":
				machine.machine_definition_id,

			"position_x":
				machine.position.x,

			"position_y":
				machine.position.y,

			"selected_recipe_id":
				machine.selected_recipe_id,

			"is_running":
				machine.is_running,

			"progress":
				machine.progress,

			"fuel":
				machine.fuel
		})

	return save_data

func load_save_data(data: Array) -> void:

	machine_states.clear()

	for machine_data in data:

		var machine := MachineState.new()

		machine.machine_definition_id = machine_data.get(
				"machine_definition_id",
				""
			)
		machine.target_time = machine_data.get( "target_time", 0.0
			)
		machine.position = Vector2i(
			machine_data.get(
				"position_x",
				0
			),
			machine_data.get(
				"position_y",
				0
			)
		)

		machine.selected_recipe_id = machine_data.get(
				"selected_recipe_id",
				""
			)

		machine.is_running = machine_data.get(
				"is_running",
				false
			)

		machine.progress = machine_data.get(
				"progress",
				0.0
			)

		machine.fuel = machine_data.get(
				"fuel",
				0.0
			)

		machine_states.append(
			machine
		)


# =====================================================
# HELPERS
# =====================================================

func get_machine_count(machine_id: String) -> int:

	var count := 0

	for machine in machine_states:

		if machine.machine_definition_id == machine_id:
			count += 1

	return count

# =====================================================
# DEBUG
# =====================================================

func print_machines() -> void:

	print("\n===== MACHINES =====")

	if machine_states.is_empty():
		print("No Machines")

	for machine in machine_states:

		print(
			machine.machine_definition_id,
			" @ ",
			machine.position,
			" recipe=",
			machine.selected_recipe_id
		)

	print("====================\n")
