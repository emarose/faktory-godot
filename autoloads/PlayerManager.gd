extends Node

var player_state := PlayerState.new()


func initialize_player() -> void:

	player_state = PlayerState.new()

	player_state.position = Vector2i.ZERO

	player_state.discovery_radius = 5


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
		5
	)
