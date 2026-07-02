extends Node2D

const TILE_SIZE := 16

@onready var world_renderer: Node2D = $WorldRenderer
@onready var player_marker: CharacterBody2D = $PlayerMarker

func _ready() -> void:
	MapManager.generate_world(12345)

	if MapManager.node_states.is_empty():
		push_error("WorldScene: No nodes generated.")
		return

	PlayerManager.set_position(
		MapManager.node_states[0].position
	)

	EventBus.player_moved.connect(
		_on_player_moved
	)

	EventBus.node_discovered.connect(
		_on_node_discovered
	)
	
	EventBus.node_depleted.connect(
		_on_node_depleted
	)
	
	EventBus.node_mined.connect(
	_on_node_mined
	)
	_discover_near_player()

	world_renderer.render_world()

func _on_player_moved(_position: Vector2i) -> void:
	_discover_near_player()

func _on_node_discovered(_node_id: String) -> void:
	world_renderer.render_world()

func _discover_near_player() -> void:
	MapManager.discover_nodes_near_position(
		PlayerManager.get_position(),
		PlayerManager.player_state.discovery_radius
	)

func _on_node_depleted(_node: NodeState) -> void:
	world_renderer.render_world()

func _on_node_mined(node: NodeState, amount: int) -> void:
	print(
		"Mined ",
		amount,
		" from ",
		node.node_definition_id,
		". Remaining: ",
		node.current_amount
	)
