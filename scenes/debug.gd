extends Node

func _ready() -> void:

	test_databases_loaded()
	test_item_lookup()
	test_recipe_lookup()
	test_machine_lookup()
	test_node_lookup()
	test_milestone_lookup()

	test_items_integrity()
	test_recipe_integrity()
	test_machine_integrity()
	test_node_integrity()
	test_milestone_integrity()

	print("\n====================")
	print("TESTS FINISHED")
	print("====================")

func test_databases_loaded() -> void:
	print("--- DATABASE COUNTS ---")

	print("Items: ", DataManager.items_by_id.size())
	print("Recipes: ", DataManager.recipes_by_id.size())
	print("Machines: ", DataManager.machines_by_id.size())
	print("Nodes: ", DataManager.nodes_by_id.size())
	print("Milestones: ", DataManager.milestones_by_id.size())

func test_item_lookup() -> void:
	print("\n--- ITEMS ---")

	for item_id in DataManager.items_by_id.keys():
		print(item_id)

func test_recipe_lookup() -> void:

	print("\n--- RECIPE LOOKUP ---")

	for recipe_id in DataManager.recipes_by_id.keys():

		var recipe = DataManager.get_recipe(recipe_id)

		if recipe == null:
			push_error("Lookup failed: %s" % recipe_id)
		else:
			print("OK: ", recipe.name)

func test_node_lookup() -> void:
	print("\n--- NODE LOOKUP ---")

	for node_id in DataManager.nodes_by_id.keys():
		var node = DataManager.get_resource_node(node_id)
		if node == null:
			push_error("Lookup failed: %s" % node_id)
		else:
			print("OK: ", node.name)

func test_machine_lookup() -> void:
	print("\n--- MACHINE LOOKUP ---")

	for machine_id in DataManager.machines_by_id.keys():
		var machine = DataManager.get_machine(machine_id)
		if machine == null:
			push_error("Lookup failed: %s" % machine_id)
		else:
			print("OK: ", machine.name)

func test_items_integrity() -> void:

	print("\n--- ITEM VALIDATION ---")

	for item in DataManager.items_by_id.values():

		if item.id.is_empty():
			push_error("Item missing id")

		if item.name.is_empty():
			push_error("Item missing name")	

func test_recipe_integrity() -> void:

	print("\n--- RECIPE VALIDATION ---")

	for recipe in DataManager.recipes_by_id.values():

		for input_id in recipe.inputs.keys():

			if not DataManager.has_item(input_id):

				push_error(
					"Recipe '%s' references missing item '%s'"
					% [recipe.id, input_id]
				)

		for output_id in recipe.outputs.keys():

			if not DataManager.has_item(output_id):

				push_error(
					"Recipe '%s' references missing item '%s'"
					% [recipe.id, output_id]
				)

func test_machine_integrity() -> void:

	print("\n--- MACHINE VALIDATION ---")

	for machine in DataManager.machines_by_id.values():

		for recipe_id in machine.allowed_recipes:

			if not DataManager.has_recipe(recipe_id):

				push_error(
					"Machine '%s' references missing recipe '%s'"
					% [machine.id, recipe_id]
				)
func test_node_integrity() -> void:

	print("\n--- NODE VALIDATION ---")

	for node in DataManager.nodes_by_id.values():

		for output_id in node.output.keys():

			if not DataManager.has_item(output_id):

				push_error(
					"Node '%s' references missing item '%s'"
					% [node.id, output_id]
				)

func test_milestone_lookup() -> void:
	print("\n--- MILESTONE LOOKUP ---")

	for milestone_id in DataManager.milestones_by_id.keys():
		var milestone = DataManager.get_milestone(milestone_id)
		if milestone == null:
			push_error("Lookup failed: %s" % milestone_id)
		else:
			print("OK: ", milestone.name)

func test_milestone_integrity() -> void:
	print("\n--- MILESTONE VALIDATION ---")

	for milestone in DataManager.milestones_by_id.values():
		if milestone.id.is_empty():
			push_error("Milestone missing id")
		if milestone.name.is_empty():
			push_error("Milestone missing name")
