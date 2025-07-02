extends VBoxContainer

# --- NODE REFERENCES ---
@onready var icon_container = $IconContainer
@onready var chance_label = $ChanceLabel

# This is the master function that the Information Panel will call.
# It receives a list of the fruit types to display.
func update_forecast(forecast_list: Array, chance: float, level: int):
	# Update the percentage chance label
	chance_label.text = "(%.0f%% Special)" % (chance * 100)
	
	# Clear out any old icons
	for child in icon_container.get_children():
		child.queue_free()

	# If the forecast level is 0, do nothing else.
	if level <= 0:
		return
		
	# At level 4, we show the full forecast (up to 5 items).
	# At lower levels, we only show the special fruits from the list.
	var fruits_to_show = []
	if level >= 4:
		# The main.gd script already slices this to the first 5 for us.
		fruits_to_show = forecast_list.slice(0, 5)
	else:
		var count = 0
		for fruit_type in forecast_list:
			if fruit_type != "Fruit":
				fruits_to_show.append(fruit_type)
				count += 1
				if count >= level: # Show up to the number of fruits our level allows
					break

	# Now, loop through the CORRECT, filtered list and create the icons.
	for fruit_type_string in fruits_to_show:
		var icon = TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(24, 24)
		
		# Use a match statement to load the correct icon texture.
		match fruit_type_string:
			"GoldenFruit":
				icon.texture = preload("res://Assets/PNGs/golden_fruit_icon.png")
			"JumpingBean":
				icon.texture = preload("res://Assets/PNGs/jumping_bean_icon.png")
			"GhostPepper":
				icon.texture = preload("res://Assets/PNGs/ghost_pepper_icon.png")
			"IronCherry":
				icon.texture = preload("res://Assets/PNGs/iron_cherry_icon.png")
			"DragonFruit":
				icon.texture = preload("res://Assets/PNGs/dragon_fruit_icon.png")
			"Fruit":
				icon.texture = preload("res://Assets/PNGs/snake_fruit_red.png")
			
		icon_container.add_child(icon)
