extends CanvasLayer

var transition_speed: float

@onready var tile_map = $TileMap
@onready var input_blocker = $InputBlocker

var frozen_columns = 0
var melted_columns = 0
var total_columns = 0

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
		choice = ["checkerboard","curtains", "diagonal", "drip","explode_in","ice_melt"].pick_random()
	
	match choice:
		"checkerboard":
			await cover_screen_checkerboard()
		"curtains":
			await cover_screen_curtains()
		"diagonal":
			await cover_screen_diagonal()
		"drip":
			await cover_screen_drip()
		"explode_in":
			await cover_screen_explode_in()
		"ice_melt":
			await cover_screen_ice_melt()
		"spiral":
			await cover_screen_spiral()
		"flakes":
			await cover_screen_flakes()

func uncover_screen(animation_type: String):
	var choice = animation_type
	if choice == "random":
		choice = ["curtains", "diagonal", "drip","explode_in","ice_melt"].pick_random()
	
	match choice:
		"checkerboard":
			await uncover_screen_checkerboard()
			input_blocker.hide()
		"curtains":
			await uncover_screen_curtains()
			input_blocker.hide()
		"diagonal":
			await uncover_screen_diagonal()
			input_blocker.hide()
		"drip":
			await uncover_screen_drip()
			input_blocker.hide()
		"explode_in":
			await uncover_screen_explode_in()
			input_blocker.hide()
		"ice_melt":
			await uncover_screen_ice_melt()
			input_blocker.hide()
		"spiral":
			await uncover_screen_spiral()
			input_blocker.hide()



func cover_screen_drip():
	var size = Vector2i(get_viewport().size / 32)
	var column_delay = 0.02
	var fall_delay = 0.01

	for x in range(size.x - 1, -1, -1):  # REVERSED here
		await get_tree().create_timer(column_delay).timeout
		start_column_drip(x, size.y, fall_delay)

	var total_time = (size.x - 1) * column_delay + (size.y - 1) * fall_delay
	await get_tree().create_timer(total_time - 0.5).timeout

func start_column_drip(x: int, height: int, delay: float) -> void:
	_run_column_drip(x, height, delay)

func _run_column_drip(x: int, height: int, delay: float) -> void:
	for y in height:
		tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		await get_tree().create_timer(delay).timeout

func uncover_screen_drip():
	var size = Vector2i(get_viewport().size / 32)
	var column_delay = 0.02
	var fall_delay = 0.01

	for x in range(size.x - 1, -1, -1):  # REVERSED here
		await get_tree().create_timer(column_delay).timeout
		start_column_lift(x, size.y, fall_delay)

	var total_time = (size.x - 1) * column_delay + (size.y - 1) * fall_delay
	await get_tree().create_timer(total_time - 0.5).timeout


func start_column_lift(x: int, height: int, delay: float) -> void:
	_run_column_lift(x, height, delay)

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
	transition_speed = 0.2
	var size = Vector2i(get_viewport().size / 32)
	var spiral = spiral_positions(size.x, size.y)
	var batch_size = 2  # You can tweak this value for speed vs smoothness

	for i in range(0, spiral.size(), batch_size):
		for j in range(batch_size):
			if i + j < spiral.size():
				var pos = spiral[i + j]
				tile_map.set_cell(0, pos, 0, Vector2i(0, 0))
		await get_tree().process_frame
		print(transition_speed, "Current Wait time")

func uncover_screen_spiral():
	transition_speed = 0.2
	var size = Vector2i(get_viewport().size / 32)
	var spiral = spiral_positions(size.x, size.y)
	var batch_size = 2

	for i in range(0, spiral.size(), batch_size):
		for j in range(batch_size):
			if i + j < spiral.size():
				var pos = spiral[i + j]
				tile_map.erase_cell(0, pos)
		await get_tree().process_frame


# --- Diagonal Animation ---
func cover_screen_diagonal():
	var size = Vector2i(get_viewport().size / 32)
	var max_steps = size.x + size.y - 1
	var drip_delay_frames = 3  # how many frames between diagonals

	var diagonals = []

	for step in range(max_steps):
		var current = []
		for x in range(step + 1):
			var y = step - x
			if x < size.x and y < size.y:
				current.append(Vector2i(x, y))
		diagonals.append(current)

	# Apply the diagonals with fake "drip" effect by staggering delays
	for diag in diagonals:
		for pos in diag:
			tile_map.set_cell(0, pos, 0, Vector2i(0, 0))
		# fake drip effect by pausing every few diagonals
		for i in range(drip_delay_frames):
			await get_tree().process_frame

