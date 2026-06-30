extends Node2D

@onready var node_container: Node2D = $NodeContainer


func _ready():
	test_discovery_persistence()


func render_nodes():

	for child in node_container.get_children():
		child.queue_free()

	for node_state in MapManager.node_states:

		if not node_state.discovered:
			continue

		var marker := Sprite2D.new()

		marker.position = Vector2(
			node_state.position.x * 16,
			node_state.position.y * 16
		)

		node_container.add_child(
			marker
		)

func test_discovery_persistence() -> void:
	print("\n--- DISCOVERY PERSISTENCE ---")

	MapManager.generate_world(12345)
	render_nodes()
	if MapManager.node_states.is_empty():
		assert_test(false, "Discovery Persistence Requires Generated Nodes")
		return

	var node = MapManager.node_states[0]

	MapManager.discover_nodes_near_position(
		node.position,
		0
	)

	assert_test(
		MapManager.get_discovered_nodes().size() > 0,
		"Node Discovered Before Save"
	)

	var save_success := SaveManager.save_game()

	assert_test(
		save_success,
		"Discovery Save Created"
	)

	MapManager.node_states.clear()

	assert_test(
		MapManager.get_discovered_nodes().size() == 0,
		"Map Cleared Before Discovery Load"
	)

	var load_success := SaveManager.load_game()

	assert_test(
		load_success,
		"Discovery Save Loaded"
	)

	assert_test(
		MapManager.get_discovered_nodes().size() > 0,
		"Discovery Persisted"
	)

	SaveManager.delete_save()
	
func assert_test(condition: bool, label: String) -> void:
	if condition:
		print("[PASS]", label)
	else:
		print("[FAIL]", label)
