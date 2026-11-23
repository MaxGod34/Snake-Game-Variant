class_name GridSizeUpgradeData extends UpgradeData

@export_category("Grid Scaling")
@export var grid_sizes: Array[Vector2i] = [
	Vector2i(12,9),
	Vector2i(16,12),
	Vector2i(20,15),
	Vector2i(24,18),
	Vector2i(28,21),
	Vector2i(32,24),
	Vector2i(36,27),
	Vector2i(40,30)
]

func get_grid_size(level: int) -> Vector2i:
	var index = clampi(level, 0, grid_sizes.size() - 1)
	return grid_sizes[index]
