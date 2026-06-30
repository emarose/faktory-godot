extends CharacterBody2D

const TILE_SIZE := 16

func _ready() -> void:
	position = _tile_to_world(
		PlayerManager.get_position()
	)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * PlayerManager.player_state.movement_speed

	move_and_slide()

	var tile_position := _world_to_tile(position)

	if tile_position != PlayerManager.get_position():
		PlayerManager.set_position(tile_position)


func _tile_to_world(tile_position: Vector2i) -> Vector2:
	return Vector2(
		tile_position.x * TILE_SIZE,
		tile_position.y * TILE_SIZE
	)


func _world_to_tile(world_position: Vector2) -> Vector2i:
	return Vector2i(
		roundi(world_position.x / TILE_SIZE),
		roundi(world_position.y / TILE_SIZE)
	)
