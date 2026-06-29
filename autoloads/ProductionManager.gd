extends Node

func can_craft(recipe_id: String) -> bool:

	var recipe = DataManager.get_recipe(recipe_id)

	if recipe == null:
		push_error(
			"ProductionManager: Recipe not found '%s'"
			% recipe_id
		)
		return false

	return InventoryManager.has_items(
		recipe.inputs
	)


func craft_recipe(recipe_id: String) -> bool:

	var recipe = DataManager.get_recipe(recipe_id)
	if recipe == null:
		push_error(
			"ProductionManager: Recipe not found '%s'"
			% recipe_id
		)
		return false

	if not can_craft(recipe_id):
		print("cant craft ",recipe_id)
		return false
	InventoryManager.remove_cost(
		recipe.inputs
	)
	for item_id in recipe.outputs.keys():
	
		var amount := int(recipe.outputs[item_id])
		InventoryManager.add_item(
			item_id,
			amount
		)

	if EventBus:
		EventBus.emit_signal(
			"recipe_completed",
			recipe_id
		)

	return true


func get_recipe(recipe_id: String):

	return DataManager.get_recipe(recipe_id)
