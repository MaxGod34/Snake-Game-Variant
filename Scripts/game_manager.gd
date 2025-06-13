extends Node



#------Session State---------#
var chosen_difficulty = "normal"
var chosen_class = "speedster"

#------Garden Progression----#
var current_garden = 1
var garden_data = {
	1: {"name": "The First Coil", "score_goal": 50},
	2: {"name": "Maximum Over-Bite", "score_goal": 125},
	3: {"name": "The Juice Box", "score_goal": 250},
	4: {"name": "The Forked Tongue Bistro", "score_goal": 420},
	5: {"name": "The Garden of Eatin'", "score_goal": 666}
}
#--------Perimeter Upgrade Sizes-------#
var grid_size_data = [
	Vector2(20, 15), # Level 0
	Vector2(24, 18), # Level 1
	Vector2(28, 21), # Level 2
	Vector2(32, 24), # Level 3
	Vector2(40, 30)  # Level 4 (MAX)
]
#-----Player Stats--------#
var player_level = 1
var skill_points = 0
var score_needed_for_next_level = 5
var score_at_level_start = 0

#----Upgrade Data Tracking----#
var speed_upgrade_level = 0
var fruit_reward = 1
var max_fruits_on_screen = 1
		#--------Burrow Uprade Shit--------#
var burrow_level = 0
var burrow_charges = 0
		#-------New Phase Shift Upgrade Shit------#
var phase_shift_level = 0
var phase_shift_charges = 0
		#-------Perimeter Upgrade Shit-----------#
var grid_size_level = 0

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

#----Active Ability Flags----#
var burrow_is_active = false
var is_phasing = false 

# Dictionary for upgrades costs and rules
var upgrade_data = {
	"increase_speed": {
		"display_name": "Slighter Sauce",
		"costs": [1, 1, 2, 2, 3, 3, 4, 4, 5, 5], 
		"max_level": 10
	},
	"increase_fruit_reward": {
		"display_name": "Elephant-Sized Portions",
		"costs": [1, 1, 2, 2, 3, 3, 4, 4, 5, 5],
		"max_level": 10
	},
	"increase_max_fruits": {
		"display_name": "More Mice!",
		"costs": [2, 2, 4, 4, 6, 6, 8, 8, 10, 10],
		"max_level": 10
	},
	"increase_burrow_charges": { # Changed from "unlock_burrow"
		"display_name": "Burrow Ability",
		"costs": [5, 5, 5], # Cost for each additional charge
		"max_level": 3
	},
	"increase_phase_charges": {
		"display_name": "Phase Shift Ability",
		"costs": [3, 4, 5],
		"max_level": 3
	},
	"increase_grid_size": {
		"display_name": "Edge Lord",
		"costs": [3, 6, 9, 12],
		"max_level": 4
	}
}



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
	burrow_charges = 0
	burrow_level = 0
	phase_shift_level = 0
	phase_shift_level = 0
	
	SceneTransition.transition_to("res://Scenes/main.tscn")
	get_tree().paused = false
	
