extends Node

# =====================================================
# RUNTIME PROGRESSION STATE
# =====================================================

var completed_milestones: Array[String] = []

var unlocked_recipes: Array[String] = []

var unlocked_machines: Array[String] = []

var unlocked_nodes: Array[String] = []


# =====================================================
# INITIALIZATION
# =====================================================

func initialize_progression() -> void:

	completed_milestones.clear()

	unlocked_recipes.clear()

	unlocked_machines.clear()

	unlocked_nodes.clear()


# =====================================================
# LOOKUPS
# =====================================================

func is_milestone_completed(
	milestone_id: String
) -> bool:

	return completed_milestones.has(
		milestone_id
	)


func is_recipe_unlocked(
	recipe_id: String
) -> bool:

	return unlocked_recipes.has(
		recipe_id
	)


func is_machine_unlocked(
	machine_id: String
) -> bool:

	return unlocked_machines.has(
		machine_id
	)


func is_node_unlocked(
	node_id: String
) -> bool:

	return unlocked_nodes.has(
		node_id
	)


# =====================================================
# REQUIREMENTS
# =====================================================

func can_complete_milestone(
	milestone_id: String
) -> bool:

	var milestone = DataManager.get_milestone(
		milestone_id
	)

	if milestone == null:
		return false

	if is_milestone_completed(
		milestone_id
	):
		return false

	return InventoryManager.has_items(
		milestone.requirements
	)


# =====================================================
# COMPLETION
# =====================================================

func complete_milestone(
	milestone_id: String
) -> bool:

	var milestone = DataManager.get_milestone(
		milestone_id
	)

	if milestone == null:
		return false

	if not can_complete_milestone(
		milestone_id
	):
		return false

	completed_milestones.append(
		milestone_id
	)

	_unlock_content(
		milestone
	)

	if EventBus:
		EventBus.emit_signal(
			"milestone_completed",
			milestone_id
		)

	return true


# =====================================================
# UNLOCKS
# =====================================================

func _unlock_content(
	milestone
) -> void:

	for recipe_id in milestone.unlock_recipes:

		unlock_recipe(recipe_id)

	for machine_id in milestone.unlock_machines:

		unlock_machine(machine_id)

	for node_id in milestone.unlock_nodes:

		unlock_node(node_id)


func unlock_recipe(
	recipe_id: String
) -> void:

	if unlocked_recipes.has(recipe_id):
		return

	unlocked_recipes.append(
		recipe_id
	)

	if EventBus:
		EventBus.emit_signal(
			"recipe_unlocked",
			recipe_id
		)


func unlock_machine(
	machine_id: String
) -> void:

	if unlocked_machines.has(machine_id):
		return

	unlocked_machines.append(
		machine_id
	)

	if EventBus:
		EventBus.emit_signal(
			"machine_unlocked",
			machine_id
		)


func unlock_node(
	node_id: String
) -> void:

	if unlocked_nodes.has(node_id):
		return

	unlocked_nodes.append(
		node_id
	)

	if EventBus:
		EventBus.emit_signal(
			"node_unlocked",
			node_id
		)


# =====================================================
# SAVE SUPPORT
# =====================================================

func get_save_data() -> Dictionary:

	return {
		"completed_milestones":
			completed_milestones.duplicate(),

		"unlocked_recipes":
			unlocked_recipes.duplicate(),

		"unlocked_machines":
			unlocked_machines.duplicate(),

		"unlocked_nodes":
			unlocked_nodes.duplicate()
	}


func load_save_data(
	data: Dictionary
) -> void:

	completed_milestones = data.get(
		"completed_milestones",
		[]
	)

	unlocked_recipes = data.get(
		"unlocked_recipes",
		[]
	)

	unlocked_machines = data.get(
		"unlocked_machines",
		[]
	)

	unlocked_nodes = data.get(
		"unlocked_nodes",
		[]
	)


# =====================================================
# DEBUG
# =====================================================

func print_progression() -> void:

	print("\n===== PROGRESSION =====")

	print(
		"Completed Milestones: ",
		completed_milestones
	)

	print(
		"Unlocked Recipes: ",
		unlocked_recipes
	)

	print(
		"Unlocked Machines: ",
		unlocked_machines
	)

	print(
		"Unlocked Nodes: ",
		unlocked_nodes
	)

	print("=======================\n")
