extends Node

func _ready() -> void:
	#DATA LOADING
	test_databases_loaded()
	test_item_lookup()
	test_recipe_lookup()
	test_machine_lookup()
	test_node_lookup()
	test_milestone_lookup()
	#DATA INTEGRITY
	test_items_integrity()
	test_recipe_integrity()
	test_machine_integrity()
	test_node_integrity()
	test_milestone_integrity()
	#WORLD GENERATION
	test_weighted_generation_sanity()
	test_mine_exhaustion()
	#GAME MANAGERS
	test_inventory_manager()
	test_save_manager()
	test_map_manager()
	test_production_manager()
	test_machine_manager()
	test_progression_manager()
	test_player_manager()

	print("\n====================")
	print("TESTS FINISHED")
	print("====================")

func assert_test(condition: bool, label: String) -> void:
	if condition:
		print("[PASS]", label)
	else:
		print("[FAIL]", label)

func test_inventory_manager() -> void:
	print("--- INVENTORY VALIDATION ---")

	InventoryManager.clear_inventory()

	InventoryManager.add_item("iron_ore", 10)

	assert_test(
		InventoryManager.get_amount("iron_ore") == 10,
        "Add Item"
	)

	assert_test(
		InventoryManager.has_item("iron_ore", 5),
        "Has Item"
	)

	assert_test(
		not InventoryManager.has_item("iron_ore", 20),
        "Has Item Fails Correctly"
	)

	InventoryManager.remove_item("iron_ore", 5)

	assert_test(
		InventoryManager.get_amount("iron_ore") == 5,
        "Remove Item"
	)

	var cost = { "iron_ore": 5 }

	assert_test(
		InventoryManager.has_items(cost),
        "Has Cost"
	)

	InventoryManager.remove_cost(cost)

	assert_test(
		InventoryManager.get_amount("iron_ore") == 0,
        "Remove Cost"
	)


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
		
		assert_test(not node.output.is_empty(), "Node '%s' Has Output" % node.id)

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

func test_save_manager() -> void:

	print("\n--- SAVE MANAGER ---")

	InventoryManager.clear_inventory()

	InventoryManager.add_item("iron_ore", 10)

	var save_success = SaveManager.save_game()

	assert_test(
		save_success,
		"Save Game"
	)
	InventoryManager.print_inventory()
	InventoryManager.clear_inventory()
	InventoryManager.print_inventory()
	var load_success = SaveManager.load_game()
	assert_test(SaveManager.save_exists(), "Save Exists After Save")
	assert_test(
			SaveManager.save_data.has("save_version"),
			"Save Version Exists"
		)
	
	assert_test(
		load_success,
		"Load Game"
	)

	assert_test(
		InventoryManager.get_amount("iron_ore") == 10,
		"Load Inventory"
	)
	
	SaveManager.delete_save()
	
	assert_test(not SaveManager.save_exists(), "Save Deleted Correctly")

func test_map_manager() -> void:
	print("MAP MANAGER")

	MapManager.generate_world(12345)
	var first_snapshot := _get_node_snapshot(MapManager.node_states)

	MapManager.generate_world(12345)
	var second_snapshot := _get_node_snapshot(MapManager.node_states)

	assert_test(
		first_snapshot == second_snapshot,
		"World Seed Deterministic: Positions, Types, Capacities"
	)

	assert_test(
		MapManager.node_states.size() == 20,
		"Generated 20 Nodes"
	)

	var node = MapManager.node_states[0]
	var definition = MapManager.get_node_definition(node)
	var original = node.current_amount

	InventoryManager.clear_inventory()

	var mined_successfully = MapManager.mine_node(node, 10)

	assert_test(
		mined_successfully,
		"Mining Node Succeeds"
	)
	
	assert_test(
		node.current_amount == original - 10,
		"Mining Reduces Node Amount"
	)

	var mining_added_resources := false
	
	for item_id in definition.output.keys():
		if InventoryManager.get_amount(item_id) > 0:
			mining_added_resources = true

	assert_test(
		mining_added_resources,
		"Mining Adds Node Output Resources"
	)

	var save_data = MapManager.get_save_data()

	MapManager.load_save_data(save_data)

	assert_test(
		MapManager.node_states.size() == 20,
		"Node Save/Load Works"
	)

