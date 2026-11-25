class_name MetaUpgradeData extends Resource

@export var enabled: bool = true

@export_category("Identity/Flavor")
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export_enum("Slot", "Aesthetic", "Tickers", "Luck", "Economy") var type: String = "Slot"

@export_category("Progression/Balance")
@export var costs: Array[int] = []
@export var level_values: Array[float] = []

var max_level: int:
	get:
		return costs.size()
		

func get_value_at_level(level: int, default_value: float = 0.0) -> float:
	if level >= 0 and level < level_values.size():
		return level_values[level]
	return default_value
