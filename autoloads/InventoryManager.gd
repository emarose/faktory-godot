extends Node

# =====================================================
# INVENTORY DATA
# =====================================================

var inventory: Dictionary = {}

# =====================================================
# EVENTS
# =====================================================

func _emit_inventory_changed() -> void:
	EventBus.emit_signal("inventory_changed", inventory)

# =====================================================
# ADD / REMOVE
# =====================================================

func add_item(item_id: String, amount: int = 1) -> void:

	if amount <= 0:
		push_warning("InventoryManager: Cannot add amount <= 0")
		return

	if not DataManager.has_item(item_id):
		push_error("InventoryManager: Invalid item id '%s'" % item_id)
		return

	inventory[item_id] = get_amount(item_id) + amount

	EventBus.emit_signal("resource_added", item_id, amount)
	_emit_inventory_changed()


func remove_item(item_id: String, amount: int = 1) -> bool:

	if amount <= 0:
		push_warning("InventoryManager: Cannot remove amount <= 0")
		return false

	if not has_item(item_id, amount):
		return false

	inventory[item_id] -= amount

	if inventory[item_id] <= 0:
		inventory.erase(item_id)

	EventBus.emit_signal("resource_removed", item_id, amount)
	_emit_inventory_changed()

	return true

# =====================================================
# QUERIES
# =====================================================

func get_amount(item_id: String) -> int:
	return inventory.get(item_id, 0)


func has_item(item_id: String, amount: int = 1) -> bool:
	return get_amount(item_id) >= amount


func has_items(cost: Dictionary) -> bool:

	for item_id in cost.keys():

		var required_amount: int = cost[item_id]

		if not has_item(item_id, required_amount):
			return false

	return true

# =====================================================
# COST HANDLING
# =====================================================

func remove_cost(cost: Dictionary) -> bool:

	if not has_items(cost):
		return false

	for item_id in cost.keys():

		var amount: int = cost[item_id]

		remove_item(item_id, amount)

	return true

# =====================================================
# DEBUG
# =====================================================

func clear_inventory() -> void:

	inventory.clear()

	_emit_inventory_changed()


func print_inventory() -> void:

	print("\n===== INVENTORY =====")

	if inventory.is_empty():
		print("Inventory Empty")

	for item_id in inventory.keys():
		print(item_id, ": ", inventory[item_id])

	print("=====================\n")

# =====================================================
# SAVE SUPPORT
# =====================================================

func get_save_data() -> Dictionary:
	return inventory.duplicate(true)


func load_save_data(data: Dictionary) -> void:

	inventory = data.duplicate(true)

	_emit_inventory_changed()
