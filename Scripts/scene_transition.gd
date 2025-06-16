extends CanvasLayer

@export var transition_speed: float = 0.01

@onready var tile_map = $TileMap
@onready var input_blocker = $InputBlocker

signal transition_finished

# This is our new "master" function for changing scenes.
# It now uses our two new helper functions.
func transition_to(scene_path):
	await cover_screen()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await uncover_screen()
	emit_signal("transition_finished")

# --- NEW HELPER FUNCTIONS ---

# This function ONLY handles covering the screen with tiles.
func cover_screen() -> void:
	input_blocker.show()
	var size = Vector2i(get_viewport().size / 32)
	var max_steps = size.x + size.y
	for step in range(max_steps):
		for x in range(step + 1):
			var y = step - x
			if x < size.x and y < size.y:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed).timeout

# This function ONLY handles uncovering the screen.
func uncover_screen() -> void:
	var size = Vector2i(get_viewport().size / 32)
	var max_steps = size.x + size.y
	for step in range(max_steps):
		for x in range(step + 1):
			var y = (size.y - 1) - (step - x)
			if x < size.x and y >= 0:
				tile_map.erase_cell(0, Vector2i(x, y))
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed).timeout
	input_blocker.hide()
