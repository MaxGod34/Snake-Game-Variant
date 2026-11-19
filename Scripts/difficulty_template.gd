class_name DifficultyData extends Resource

@export_category("Flavor_Intro")
@export var display_name: String = "blank ERROR"
@export var description: String = "shootin' blanks ERROR"
@export var icon_path: String = "" #res://whatever/whenever

@export_category("Modifiers")
@export var juice_cost_modifier: int = 0		# Find scale somewhere
@export var speed_multiplier: float = 1.0		# Awh yea
@export var start_slots: int = 10	# Ability Slots
@export var start_juice: int = 30			# Early Upgrades
@export var campaign_length: int = 9
@export var has_rock_modifier: bool = false

@export_category("Upgrade_Lock/Unlock")
@export var locked_paths: Array[String] = []
@export var start_upgrades: Dictionary = {}

@export_category("Meta_Progression")
@export var xp_multiplier: float = 1.0
