class_name DualStatUpgrade extends UpgradeData

@export_category("Dual Level Values")
@export var stat_a_name: String = "Chance:?"
@export var stat_a_values: Array[float] = []

@export var stat_b_name: String = "Reward?"
@export var stat_b_values: Array[float] = []

func get_stat_a(level: int, fallback: float = 0.0) -> float:
	return stat_a_values[level] if level >= 0 and level < stat_a_values.size() else fallback

func get_stat_b(level: int, fallback: float = 0.0) -> float:
	return stat_b_values[level] if level >= 0 and level < stat_b_values.size() else fallback
