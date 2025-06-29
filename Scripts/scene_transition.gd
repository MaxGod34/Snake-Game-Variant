extends CanvasLayer

@export var transition_speed: float = 0.01 

@onready var tile_map = $TileMap
@onready var input_blocker = $InputBlocker

signal transition_finished

# This is the global function we'll call from other scripts
func transition_to(scene_path: String, animation_type: String = "random"):
	input_blocker.show()
	
	await cover_screen(animation_type)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	await uncover_screen(animation_type)
	
	input_blocker.hide()
	emit_signal("transition_finished")

func play_cover_animation(animation_type: String):
	input_blocker.show()
	await cover_screen(animation_type)
	
func cover_screen(animation_type: String):
	var choice = animation_type
	if choice == "random":
		choice = ["diagonal", "drip"].pick_random()
	
	match choice:
		"diagonal":
			await cover_screen_diagonal()
		"drip":
			await cover_screen_drip()
		"spiral":
			await cover_screen_spiral()
		"flakes":
			await cover_screen_flakes()

func uncover_screen(animation_type: String):
	var choice = animation_type
	if choice == "random":
		choice = ["diagonal", "drip"].pick_random()
	
	match choice:
		"diagonal":
			await uncover_screen_diagonal()
			input_blocker.hide()
		"drip":
			await uncover_screen_drip()
			input_blocker.hide()
		"spiral":
			await uncover_screen_spiral()
			input_blocker.hide()



func cover_screen_drip():
	var size = Vector2i(get_viewport().size / 32)
	var column_delay = 0.03
	var fall_delay = 0.01

	for x in range(size.x - 1, -1, -1):  # REVERSED here
		await get_tree().create_timer(column_delay).timeout
		start_column_drip(x, size.y, fall_delay)

	var total_time = (size.x - 1) * column_delay + (size.y - 1) * fall_delay
	await get_tree().create_timer(total_time - 0.5).timeout

func start_column_drip(x: int, height: int, delay: float) -> void:
	call_deferred("_run_column_drip", x, height, delay)

func _run_column_drip(x: int, height: int, delay: float) -> void:
	for y in height:
		tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		await get_tree().create_timer(delay).timeout

func uncover_screen_drip():
	var size = Vector2i(get_viewport().size / 32)
	var column_delay = 0.03
	var fall_delay = 0.01

	for x in range(size.x - 1, -1, -1):  # REVERSED here
		await get_tree().create_timer(column_delay).timeout
		start_column_lift(x, size.y, fall_delay)

	var total_time = (size.x - 1) * column_delay + (size.y - 1) * fall_delay
	await get_tree().create_timer(total_time - 0.5).timeout


func start_column_lift(x: int, height: int, delay: float) -> void:
	call_deferred("_run_column_lift", x, height, delay)

func _run_column_lift(x: int, height: int, delay: float) -> void:
	for y in height:
		tile_map.erase_cell(0, Vector2i(x, y))
		await get_tree().create_timer(delay).timeout



func spiral_positions(width: int, height: int) -> Array:
	var positions: Array = []
	var x_min = 0
	var x_max = width - 1
	var y_min = 0
	var y_max = height - 1

	while x_min <= x_max and y_min <= y_max:
		for x in range(x_min, x_max + 1):
			positions.append(Vector2i(x, y_min))
		for y in range(y_min + 1, y_max + 1):
			positions.append(Vector2i(x_max, y))
		if y_min < y_max:
			for x in range(x_max - 1, x_min - 1, -1):
				positions.append(Vector2i(x, y_max))
		if x_min < x_max:
			for y in range(y_max - 1, y_min, -1):
				positions.append(Vector2i(x_min, y))

		x_min += 1
		x_max -= 1
		y_min += 1
		y_max -= 1

	return positions






func cover_screen_spiral():
	transition_speed = 0.001
	var size = Vector2i(get_viewport().size / 32)
	var spiral = spiral_positions(size.x, size.y)
	for pos in spiral:
		tile_map.set_cell(0, pos, 0, Vector2i(0, 0))
		await get_tree().create_timer(transition_speed).timeout

func uncover_screen_spiral():
	transition_speed = 0.001
	var size = Vector2i(get_viewport().size / 32)
	var spiral = spiral_positions(size.x, size.y)
	for pos in spiral:
		tile_map.erase_cell(0, pos)
		await get_tree().create_timer(transition_speed).timeout


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


#Flake Animation -------
func cover_screen_flakes():
	var size = Vector2i(get_viewport().size / 32)
	
	var all_tiles = []
	for y in range(size.y):
		for x in range(size.x):
			all_tiles.append(Vector2i(x,y))
			
	all_tiles.shuffle()
	
	for pos in all_tiles:
		tile_map.set_cell(0, pos, 0, Vector2i(0,0))
		if transition_speed > 0:
			await get_tree().create_timer(transition_speed * 0.01).timeout
