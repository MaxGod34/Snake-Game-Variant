extends PanelContainer

# --- NODE REFERENCES ---
# Get references to all the labels and containers we need to update.
# Make sure these paths match THIS scene tree exactly!
@onready var run_timer_label = $HBoxContainer/GardenDataContainer/RunTimerLabel
@onready var combo_window_label = $HBoxContainer/GardenDataContainer/FrenzyMeter/ComboWindowLabel
@onready var combo_counter_label = $HBoxContainer/GardenDataContainer/FrenzyMeter/ComboCounterLabel
@onready var frenzy_meter_container = $HBoxContainer/GardenDataContainer/FrenzyMeter
@onready var garden_name_label = $HBoxContainer/GardenDataContainer/GardenStatus/GardenNameLabel
@onready var garden_goal_label = $HBoxContainer/GardenDataContainer/GardenStatus/GardenGoalLabel
@onready var gps_graph = $HBoxContainer/GardenDataContainer/GPSTracker/GraphLine
@onready var gps_label = $HBoxContainer/GardenDataContainer/GPSTracker/GPS
@onready var harvest_forecast_ui = $HBoxContainer/GardenDataContainer/HarvestForecastUI



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

		
	# --- Update Garden Status ---
	garden_name_label.text = "%s (Garden %s)" % [data["garden_name"], data["garden_number"]]
	var goal_text = "%s / %s <- Goal" % [data["current_score"], data["garden_goal"]]
	garden_goal_label.text = goal_text
	
	
	
	# --- NEW: Update Harvest Forecast ---
	# We check if the forecast data exists, and if so, pass it to our child UI
	if data.has("forecast_list") and GameManager.harvest_forecast_level > 0:
		harvest_forecast_ui.visible = true
		harvest_forecast_ui.update_forecast(
			data["forecast_list"],
			data["special_fruit_chance"],
			data["harvest_forecast_level"]
			)
	else:
		harvest_forecast_ui.visible = false
	
	
	
	# --- NEW: Update GPS Graph ---
	var current_gps: float = data["current_gps"]
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

	# Auto-scale Y-axis so the line never shoots out of the box (min ceiling of 10 GPS)
	var peak_gps: float = max(10.0, gps_history.max())
	var max_graph_height: float = 50.0 # Adjust to match your GPSTracker container height
	var capped_wobble_amp: float = min(current_gps * 1.2, 10.0) # Never thrash more than 10px

	gps_graph.clear_points()
	for i in range(gps_history.size()):
		var normalized = gps_history[i] / peak_gps
		var y_pos = -normalized * max_graph_height
		var wobble = sin(i * 0.5 + Time.get_ticks_msec() * 0.01) * capped_wobble_amp
		gps_graph.add_point(Vector2(i * 3, y_pos + wobble))

	previous_gps = current_gps
