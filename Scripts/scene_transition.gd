extends CanvasLayer

@export var transition_speed: float = 0.01 

@onready var tile_map = $TileMap
@onready var input_blocker = $InputBlocker

signal transition_finished

# This is the global function we'll call from other scripts
func transition_to(scene_path):
	input_blocker.show()
	
	# Randomly choose an animation
	var animation_choice = randi() % 2
	
	print("Playing Diagonal Transition")
	await cover_screen_diagonal()

	# --- CHANGE THE SCENE ---
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	# --- UNCOVER SCREEN ---
	await uncover_screen_diagonal()
	
	input_blocker.hide()
	emit_signal("transition_finished")



# --- Diagonal Animation ---
func cover_screen_diagonal():
	transition_speed = 0.02
	var size = Vector2i(get_viewport().size / 32)
	var max_steps = size.x + size.y
	for step in range(max_steps):
		for x in range(step + 1):
			var y = step - x
			if x < size.x and y < size.y:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed).timeout

func uncover_screen_diagonal():
	transition_speed = 0.02
	var size = Vector2i(get_viewport().size / 32)
	var max_steps = size.x + size.y
	for step in range(max_steps):
		for x in range(step + 1):
			var y = (size.y - 1) - (step - x)
			if x < size.x and y >= 0:
				tile_map.erase_cell(0, Vector2i(x, y))
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed).timeout
