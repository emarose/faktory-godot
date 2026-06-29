extends Node

# =====================================================
# WORLD DATA
# =====================================================

var world_seed: int = 0

var node_states: Array[NodeState] = []

# =====================================================
# WORLD GENERATION
# =====================================================

func generate_world(seed_value: int = -1) -> void:

	node_states.clear()

	if seed_value == -1:
		world_seed = randi()
	else:
		world_seed = seed_value

	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed

	print("Generating world with seed: ", world_seed)

	_generate_test_nodes(rng)

# =====================================================
# TEST GENERATION
# =====================================================

func _generate_test_nodes(rng: RandomNumberGenerator) -> void:

	var available_nodes := DataManager.nodes_by_id.keys()

	if available_nodes.is_empty():
		push_error("MapManager: No NodeDefinitions found.")
		return

	for i in range(20):

		var node_id = available_nodes.pick_random()

		var definition = DataManager.get_resource_node(node_id)

		var node := NodeState.new()

		node.node_definition_id = node_id
		node.position = Vector2i(
			rng.randi_range(0, 100),
			rng.randi_range(0, 100)
		)

		node.current_amount = definition.capacity
		node.discovered = false

		node_states.append(node)

	print("Generated nodes: ", node_states.size())

# =====================================================
# NODE LOOKUPS
# =====================================================

func get_node_at_position(pos: Vector2i) -> NodeState:

	for node in node_states:

		if node.position == pos:
			return node

	return null

func get_node_definition(node: NodeState):

	return DataManager.get_resource_node(
		node.node_definition_id
	)

# =====================================================
# DISCOVERY
# =====================================================

func discover_node(node: NodeState) -> void:

	if node == null:
		return

	if node.discovered:
		return

	node.discovered = true

	if EventBus:
		EventBus.emit_signal(
			"node_discovered",
			node
		)

# =====================================================
# MINING
# =====================================================

func mine_node(
	node: NodeState,
	amount: int
) -> bool:

	if node == null:
		return false

	if amount <= 0:
		return false

	if node.current_amount <= 0:
		return false

	var definition = get_node_definition(node)

	if definition == null:
		return false

	var mined_amount = min(
		amount,
		node.current_amount
	)

	node.current_amount -= mined_amount

	for item_id in definition.output.keys():

		var output_multiplier = definition.output[item_id]

		InventoryManager.add_item(
			item_id,
			mined_amount * output_multiplier
		)

	if node.current_amount <= 0:

		if EventBus:
			EventBus.emit_signal(
				"node_depleted",
				node
			)

	return true

# =====================================================
# SAVE SUPPORT
# =====================================================

func get_save_data() -> Dictionary:

	var nodes_data := []

	for node in node_states:

		nodes_data.append({
			"node_definition_id": node.node_definition_id,
			"position_x": node.position.x,
			"position_y": node.position.y,
			"current_amount": node.current_amount,
			"discovered": node.discovered
		})

	return {
		"world_seed": world_seed,
		"nodes": nodes_data
	}

func load_save_data(data: Dictionary) -> void:

	world_seed = data.get(
		"world_seed",
		0
	)

	node_states.clear()

	var saved_nodes = data.get(
		"nodes",
		[]
	)

	for node_data in saved_nodes:

		var node := NodeState.new()

		node.node_definition_id = node_data.get(
			"node_definition_id",
			""
		)

		node.position = Vector2i(
			node_data.get("position_x", 0),
			node_data.get("position_y", 0)
		)

		node.current_amount = node_data.get(
			"current_amount",
			0
		)

		node.discovered = node_data.get(
			"discovered",
			false
		)

		node_states.append(node)

	print(
		"Loaded nodes: ",
		node_states.size()
	)

# =====================================================
# DEBUG
# =====================================================

func print_nodes() -> void:

	print("\n===== WORLD NODES =====")

	for node in node_states:

		print(
			node.node_definition_id,
			" @ ",
			node.position,
			" amount=",
			node.current_amount,
			" discovered=",
			node.discovered
		)

	print("=======================\n")
