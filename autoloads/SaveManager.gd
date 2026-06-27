extends Node

const SAVE_PATH := "user://savegame.json"

var save_data := {}

func save_game() -> bool:

	save_data = {
		"save_version": 1,
		"inventory": InventoryManager.get_save_data()
	}

	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)
	print("save file:",file)
	if file == null:
		push_error("Failed to create save file")
		return false

	file.store_string(
		JSON.stringify(save_data, "\t")
	)

	file.close()

	print("Game Saved")

	return true


func load_game() -> bool:

	if not save_exists():
		return false

	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		push_error("Failed to load save file")
		return false

	var content = file.get_as_text()

	file.close()

	var json = JSON.new()

	var result = json.parse(content)

	if result != OK:
		push_error("Failed parsing save file")
		return false

	var data = json.data

	InventoryManager.load_save_data(
		data.get("inventory", {})
	)

	print("Game Loaded")

	return true


func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:

	if save_exists():
		DirAccess.remove_absolute(SAVE_PATH)

	print("...Deleting save")
