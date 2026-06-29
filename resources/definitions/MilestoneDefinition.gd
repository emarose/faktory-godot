extends Resource
class_name MilestoneDefinition

@export var id: String
@export var name: String
@export var description: String
@export var requirements: Dictionary
@export var unlock_recipes: Array[String]
@export var unlock_machines: Array[String]
@export var unlock_nodes: Array[String]
