extends Node2D

func set_node_type(node_id: String) -> void:

	match node_id:

		"iron_node":
			modulate = Color.GRAY

		"copper_node":
			modulate = Color.ORANGE

		_:
			modulate = Color.WHITE
