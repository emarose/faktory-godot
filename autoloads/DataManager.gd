extends Node

# =====================================================
# DATA REGISTRIES
# =====================================================

var items_by_id: Dictionary = {}
var recipes_by_id: Dictionary = {}
var machines_by_id: Dictionary = {}
var nodes_by_id: Dictionary = {}
var milestones_by_id: Dictionary = {}

# =====================================================
# DATA PATHS
# =====================================================

const ITEMS_PATH := "res://data/items"
const RECIPES_PATH := "res://data/recipes"
const MACHINES_PATH := "res://data/machines"
const NODES_PATH := "res://data/nodes"
const MILESTONES_PATH := "res://data/milestones"

# =====================================================
# LIFECYCLE
# =====================================================

func _ready() -> void:
	load_all_definitions()
	validate_definitions()

	print("DataManager loaded:")
	print("- Items: ", items_by_id.size())
	print("- Recipes: ", recipes_by_id.size())
	print("- Machines: ", machines_by_id.size())
	print("- Nodes: ", nodes_by_id.size())
	print("- Milestones: ", milestones_by_id.size())

# =====================================================
# LOADING
# =====================================================

func load_all_definitions() -> void:
	items_by_id = _load_resource_folder(ITEMS_PATH)
	recipes_by_id = _load_resource_folder(RECIPES_PATH)
	machines_by_id = _load_resource_folder(MACHINES_PATH)
	nodes_by_id = _load_resource_folder(NODES_PATH)
	milestones_by_id = _load_resource_folder(MILESTONES_PATH)

func _load_resource_folder(folder_path: String) -> Dictionary:
	var result: Dictionary = {}

	var dir := DirAccess.open(folder_path)

	if dir == null:
		push_error("DataManager: Folder not found -> %s" % folder_path)
		return result

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():

			if file_name.ends_with(".tres") or file_name.ends_with(".res"):

				var full_path := folder_path.path_join(file_name)

				var resource := ResourceLoader.load(full_path)

				if resource == null:
					push_error("Failed loading resource: %s" % full_path)
					file_name = dir.get_next()
					continue

				var id = resource.get("id")

				if id == null or str(id).is_empty():
					push_error("Resource missing id: %s" % full_path)
					file_name = dir.get_next()
					continue

				if result.has(id):
					push_error("Duplicate id detected: %s" % id)
					file_name = dir.get_next()
					continue

				result[id] = resource

		file_name = dir.get_next()

	dir.list_dir_end()

	return result

# =====================================================
# VALIDATION
# =====================================================

func validate_definitions() -> void:
	_validate_recipes()
	_validate_nodes()

func _validate_recipes() -> void:

	for recipe in recipes_by_id.values():

		for input_id in recipe.inputs.keys():

			if not items_by_id.has(input_id):
				push_error(
					"Recipe '%s' references missing input item '%s'"
					% [recipe.id, input_id]
				)

		for output_id in recipe.outputs.keys():

			if not items_by_id.has(output_id):
				push_error(
					"Recipe '%s' references missing output item '%s'"
					% [recipe.id, output_id]
				)

func _validate_nodes() -> void:
	for node in nodes_by_id.values():
		for output_id in node.output.keys():
			if not items_by_id.has(output_id):
				push_error(
					"Node '%s' references missing output item '%s'"
					% [node.id, output_id]
				)

# =====================================================
# LOOKUPS
# =====================================================

func get_item(id: String):
	return items_by_id.get(id)

func get_recipe(id: String):
	return recipes_by_id.get(id)

func get_machine(id: String):
	return machines_by_id.get(id)

func get_resource_node(id: String):
	return nodes_by_id.get(id)

func get_milestone(id: String):
	return milestones_by_id.get(id)

# =====================================================
# EXISTENCE CHECKS
# =====================================================

func has_item(id: String) -> bool:
	return items_by_id.has(id)

func has_recipe(id: String) -> bool:
	return recipes_by_id.has(id)

func has_machine(id: String) -> bool:
	return machines_by_id.has(id)

func has_resource_node(id: String) -> bool:
	return nodes_by_id.has(id)

func has_milestone(id: String) -> bool:
	return milestones_by_id.has(id)