#func test_map_manager() -> void:
	#print("MAP MANAGER")
	#MapManager.generate_world(12345)
#
	#var first = MapManager.node_states[0].position
#
	#MapManager.generate_world(12345)
#
	#var second = MapManager.node_states[0].position
#
	#assert_test(
		#first == second,
		#"World Seed Deterministic"
	#)
	#assert_test(
		#MapManager.node_states.size() == 20,
		#"Generated 20 Nodes"
	#)
	#var node = MapManager.node_states[0]
#
	#var original = node.current_amount
#
	#MapManager.mine_node(node, 10)
#
	#assert_test(
		#node.current_amount == original - 10,
		#"Mining Reduces Node Amount"
	#)
	#assert_test(
	#InventoryManager.get_amount("iron_ore") > 0,
	#"Mining Adds Resources"
	#)
	#var save_data = MapManager.get_save_data()
#
	#MapManager.load_save_data(save_data)
#
	#assert_test(
		#MapManager.node_states.size() == 20,
		#"Node Save/Load Works"
	#)

func test_production_manager() -> void:
	InventoryManager.clear_inventory()
	print("OUTPUT DEBUG")
	InventoryManager.add_item("iron_ore",10)
	
	assert_test(ProductionManager.can_craft("iron_ingot"),
	"Can Craft Iron Ingot"
	)
	
	ProductionManager.craft_recipe("iron_ingot")
	
	assert_test(InventoryManager.get_amount("iron_ore") == 8,"Inputs Consumed")
	InventoryManager.print_inventory()
	assert_test(InventoryManager.get_amount("iron_ingot") == 1,"Outputs Granted")
	
	InventoryManager.clear_inventory()
	
	assert_test(not ProductionManager.can_craft("iron_ingot"),
	"Cannot Craft Without Resources")

func test_machine_manager() -> void:
	print("\n--- MACHINE MANAGER ---")

	MachineManager.machine_states.clear()
	InventoryManager.clear_inventory()

	InventoryManager.add_item(
		"iron_ore",
		10
	)

	var machine = MachineManager.create_machine("smelter")

	assert_test(
		machine != null,
		"Machine Created"
	)

	assert_test(
		MachineManager.assign_recipe(machine, "iron_ingot"),
		"Recipe Assigned"
	)

	assert_test(
		MachineManager.start_machine(machine),
		"Machine Started"
	)

	MachineManager.update_machine(
		machine,
		100.0
	)

	assert_test(
		InventoryManager.get_amount("iron_ingot") == 1,
		"Machine Completed First Output"
	)

	assert_test(
		machine.is_running,
		"Machine Auto Restarted"
	)

	var safety := 20

	while machine.is_running and safety > 0:
		MachineManager.update_machine(
			machine,
			100.0
		)

		safety -= 1

	assert_test(
		safety > 0,
		"Machine Auto Processing Finished Safely"
	)

	assert_test(
		InventoryManager.get_amount("iron_ore") == 0,
		"Consumed All Ore"
	)

	assert_test(
		InventoryManager.get_amount("iron_ingot") == 5,
		"Produced All Ingots"
	)

	assert_test(
		not machine.is_running,
		"Stopped When Inputs Exhausted"
	)

	var save_data = MachineManager.get_save_data()

	MachineManager.load_save_data(save_data)

	assert_test(
		MachineManager.machine_states.size() == 1,
		"Machine Save/Load"
	)

	assert_test(
		MachineManager.machine_states[0].auto_restart,
		"Machine Auto Restart Save/Load"
	)

