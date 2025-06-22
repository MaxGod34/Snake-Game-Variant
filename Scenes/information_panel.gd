extends PanelContainer

# --- NODE REFERENCES ---
# Get references to all the labels and containers we need to update.
# Make sure these paths match your scene tree exactly!
@onready var run_timer_label = $HBoxContainer/VBoxContainer/FrenzyMeter/RunTimerLabel
@onready var combo_window_label = $HBoxContainer/VBoxContainer/FrenzyMeter/ComboWindowLabel
@onready var combo_counter_label = $HBoxContainer/VBoxContainer/FrenzyMeter/ComboCounterLabel
@onready var cookbook_ui_container = $HBoxContainer/VBoxContainer/CookbookUI
@onready var recipe_name_label = $HBoxContainer/VBoxContainer/CookbookUI/RecipeNameLabel
@onready var ingredients_container = $HBoxContainer/VBoxContainer/CookbookUI/IngredientsContainer
@onready var garden_name_label = $HBoxContainer/GardenDataContainer/GardenStatus/GardenNameLabel
@onready var garden_goal_label = $HBoxContainer/GardenDataContainer/GardenStatus/GardenGoalLabel

# This is the master function that main.gd will call every frame.
# It takes all the current game data in one single dictionary.
func update_display(data: Dictionary):
	# --- Update Frenzy Meter ---
	run_timer_label.text = "Run Time: " + data["run_time_string"]
	
	if data["combo_is_active"]:
		combo_window_label.visible = true
		combo_window_label.text = "Combo Window: %.1f" % data["combo_window_time"]
	else:
		combo_window_label.visible = false
		
	if data["combo_count"] > 1:
		combo_counter_label.visible = true
		combo_counter_label.text = "x%s COMBO!" % data["combo_count"]
	else:
		combo_counter_label.visible = false
		
	# --- Update Garden Status ---
	garden_name_label.text = "%s (Garden %s/13)" % [data["garden_name"], data["garden_number"]]
	var goal_text = "Goal: %s / %s" % [data["current_score"], data["garden_goal"]]
	garden_goal_label.text = goal_text
	
	# --- Update Cookbook ---
	# We now call our dedicated helper function to handle the complex recipe UI.
	update_recipe_display(data["active_recipe"], data["recipe_progress"])

# --- This is the new, corrected helper function for the Cookbook ---
func update_recipe_display(recipe: Dictionary, progress: int):
	# First, check if the player has the cookbook unlocked.
	if not GameManager.the_cookbook_unlocked:
		cookbook_ui_container.visible = false
		return # If not, hide the whole section and stop.
	
	# If they do have it, make sure the section is visible.
	cookbook_ui_container.visible = true
	
	# Clear out any old ingredient icons from the previous frame.
	for child in ingredients_container.get_children():
		child.queue_free()
		
	# If there's no active recipe, just show a message and stop.
	if recipe.is_empty():
		recipe_name_label.text = "No Active Recipe"
		return
		
	# Display the recipe name.
	recipe_name_label.text = recipe["name"]
	
	# Now, loop through the ingredients and create an icon for each one.
	for i in range(recipe["sequence"].size()):
		var ingredient_data = recipe["sequence"][i]
		var ingredient_type_string = ingredient_data["type"]
		
		var icon = TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(24, 24)

		# Use a match statement to load the correct icon texture.
		# You MUST replace these paths with the actual paths to your icon files!
		match ingredient_type_string:
			"Fruit":
				icon.texture = preload("res://Assets/PNGs/snake_fruit_red.png")
			"GoldenFruit":
				icon.texture = preload("res://Assets/PNGs/golden_fruit_icon.png")
			"GhostPepper":
				icon.texture = preload("res://Assets/PNGs/ghost_pepper_icon.png")
			"JumpingBean":
				icon.texture = preload("res://Assets/PNGs/jumping_bean_icon.png")
			"IronCherry":
				icon.texture = preload("res://Assets/PNGs/iron_cherry_icon.png")
			"DragonFruit":
				icon.texture = preload("res://Assets/PNGs/dragon_fruit_icon.png")
			_:
				print("No icon found for ingredient type: ", ingredient_type_string)

		# If we've already completed this step, make the icon darker.
		if i < progress:
			icon.modulate = Color(0.3, 0.3, 0.3, 0.8) # Slightly transparent gray
			
		ingredients_container.add_child(icon)
