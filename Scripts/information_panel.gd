extends PanelContainer

# --- NODE REFERENCES ---
# Get references to all the labels and containers we need to update.
# Make sure these paths match THIS scene tree exactly!
@onready var run_timer_label = $HBoxContainer/GardenDataContainer/RunTimerLabel
@onready var combo_window_label = $HBoxContainer/GardenDataContainer/FrenzyMeter/ComboWindowLabel
@onready var combo_counter_label = $HBoxContainer/GardenDataContainer/FrenzyMeter/ComboCounterLabel
@onready var frenzy_meter_container = $HBoxContainer/GardenDataContainer/FrenzyMeter
@onready var frenzy_hsep =$HBoxContainer/GardenDataContainer/CookbookUI/HSeparatorFrenzy 
@onready var cookbook_ui_container = $HBoxContainer/GardenDataContainer/CookbookUI
@onready var cookbook_hsep = $HBoxContainer/GardenDataContainer/HSeparatorCookbook
@onready var recipe_name_label = $HBoxContainer/GardenDataContainer/CookbookUI/RecipeNameLabel
@onready var ingredients_container = $HBoxContainer/GardenDataContainer/CookbookUI/IngredientsContainer
@onready var garden_name_label = $HBoxContainer/GardenDataContainer/GardenStatus/GardenNameLabel
@onready var garden_goal_label = $HBoxContainer/GardenDataContainer/GardenStatus/GardenGoalLabel
@onready var gps_graph = $HBoxContainer/GardenDataContainer/GPSTracker/GraphLine
@onready var gps_label = $HBoxContainer/GardenDataContainer/GPSTracker/GPS
@onready var harvest_forecast_ui = $HBoxContainer/GardenDataContainer/HarvestForecastUI
@onready var forecast_hsep = $HBoxContainer/GardenDataContainer/HSeparatorHarvest


var gps_history: Array = []
var previous_gps: float = 0.0
var gps_trend: float = 0.0

func _ready():
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Shaders/gps_line.gdshader")
	gps_graph.material = mat

	

# This is the master function that main.gd will call every frame.
# It takes all the current game data in one single dictionary.
func update_display(data: Dictionary):
	# --- Update Frenzy Meter ---
	
	run_timer_label.text = data["run_time_string"] + " <- Run Time"
	
	if data["sugar_rush_unlocked"]:
		frenzy_meter_container.visible = true
		frenzy_hsep.visible = true
		
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
	else:
		frenzy_meter_container.visible = false
		frenzy_hsep.visible = false
		
	# --- Update Garden Status ---
	garden_name_label.text = "%s (Garden %s)" % [data["garden_name"], data["garden_number"]]
	var goal_text = "%s / %s <- Goal" % [data["current_score"], data["garden_goal"]]
	garden_goal_label.text = goal_text
	
	# --- Update Cookbook ---
	# We now call our dedicated helper function to handle the complex recipe UI.
	update_recipe_display(data["active_recipe"], data["recipe_progress"])
	
	
	# --- NEW: Update Harvest Forecast ---
	# We check if the forecast data exists, and if so, pass it to our child UI
	if data.has("forecast_list") and GameManager.harvest_forecast_level > 0:
		forecast_hsep.visible = true
		harvest_forecast_ui.visible = true
		harvest_forecast_ui.update_forecast(
			data["forecast_list"],
			data["special_fruit_chance"],
			data["harvest_forecast_level"]
			)
	else:
		forecast_hsep.visible = false
		harvest_forecast_ui.visible = false
	
	
	
	# --- NEW: Update GPS Graph ---
	var current_gps = data["current_gps"]
	gps_label.text = "%s / sec <- GPS" % current_gps
	# --- THIS IS THE NEW LOGIC ---
	# 1. Determine the immediate direction of change (up, down, or stable).
	var intensity = clamp(current_gps / 10.0, 0.0, 1.0) # Max intensity at 10 GPS
	
	# 2. Pass the intensity AND the player's chosen color to the shader.
	# This is where the future customization will happen!
	gps_graph.material.set_shader_parameter("intensity", intensity)
	gps_graph.material.set_shader_parameter("base_color", Color.GREEN) # We can change this later
	
	# 4. Add the new GPS value to our history.
	gps_history.append(current_gps)
	if gps_history.size() > 100:
		gps_history.pop_front()
		
	# 5. Redraw the graph with the "shaky" line
	gps_graph.clear_points()
	for i in range(gps_history.size()):
		var gps_value = gps_history[i]
		var y_pos = -gps_value * 5
		var wobble = sin(i * 0.5 + Time.get_ticks_msec() * 0.01) * gps_value * 4.0 # OG: * 2
		y_pos += wobble
		gps_graph.add_point(Vector2(i * 3, y_pos))
		
	# 6. Remember the current GPS for the next frame's comparison
	previous_gps = current_gps

# --- This is the new, corrected helper function for the Cookbook ---
func update_recipe_display(recipe: Dictionary, progress: int):
	# First, check if the player has the cookbook unlocked.
	if not GameManager.the_cookbook_unlocked:
		cookbook_hsep.visible = false
		cookbook_ui_container.visible = false
		return # If not, hide the whole section and stop.
	
	# If they do have it, make sure the section is visible.
	cookbook_ui_container.visible = true
	cookbook_hsep.visible = true
	
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
		
		
		
	