func test_progression_manager() -> void:
	ProgressionManager.unlock_recipe("iron_ingot")
	assert_test(ProgressionManager.is_recipe_unlocked("iron_ingot"),"Recipe Unlock")
	
	ProgressionManager.unlock_machine("smelter")
	assert_test(ProgressionManager.is_machine_unlocked("smelter"),"Machine Unlock")
	var save_data = (ProgressionManager.get_save_data())

	ProgressionManager.initialize_progression()
	ProgressionManager.load_save_data(save_data)

	assert_test(ProgressionManager.is_recipe_unlocked("iron_ingot"),"Progression Save Load")

func test_weighted_generation_sanity() -> void:
	print("\n--- WEIGHTED GENERATION SANITY ---")

	var iron_definition = DataManager.get_resource_node("iron_node")
	var copper_definition = DataManager.get_resource_node("copper_node")

	if iron_definition == null or copper_definition == null:
		assert_test(false, "Weighted Generation Requires Iron And Copper Nodes")
		return

	if iron_definition.spawn_weight <= copper_definition.spawn_weight:
		print("Skipping weighted sanity check: iron_node weight is not larger than copper_node weight.")
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 12345

	var iron_count := 0
	var copper_count := 0

	for i in range(1000):
		var node_id := MapManager.weighted_random_node(rng)

		if node_id == "iron_node":
			iron_count += 1

		if node_id == "copper_node":
			copper_count += 1

	print("iron_node: ", iron_count)
	print("copper_node: ", copper_count)

	assert_test(
		iron_count > copper_count,
		"Weighted Generation Prefers Larger Weight"
	)

func test_mine_exhaustion() -> void:
	print("\n--- MINE EXHAUSTION ---")

	MapManager.generate_world(12345)

	if MapManager.node_states.is_empty():
		assert_test(false, "Mine Exhaustion Requires Generated Nodes")
		return

	var node = MapManager.node_states[0]

	InventoryManager.clear_inventory()

	node.current_amount = 1

	var first_mine := MapManager.mine_node(node, 10)

	assert_test(
		first_mine,
		"Mine Final Node Amount Succeeds"
	)

	assert_test(
		node.current_amount == 0,
		"Mine Exhaustion Reaches Zero"
	)

	var second_mine := MapManager.mine_node(node, 10)

	assert_test(
		not second_mine,
		"Mine Exhausted Node Fails"
	)

	assert_test(
		node.current_amount == 0,
		"Exhausted Mine Stays At Zero"
	)

func test_player_manager() -> void:
	print("\n--- PLAYER MANAGER ---")

	PlayerManager.initialize_player()

	assert_test(
		PlayerManager.get_position() == Vector2i.ZERO,
		"Player Initialized"
	)

	assert_test(
		PlayerManager.player_state.discovery_radius == 16,
		"Player Discovery Radius Initialized"
	)

	PlayerManager.set_position(Vector2i(10, 20))

	assert_test(
		PlayerManager.get_position() == Vector2i(10, 20),
		"Player Position Updated"
	)

	PlayerManager.player_state.discovery_radius = 8

	var save_success := SaveManager.save_game()

	assert_test(
		save_success,
		"Player Save Created"
	)

	PlayerManager.initialize_player()

	assert_test(
		PlayerManager.get_position() == Vector2i.ZERO,
		"Player Reset Before Load"
	)

	var load_success := SaveManager.load_game()

	assert_test(
		load_success,
		"Player Save Loaded"
	)

	assert_test(
		PlayerManager.get_position() == Vector2i(10, 20),
		"Player Position Persisted"
	)

	assert_test(
		PlayerManager.player_state.discovery_radius == 8,
		"Player Discovery Radius Persisted"
	)

	SaveManager.delete_save()
	
# HELPERS
func _get_node_snapshot(nodes: Array[NodeState]) -> Array:
	var snapshot := []

	for node in nodes:
		snapshot.append({
			"id": node.node_definition_id,
			"position": node.position,
			"amount": node.current_amount
		})

	return snapshot
