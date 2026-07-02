extends Node

# RESOURCES & INVENTORY
signal inventory_changed(inventory)
signal resource_added(item_id, amount)
signal resource_removed(item_id, amount)
signal node_discovered(node_id)
signal node_depleted(node_id)
signal node_mined(node_id, amount)
# MACHINES
signal machine_created(machine_id)
signal machine_removed(machine_id)
signal machine_recipe_assigned(machine_id,recipe_id)
signal recipe_completed(recipe_id)
signal machine_processed(machine_id)
signal machine_started(machine_id)
signal machine_completed(machine_id)
signal machine_auto_restarted(machine_id)
# GAME DATA
signal game_loaded()
signal game_saved()
#MILESTONES
signal milestone_completed(milestone_id)
signal recipe_unlocked(recipe_id)
signal machine_unlocked(machine_id)
signal node_unlocked(node_id)
#PLAYER
signal player_moved(position)