func uncover_screen_diagonal():
	var size = Vector2i(get_viewport().size / 32)
	var max_steps = size.x + size.y - 1
	var drip_delay_frames = 3  # how many frames between diagonals

	var diagonals = []

	for step in range(max_steps):
		var current = []
		for x in range(step + 1):
			var y = step - x
			if x < size.x and y < size.y:
				current.append(Vector2i(x, y))
		diagonals.append(current)

	# Apply the diagonals with fake "drip" effect by staggering delays
	for diag in diagonals:
		for pos in diag:
			tile_map.erase_cell(0, pos)
		# fake drip effect by pausing every few diagonals
		for i in range(drip_delay_frames):
			await get_tree().process_frame


#Flake Animation -------
func cover_screen_flakes():
	transition_speed = 0.01  # Optional, for pacing
	var size = Vector2i(get_viewport().size / 32)
	var all_tiles: Array = []

	for y in range(size.y):
		for x in range(size.x):
			all_tiles.append(Vector2i(x, y))
			
	all_tiles.shuffle()

	var batch_size = 3  # Tweak this to balance speed vs smoothness

	for i in range(0, all_tiles.size(), batch_size):
		for j in range(batch_size):
			if i + j < all_tiles.size():
				var pos = all_tiles[i + j]
				tile_map.set_cell(0, pos, 0, Vector2i(0, 0))
		await get_tree().process_frame


func cover_screen_checkerboard():
	var size = Vector2i(get_viewport().size / 32)
	var phases = [[], []]  # Two empty arrays for the two phases
	
	# Build the phases arrays manually
	for y in range(size.y):
		for x in range(size.x):
			if (x + y) % 2 == 0:
				phases[0].append(Vector2i(x, y))
			else:
				phases[1].append(Vector2i(x, y))
	
	# Randomize starting direction for cover
	var direction = randi() % 8  # 0=top, 1=right, 2=bottom, 3=left, 4=top-left, 5=top-right, 6=bottom-left, 7=bottom-right
	_sort_phases_by_direction(phases, direction)
	
	# Apply the checkerboard pattern in chunks
	for group in phases:
		var chunk_size = 10
		for i in range(0, group.size(), chunk_size):
			for j in range(min(chunk_size, group.size() - i)):
				tile_map.set_cell(0, group[i + j], 0, Vector2i(0, 0))
			await get_tree().process_frame

func uncover_screen_checkerboard():
	var size = Vector2i(get_viewport().size / 32)
	var phases = [[], []]  # Two empty arrays for the two phases
	
	# Build the phases arrays manually
	for y in range(size.y):
		for x in range(size.x):
			if (x + y) % 2 == 0:
				phases[0].append(Vector2i(x, y))
			else:
				phases[1].append(Vector2i(x, y))
	
	# Randomize starting direction for uncover (different from cover)
	var direction = randi() % 8  # 0=top, 1=right, 2=bottom, 3=left, 4=top-left, 5=top-right, 6=bottom-left, 7=bottom-right
	_sort_phases_by_direction(phases, direction)
	
	# Remove the checkerboard pattern in chunks
	for group in phases:
		var chunk_size = 10
		for i in range(0, group.size(), chunk_size):
			for j in range(min(chunk_size, group.size() - i)):
				tile_map.erase_cell(0, group[i + j])
			await get_tree().process_frame

# Helper function to sort phases by direction
func _sort_phases_by_direction(phases: Array, direction: int):
	for phase in phases:
		match direction:
			0: # Top to bottom
				phase.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
			1: # Right to left
				phase.sort_custom(func(a, b): return a.x > b.x or (a.x == b.x and a.y < b.y))
			2: # Bottom to top
				phase.sort_custom(func(a, b): return a.y > b.y or (a.y == b.y and a.x > b.x))
			3: # Left to right
				phase.sort_custom(func(a, b): return a.x < b.x or (a.x == b.x and a.y < b.y))
			4: # Top-left to bottom-right
				phase.sort_custom(func(a, b): return (a.x + a.y) < (b.x + b.y) or ((a.x + a.y) == (b.x + b.y) and a.x < b.x))
			5: # Top-right to bottom-left
				phase.sort_custom(func(a, b): return (a.x - a.y) > (b.x - b.y) or ((a.x - a.y) == (b.x - b.y) and a.x > b.x))
			6: # Bottom-left to top-right
				phase.sort_custom(func(a, b): return (a.x - a.y) < (b.x - b.y) or ((a.x - a.y) == (b.x - b.y) and a.x < b.x))
			7: # Bottom-right to top-left
				phase.sort_custom(func(a, b): return (a.x + a.y) > (b.x + b.y) or ((a.x + a.y) == (b.x + b.y) and a.x > b.x))

