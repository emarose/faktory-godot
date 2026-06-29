extends Node

func can_craft(recipe_id: String) -> bool:

	var recipe = DataManager.get_recipe(recipe_id)

	if recipe == null:
		push_error(
			"ProductionManager: Recipe not found '%s'"
			% recipe_id
		)
		return false

	return InventoryManager.has_items(recipe.inputs)

func craft_recipe(recipe_id: String) -> bool:

	if not consume_recipe_inputs(recipe_id):
		return false

	if not grant_recipe_outputs(recipe_id):
		return false

	if EventBus:
		EventBus.emit_signal(
			"recipe_completed",
			recipe_id
		)

	return true

func get_recipe(recipe_id: String):
	return DataManager.get_recipe(recipe_id)

func consume_recipe_inputs(recipe_id: String) -> bool:
	var recipe = DataManager.get_recipe(recipe_id)

	if recipe == null:
		push_error(
			"ProductionManager: Recipe not found '%s'"
			% recipe_id
		)
		return false

	if not InventoryManager.has_items(recipe.inputs):
		return false

	InventoryManager.remove_cost(recipe.inputs)

	return true

func grant_recipe_outputs(recipe_id: String) -> bool:
	var recipe = DataManager.get_recipe(recipe_id)

	if recipe == null:
		push_error(
			"ProductionManager: Recipe not found '%s'"
			% recipe_id
		)
		return false

	for item_id in recipe.outputs.keys():
		
		var amount := int(recipe.outputs[item_id])
		InventoryManager.add_item(item_id,amount)

	return true

func get_processing_time(recipe_id: String) -> float:
	var recipe = DataManager.get_recipe(recipe_id)

	if recipe == null:
		return 0.0

	return recipe.processing_time
