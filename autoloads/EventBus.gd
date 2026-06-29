extends Node

signal inventory_changed(inventory)
signal resource_added(item_id, amount)
signal resource_removed(item_id, amount)
signal node_discovered(node)
signal node_depleted(node)
signal machine_built(machine_state_id)
signal machine_placed(machine_state_id)
signal recipe_completed(recipe_id)
signal milestone_completed(milestone_id)
signal game_loaded()
signal game_saved()
