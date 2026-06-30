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
	_generate_nodes(rng)

# =====================================================
# GENERATION
# =====================================================

func _generate_test_nodes(rng: RandomNumberGenerator) -> void:

	var available_nodes := DataManager.nodes_by_id.keys()

	if available_nodes.is_empty():
		push_error("MapManager: No NodeDefinitions found.")
		return

	for i in range(20):
		# this available_nodes.pick_random() should be replaced to use spawn_weight and ratio values from the node definitions, but for now this is fine for testing purposes
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
#IMPORTANT FOR THE FUTURE: world generation settings should live in a resource/data definition, not inside MapManager.
func _generate_nodes(rng: RandomNumberGenerator) -> void:
	if DataManager.nodes_by_id.is_empty():
		push_error("MapManager: No NodeDefinitions found.")
		return

	for i in range(20):
		var node_id := weighted_random_node(rng)

		if node_id.is_empty():
			push_error(
				"MapManager: weighted_random_node returned empty id."
			)
			continue

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

func weighted_random_node(rng: RandomNumberGenerator) -> String:
	var total_weight := 0

	for definition in DataManager.nodes_by_id.values():
		total_weight += max(definition.spawn_weight, 0)

	if total_weight <= 0:
		push_error("MapManager: No NodeDefinitions with spawn_weight > 0.")
		return ""

	var roll := rng.randi_range(1, total_weight)
	var running_weight := 0

	for node_id in DataManager.nodes_by_id.keys():
		var definition = DataManager.get_resource_node(node_id)
		running_weight += max(definition.spawn_weight, 0)

		if roll <= running_weight:
			return node_id

	return ""
# =====================================================
# DISCOVERY
# =====================================================

func discover_node(
	node_id: String
) -> void:

	for node in node_states:

		if node.node_definition_id != node_id:
			continue

		if node.discovered:
			continue

		_discover_node_state(node)
		return


func discover_nodes_near_position(
	position: Vector2i,
	radius: int
) -> void:

	for node in node_states:
		
		var distance = position.distance_to(node.position)
		print(
			"Node:",node.node_definition_id,
			node.position,
			" Distance:",
			distance
		)

		if node.discovered:
			continue

		if node.position.distance_to(position) > radius:
			continue
		
		_discover_node_state(node)


func get_discovered_nodes() -> Array[NodeState]:

	var discovered_nodes: Array[NodeState] = []

	for node in node_states:

		if node.discovered:
			discovered_nodes.append(node)

	return discovered_nodes


func get_undiscovered_nodes() -> Array[NodeState]:

	var undiscovered_nodes: Array[NodeState] = []

	for node in node_states:

		if not node.discovered:
			undiscovered_nodes.append(node)

	return undiscovered_nodes


func get_nodes_near_position(
	position: Vector2i,
	radius: int
) -> Array[NodeState]:

	var nearby_nodes: Array[NodeState] = []

	for node in node_states:

		if node.position.distance_to(position) <= radius:
			nearby_nodes.append(node)

	return nearby_nodes


func get_visible_nodes() -> Array[NodeState]:

	return get_discovered_nodes()


func _discover_node_state(
	node: NodeState
) -> void:

	if node == null:
		return

	if node.discovered:
		return

	node.discovered = true

	if EventBus:
		EventBus.emit_signal(
			"node_discovered",
			node.node_definition_id
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