func cover_screen_curtains():
	var size = Vector2i(get_viewport().size / 32)
	var column_delay = 0.02
	var fall_delay = 0.01
	var center_x = size.x / 2
	
	# Create a wavy curtain effect
	for x in range(size.x):
		var distance_from_center = abs(x - center_x)
		var wave_delay = sin(distance_from_center * 0.5) * 0.05 # Add some wave to the timing
		
		get_tree().create_timer(distance_from_center * column_delay + wave_delay).timeout.connect(
			func(): start_column_drip(x, size.y, fall_delay)
		)
	
	var total_time = center_x * column_delay + (size.y - 1) * fall_delay + 0.5
	await get_tree().create_timer(total_time).timeout

func uncover_screen_curtains():
	var size = Vector2i(get_viewport().size / 32)
	var column_delay = 0.02
	var fall_delay = 0.01
	var center_x = size.x / 2
	
	# Curtain opening from center outward
	for x in range(size.x):
		var distance_from_center = abs(x - center_x)
		var wave_delay = sin(distance_from_center * 0.5) * 0.25
		
		get_tree().create_timer(distance_from_center * column_delay + wave_delay).timeout.connect(
			func(): start_column_lift(x, size.y, fall_delay)
		)
	
	var total_time = center_x * column_delay + (size.y - 1) * fall_delay + 0.5
	await get_tree().create_timer(total_time).timeout

func cover_screen_explode_in():
	var size = Vector2i(get_viewport().size / 32)
	var center = size / 2
	var all_tiles = []

	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2i(x, y)
			var dist = pos.distance_to(center)
			all_tiles.append({"pos": pos, "dist": dist + randf() * 4.0})  # Add jitter

	all_tiles.sort_custom(func(a, b): return a["dist"] < b["dist"])

	var batch_size = 6
	for i in range(0, all_tiles.size(), batch_size):
		for j in range(batch_size):
			if i + j < all_tiles.size():
				tile_map.set_cell(0, all_tiles[i + j]["pos"], 0, Vector2i(0, 0))
		await get_tree().process_frame
func uncover_screen_explode_in():
	var size = Vector2i(get_viewport().size / 32)
	var center = size / 2
	var all_tiles = []

	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2i(x, y)
			var dist = pos.distance_to(center)
			all_tiles.append({"pos": pos, "dist": dist + randf() * 4.0})

	all_tiles.sort_custom(func(a, b): return a["dist"] < b["dist"])

	var batch_size = 6
	for i in range(0, all_tiles.size(), batch_size):
		for j in range(batch_size):
			if i + j < all_tiles.size():
				tile_map.erase_cell(0, all_tiles[i + j]["pos"])
		await get_tree().process_frame

func cover_screen_ice_melt():
	var size = Vector2i(get_viewport().size / 32)
	var columns = []

	for x in range(size.x):
		columns.append(x)

	columns.shuffle()

	frozen_columns = 0
	total_columns = columns.size()
	var active_columns = 1

	for i in range(0, columns.size(), active_columns):
		for j in range(active_columns):
			if i + j < columns.size():
				start_column_freeze(columns[i + j], size.y)
		await get_tree().process_frame

	# Wait for all columns to finish before returning
	while frozen_columns < total_columns:
		await get_tree().process_frame


func start_column_freeze(x: int, height: int):
	call_deferred("_run_column_freeze", x, height)

func _run_column_freeze(x: int, height: int):
	for y in range(height):
		tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		await get_tree().process_frame
	frozen_columns += 1


func uncover_screen_ice_melt():
	var size = Vector2i(get_viewport().size / 32)
	var columns = []

	for x in range(size.x):
		columns.append(x)

	columns.shuffle()

	melted_columns = 0
	total_columns = columns.size()
	var active_columns = 1

	for i in range(0, columns.size(), active_columns):
		for j in range(active_columns):
			if i + j < columns.size():
				start_column_melt(columns[i + j], size.y)
		await get_tree().process_frame

	while melted_columns < total_columns:
		await get_tree().process_frame

func start_column_melt(x: int, height: int):
	call_deferred("_run_column_melt", x, height)

func _run_column_melt(x: int, height: int):
	for y in range(height):
		tile_map.erase_cell(0, Vector2i(x, y))
		await get_tree().process_frame
	melted_columns += 1
