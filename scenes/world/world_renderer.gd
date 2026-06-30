extends Node2D

const TILE_SIZE := 16

var node_marker_scene = preload("res://scenes/markers/NodeMarker.tscn")

func render_world() -> void:
	for child in get_children():
		child.queue_free()

	for node_state in MapManager.get_discovered_nodes():
		var marker = node_marker_scene.instantiate()

		marker.position = Vector2(
			node_state.position.x * TILE_SIZE,
			node_state.position.y * TILE_SIZE
		)

		marker.set_node_type(
			node_state.node_definition_id
		)

		add_child(marker)

	print("Rendered node markers: ", get_child_count())
