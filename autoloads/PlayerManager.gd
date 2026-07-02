extends Node

var player_state := PlayerState.new()


func attempt_interact() -> void:
	var node := MapManager.get_nearest_discovered_node(
		get_position(),
		player_state.interact_radius
	)

	if node == null:
		print("No discovered node nearby.")
		return

	var mined := MapManager.mine_node(
		node,
		player_state.manual_mine_amount
	)

	if mined:
		print("Mined node: ", node.node_definition_id)
	else:
		print("Could not mine node: ", node.node_definition_id)


func initialize_player() -> void:

	player_state = PlayerState.new()

	player_state.position = Vector2i.ZERO

	player_state.discovery_radius = 16


func set_position(
	new_position: Vector2i
) -> void:

	player_state.position = new_position

	if EventBus:
		EventBus.emit_signal(
			"player_moved",
			new_position
		)


func get_position() -> Vector2i:
	return player_state.position

func get_save_data() -> Dictionary:
	return {
		"x": player_state.position.x,
		"y": player_state.position.y,
		"discovery_radius": player_state.discovery_radius
	}

func load_save_data(data: Dictionary) -> void:
	player_state.position = Vector2i(
		data.get("x", 0),
		data.get("y", 0)
	)

	player_state.discovery_radius = data.get(
		"discovery_radius",
		16
	)
