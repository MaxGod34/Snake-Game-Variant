extends Node


var player_level = 1
var skill_points = 0
var score_needed_for_next_level = 5
var score_at_level_start = 0

var current_garden = 1
var garden_data = {
	1: {"name": "The First Step", "score_goal": 50},
	2: {"name": "The Growing Patch", "score_goal": 125},
	3: {"name": "The Sunken Grove", "score_goal": 250},
	4: {"name": "The Serpent's Maze", "score_goal": 420},
	5: {"name": "The Endless Eden", "score_goal": 666}
}

var chosen_difficulty = "normal"
var chosen_class = "speedster"
var difficulty_data = {
	"easy": {"speed_multiplier": 1.0, "goal_multiplier": 0.8},
	"normal": {"speed_multiplier": 1.0, "goal_multiplier": 0.9},
	"hard": {"speed_multiplier": 0.75, "goal_multiplier": 1.0}
}
var class_data = {
	"speedster": {
		"name": "Speedster",
		"start_length": 1,
		"start_speed": 0.2,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"speed_upgrade_mod": 0.9, #Better Speed Upgrade
		"reward_upgrade_mod": 1 #Normal Fruit reward upgrade
	},
	"warlock": {
		"name": "Warlock",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 2,   #better fruit reward off start
		"start_max_fruits": 1,
		"speed_upgrade_mod": 0.9, #Normal Speed Upgrade
		"reward_upgrade_mod": 2 #Much Better Fruit reward upgrade
	},
	"inchworm": {
		"name": "Inchworm",
		"start_length": 5, # Starts long
		"start_speed": 0.3, # Starts slow
		"start_fruit_reward": 1,
		"start_max_fruits": 2, # Start with more fruit on screen
		"speed_upgrade_mod": 0.95, # Upgrade modifiers unchanged/default
		"reward_upgrade_mod": 1
	}
}

var speed_upgrade_level = 0
var fruit_reward = 1
var max_fruits_on_screen = 1
#--------Burrow Uprade Shit--------#
var burrow_unlocked = false
var burrow_is_charged = false
var burrow_is_active = false


func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func start_game():
	var p_class_data = class_data[chosen_class]
	# Reset all stats for a new run
	player_level = 1
	skill_points = 0
	score_needed_for_next_level = 5
	score_at_level_start = 0
	current_garden = 1
	
	speed_upgrade_level = 0
	fruit_reward = p_class_data["start_fruit_reward"]
	max_fruits_on_screen = p_class_data["start_max_fruits"]
	#--------Burrow Uprade Shit--------#
	burrow_unlocked = false
	burrow_is_charged = false
	burrow_is_active = false
	
	get_tree().paused = false
	go_to_scene("res://Scenes/main.tscn")
