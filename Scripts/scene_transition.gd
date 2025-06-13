extends CanvasLayer

@export var transition_speed: float = 0.04 # How long the pause is between each animation step

@onready var tile_map = $TileMap
@onready var input_blocker = $InputBlocker

signal transition_finished

func transition_to(scene_path):
	input_blocker.show()
	var size = Vector2i(get_viewport().size / 32)
	
	# --- COVER SCREEN ANIMATION (Diagonal Wipe) ---
	# The max number of steps is the width + height of the screen in tiles
	var max_steps = size.x + size.y
	for step in range(max_steps):
		# for each step, draw all tiles that add up to this step number
		for x in range(step + 1):
			var y = step - x
			# don't try to draw outside the screen
			if x < size.x and y < size.y:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		
		# Wait after each diagonal line is drawn
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed).timeout
			
	# --- CHANGE THE SCENE ---
	get_tree().change_scene_to_file(scene_path)
	# Wait one frame to ensure the new scene is fully loaded before we start the uncover animation
	await get_tree().process_frame

	# --- UNCOVER SCREEN ANIMATION (Diagonal Wipe from Bottom-Left) ---
	# This logic is similar to the cover, but we calculate 'y' from the bottom edge.
	for step in range(max_steps):
		for x in range(step + 1):
			var y = (size.y - 1) - (step - x) # Calculate y from the bottom
			if x < size.x and y >= 0:
				tile_map.erase_cell(0, Vector2i(x, y))
		
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed).timeout

	input_blocker.hide()
	emit_signal("transition_finished")
