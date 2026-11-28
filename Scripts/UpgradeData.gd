class_name UpgradeData extends Resource

@export_category("ID")
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_category("Tree_Placement")
@export_enum("The Core", "The Harvest", "The Redline", "The Ssscale", "Snake Eyes")
var path: String = "The Core"

@export_enum("Idle", "Planner", "Ledger", "Glutton", "Wrangler", "Geode", "Acrobat", "Frenzy", "Survivor", "Illusionist", "Architect", "Gamba")
var sub_path: String = "Idle"

@export_enum("Passive", "Active Ability", "In-Active Ability", "Keystone", "Keystone Ability", "Boost", "Passive/Ability", "On-Death Ability")
var type: String = "Passive"

@export_category("Progression & Balance")
@export var costs: Array[int] = []
@export var level_values: Array[float] = [] #Empty for 1timers

@export_category("Unlock Rules")
@export var prerequisites: Dictionary = {}
@export var exlusivity_group: String = ""

var max_level: int:
	get:
		return costs.size()

func get_value_at_level(level: int, default_val: float = 0.0) -> float:
	if level >= 0 and level < level_values.size():
		return level_values[level]
	return default_val
