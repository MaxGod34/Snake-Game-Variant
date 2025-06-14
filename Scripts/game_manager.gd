extends Node

#------Session State---------#
var chosen_difficulty = "viper"
var chosen_class = "speedster"

#------Garden Progression----#
var has_died_this_garden = false
var current_garden = 1
var garden_data = {
	1: {"name": "The First Coil", "score_goal": 50},
	2: {"name": "Maximum Over-Bite", "score_goal": 125},
	3: {"name": "The Juice Box", "score_goal": 250},
	4: {"name": "The Forked Tongue Bistro", "score_goal": 420},
	5: {"name": "The Garden of Eatin'", "score_goal": 666}
}



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
	#-------Extra Life Shit-------------#
var extra_lives = 0
	#----Active Ability Flags----#
var burrow_is_active = false
var is_phasing = false 
	#--------Perimeter Upgrade Sizes-------#
var grid_size_data = [
	Vector2(20, 15), # Level 0
	Vector2(24, 18), # Level 1
	Vector2(28, 21), # Level 2
	Vector2(32, 24), # Level 3
	Vector2(40, 30)  # Level 4 (MAX)
]
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#
#|||||||||||||||||||||||||||||||||||||#
#_____________________________________#

#---------Difficulty parameters-------#
var difficulty_data = {
	"hatchling": {	#Easy
		"name": "Hatchling",
		"speed_multiplier": 1.1,  # Slower snake (higher wait_time)
		"goal_multiplier": 0.8,   # Shorter garden goals
		"sp_cost_modifier": 0,    # Upgrades cost the normal amount
		"starting_sp": 5          # Start with 5 free skill points!
	},
	"viper": {	#Medium
		"name": "Viper",
		"speed_multiplier": 1.0,  # Normal speed
		"goal_multiplier": 1.0,   # Normal garden goals
		"sp_cost_modifier": 1,    # Upgrades cost +1 SP
		"starting_sp": 0
	},
	"basilisk": {	#Hard
		"name": "Basilisk",
		"speed_multiplier": 0.8,  # Faster snake
		"goal_multiplier": 1.25,  # Longer garden goals
		"sp_cost_modifier": 2,    # Upgrades cost +2 SP
		"starting_sp": 0
	}
}
#---------CLASS PARAMETERS--------#
var class_data = {
	"speedster": {
		"name": "Speedster",
		"description": "Starts fast. Speed upgrades are more effective. Defensive upgrades are more expensive.",
		"start_length": 1,
		"start_speed": 0.18,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.85, # Very good
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_speed": 0,          # Normal cost
			"increase_fruit_reward": 0,
			"increase_max_fruits": 0,
			"increase_burrow_charges": 1, # +1 SP cost
			"increase_phase_charges": 1,  # +1 SP cost
			"increase_grid_size": 2,      # +2 SP cost
			"buy_extra_life": 2           # +2 SP cost
		}
	},
	"warlock": {
		"name": "Warlock",
		"description": "Grows faster by default. Fruit-based upgrades are cheaper.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 2, # Starts with a better reward
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 2, # Very good
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_speed": 0,
			"increase_fruit_reward": -1,  # -1 SP cost (minimum of 1)
			"increase_max_fruits": -1,    # -1 SP cost (minimum of 1)
			"increase_burrow_charges": 1,
			"increase_phase_charges": 1,
			"increase_grid_size": 0,
			"buy_extra_life": 1
		}
	},
	"inchworm": {
		"name": "Inchworm",
		"description": "Starts long and slow. Defensive and world-expanding upgrades are cheaper.",
		"start_length": 5,
		"start_speed": 0.3,
		"start_fruit_reward": 1,
		"start_max_fruits": 2,
		"start_lives": 0,
		"speed_upgrade_mod": 0.98, # Very bad
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_speed": 1,          # + 1 SP
			"increase_fruit_reward": -1,  # Cheaper 1 (min. 1)
			"increase_max_fruits": 0,
			"increase_burrow_charges": 1, # +1 SP cost
			"increase_phase_charges": 1,  # +1 SP cost
			"increase_grid_size": -1,      # Cheaper 1 (min. 1)
			"buy_extra_life": 2           # +2 SP cost
		}
	},
	"phoenix_coil": {
		"name": "Phoenix Coil",
		"description": "Starts with an extra life. Can purchase more lives cheaply.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 1, # Starts with an extra life!
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_speed": 1,
			"increase_fruit_reward": 1,
			"increase_max_fruits": 0,
			"increase_burrow_charges": 0,
			"increase_phase_charges": 0,
			"increase_grid_size": 1,
			"buy_extra_life": -5 # Makes the 10 SP cost only 5
		}
	},
	"sidewinder": {
		"name": "Sidewinder",
		"description": "A trickster. Every time you use an ability, there's a 25% chance the charge is not consumed.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_speed": 1,
			"increase_fruit_reward": 1,
			"increase_max_fruits": 0,
			"increase_burrow_charges": -3,
			"increase_phase_charges": -1,
			"increase_grid_size": 1,
			"buy_extra_life": 0
		}
	},
	"the_zealot": {
		"name": "The Zealot",
		"description": "Cannot gain extra lives. Receives a massive +5 SP bonus for completing a Garden without dying.",
		"start_length": 1,
		"start_speed": 0.2,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0, # Cannot get more
		"speed_upgrade_mod": 0.9,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 5, # The big bonus!
		"cost_modifiers": {
			"increase_speed": -1,
			"increase_fruit_reward": 0,
			"increase_max_fruits": 1,
			"increase_burrow_charges": 0,
			"increase_phase_charges": 0,
			"increase_grid_size": 0,
			"buy_extra_life": 0
		}
	},
	"the_alchemist": {
		"name": "The Alchemist",
		"description": "Does not gain SP from leveling up. Every fruit has a 10% chance to grant 1 SP instead.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_speed": 0,
			"increase_fruit_reward": 0,
			"increase_max_fruits": -1,
			"increase_burrow_charges": -1,
			"increase_phase_charges": -1,
			"increase_grid_size": 2,
			"buy_extra_life": -1
		}
	}
}

# Dictionary for upgrades costs and rules
var upgrade_data = {
	"increase_speed": {
		"display_name": "Slither Sauce",
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
	},
	"buy_extra_life": {
		"display_name": "Mulligan Munchie",
		"costs": [3, 7, 10],
		"max_level": 3
	}
}

#----------FUNCTIONS-----------#
func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func start_game():
	var p_class_data = class_data[chosen_class]
	var diff_data = difficulty_data[chosen_difficulty]
	# Reset all stats for a new run
	player_level = 1
	skill_points = 0
	skill_points += diff_data["starting_sp"]	# add starting sp
	score_needed_for_next_level = 5
	score_at_level_start = 0
	current_garden = 1
	has_died_this_garden = false
	
	speed_upgrade_level = 0
	fruit_reward = p_class_data["start_fruit_reward"]
	max_fruits_on_screen = p_class_data["start_max_fruits"]
	grid_size_level = 0

	burrow_charges = 0
	burrow_level = 0
	phase_shift_level = 0
	phase_shift_level = 0
	extra_lives = 0
	extra_lives += p_class_data["start_lives"]
	
	SceneTransition.transition_to("res://Scenes/main.tscn")
	get_tree().paused = false
