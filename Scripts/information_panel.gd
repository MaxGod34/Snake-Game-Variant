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


var gps_history: Array[float] = []
var graph_points: PackedVector2Array = PackedVector2Array()
var smoothed_gps: float = 0.0
var wave_phase: float = 0.0

const MAX_POINTS: int = 50
const MAX_GRAPH_HEIGHT: float = 50.0
var previous_gps: float = 0.0
var gps_trend: float = 0.0

func _ready():
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Shaders/gps_line.gdshader")
	gps_graph.material = mat

func _process(delta: float) -> void:
	if gps_history.is_empty():
		return
	
	var slither_speed: float = clampf(3.0 + smoothed_gps * 0.2, 3.0, 14.0)
	wave_phase = fmod(wave_phase + delta * slither_speed, TAU)
	
	var count := gps_history.size()
	if graph_points.size() != count:
		graph_points.resize(count)
	
	for i in range(count):
		var g: float = gps_history[i]
		var normalized_h: float = clampf(log(1.0 + g) / log(101.0), 0.0, 1.0)
		var base_y: float = -normalized_h * MAX_GRAPH_HEIGHT
	
		var wiggle_amp: float = clampf(log(1.0 + g) * 2.2, 0.0, 8.0)
		var wiggle: float = sin(i * 0.35 - wave_phase) * wiggle_amp
		graph_points[i] = Vector2(i * 6.0, base_y + wiggle)
	
	gps_graph.points = graph_points

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
	
	
	
	
	# --- Update GPS Data & Shader ---
	var raw_gps: float = data["current_gps"]
	smoothed_gps = lerpf(smoothed_gps, raw_gps, 0.25)
	gps_label.text = "%.1f / sec <- GPS" % smoothed_gps

	var intensity: float = clampf(smoothed_gps / 10.0, 0.0, 1.0)
	gps_graph.material.set_shader_parameter("intensity", intensity)
	gps_graph.material.set_shader_parameter("base_color", Color.GREEN)

	gps_history.append(smoothed_gps)
	if gps_history.size() > MAX_POINTS:
		gps_history.pop_front()
