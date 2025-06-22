extends Node

#------Session State---------#
var chosen_difficulty = "viper"
var chosen_class = "speedster"
var run_time: float = 0.0
#------Garden Progression----#
var has_died_this_garden = false
var current_garden = 1
var garden_data = {
	# --- The Early Game (Learning the Ropes) ---
	1: {"name": "The First Coil", "score_goal": 20, "obstacle_count": 0},
	2: {"name": "The Juice Box", "score_goal": 35, "obstacle_count": 3},
	3: {"name": "The Danger Noodle Den", "score_goal": 55, "obstacle_count": 5},
	
	# --- The Mid-Game (Testing Your Build) ---
	4: {"name": "The Forked Tongue Bistro", "score_goal": 80, "obstacle_count": 8},
	5: {"name": "Rhythm & Haste", "score_goal": 110, "obstacle_count": 10},
	6: {"name": "The Architect's Grid", "score_goal": 150, "obstacle_count": 12},
	7: {"name": "The Razor's Edge", "score_goal": 200, "obstacle_count": 15},

	# --- The Late Game (Mastering Your Path) ---
	8: {"name": "The Glitch Garden", "score_goal": 260, "obstacle_count": 20},
	9: {"name": "The Basilisk's Lair", "score_goal": 330, "obstacle_count": 25},
	10: {"name": "The Kill Screen Quarry", "score_goal": 410, "obstacle_count": 30},
	
	# --- The Endgame (The Final Challenge) ---
	11: {"name": "The Apex Arena", "score_goal": 500, "obstacle_count": 35},
	12: {"name": "The Endless Labyrinth", "score_goal": 500, "obstacle_count": 40},
	13: {"name": "The Garden of Eatin'", "score_goal": 666, "obstacle_count": 50}
}

var garden_bonus_data = {
	"par_time": {"base_reward": 50, "time_limit": 60.0}, # 50 Scales if garden is beaten in under 60s
	"no_death": {"reward": 25}, # 25 Scales for a flawless, no-death garden
	"ascetic": {"reward": 50}, # 100 Scales if no upgrades were purchased this garden
	"pacifist": {"reward": 15}, # 15 Scales if no active abilities were used
	"engagement": {"reward": 2} # +2 Scales for every SP spent on upgrades this garden
}


#-----Player Stats--------#
var player_level = 1
var juice = 0
var pulp = 0
var score_needed_for_next_level = 5
var score_at_level_start = 0
var fruits_eaten_this_run: int = 0
var total_juice_this_run: int = 0
var segments_to_restore = 0

# --- BONUS TRACKING VARS ---
var juice_spent_this_garden = 0
var abilities_used_this_garden = 0
var garden_start_time = 0.0

#----Upgrade Data Tracking----#
var fruit_reward = 1
var max_fruits_on_screen = 1

# --- "PULP" META-UPGRADE LEVELS ---
var synapse_slots_unlocked: int = 2 # Start with 2 slots by default
var serpents_coffer_level: int = 0
var serpents_coffer_data = [0.0, 0.05, 0.10, 0.15, 0.20]
var geode_compass_level: int = 0
var geomancers_compass_data = [1.0, 0.9, 0.8, 0.7, 0.6] # % of rocks left
var four_leaf_clover_level: int = 0
var four_leaf_clover_data = [0.0, 0.02, 0.04, 0.07, 0.10] # + % on all luck
var chroma_scales_level: int = 0


	#----Active Ability Flags----#
var burrow_is_active = false
var is_phasing = false 
var is_bounty_active = false
var autotomy_is_active = false
var is_zenith_active = false
var iron_cherry_buff_active = false
var dragon_fruit_buff_active = false

#------The Planner-------#
var diet_slith_level = 0
var fruit_foresight_unlocked = false
var geological_survey_unlocked = false
var sovereign_trail_level = 0
var meditative_state_level = 0
var meditative_state_charges = 0
var meditative_data = [0.0, 2.0, 3.0, 5.0]
var garden_weaver_unlocked = false
var garden_weaver_used_this_garden = false

#-----------THE GLUTTON----------------#
var es_portions_level = 0
var more_mice_level = 0
var golden_seeds_level = 0
var golden_seeds_data = [
	{"chance": 0.0, "reward": 0},
	{"chance": 0.05, "reward": 1},
	{"chance": 0.1, "reward": 1},
	{"chance": 0.2, "reward": 3},
	{"chance": 0.33, "reward": 3}
]
var patient_gardener_level = 0
var patient_gardener_data = [
	{}, # Level 0
	{"time": 10.0, "multiplier": 2}, # Level 1
	{"time": 7.0, "multiplier": 2},  # Level 2
	{"time": 5.0, "multiplier": 3}   # Level 3
]
var banana_bounty_charges = 0
var banana_bounty_level = 0
var the_satchel_unlocked = false

#----------ACROBAT PATH-----#
var slither_sauce_level = 0 
var tenderizer_level = 0
var tenderizer_charges = 0
var juke_and_jive_unlocked = false
var afterburner_level = 0
var afterburner_data = [
	{}, # Level 0 does nothing
	{"boost": 0.75, "duration": 2.0}, # Level 1: 25% faster for 2s
	{"boost": 0.60, "duration": 2.5}, # Level 2: 40% faster for 2.5s
	{"boost": 0.50, "duration": 3.0}  # Level 3: 50% faster for 3s
]
var pop_rocks_unlocked = false
var autotomy_unlocked = false
var autotomy_used_this_garden = false

#------------THE ARCHITECT-----------#
var edge_lord_level = 0
var edge_lord_data = [
	Vector2(20, 15), # Level 0
	Vector2(24, 18), # Level 1
	Vector2(28, 21), # Level 2
	Vector2(32, 24), # Level 3
	Vector2(36, 27), # Level 4
	Vector2(40, 30)  # Level 5
]
var zoning_ordinance_level = 0
var border_czar_unlocked = false
var surveyed_land_unlocked = false
var burrow_level = 0
var burrow_charges = 0
var pocket_garden_level = 0
var pocket_garden_charges = 0
var pocket_garden_data = [
	{}, # Level 0
	{"cost": 10, "duration": 20.0}, # Level 1
	{"cost": 20, "duration": 30.0}, # Level 2
	{"cost": 30, "duration": 60.0}  # Level 3
]
var active_pocket_garden_rect = null
# Ultimate Keystones
var fold_space_unlocked = false
var masters_blueprint_unlocked = false
var shatter_reality_unlocked = false
#------------------------------------#
#---------SURVIVOR PATH----------#
var extra_lives = 0
var phoenix_dawn_unlocked = false
var last_stand_unlocked = false
var sacrificial_molt_used_this_run = false
var sacrificial_molt_unlocked = false
var death_defied_unlocked = false
var martyrdom_unlocked = false
var times_died_this_run = 0
var new_game_s_plus_active = false 

#-----------#illusionist------------#
var ghost_tail_level = 0
var ghost_tail_data = [0, 7, 10, 15, 20, 34] # Lvl 0, 1, 2, 3, 4, 5
var phase_shift_level = 0
var phase_shift_charges = 0
var blink_level = 0
var blink_charges = 0
var three_card_monty_unlocked = false
var fractured_self_unlocked = false
var dazzle_pie_unlocked = false

# --- Frenzy Path ---
var sugar_rush_unlocked = false
var chain_reaction_level = 0
var chain_reaction_data = [1, 5, 10, 999] # Lvl 0, 1, 2, 3
var overdrive_level = 0
var lingering_rush_level = 0
var lingering_rush_data = [5.0, 5.5, 6.0, 6.5, 7.0, 7.5]
var juggernaut_unlocked = false
var zenith_unlocked = false
var zenith_charges = 0
# track the combo itself
var current_combo = 0
var combo_is_pure = true


# --- Geomancer Path ---
var fertile_ground_level = 0
var mineral_rich_soil_level = 0
var tectonic_shift_level = 0
var heavy_foundation_level = 0
# We need to know which Rockeater upgrade they chose
var rockeater_type = "" # e.g., "Rockmuncher", "Geode Cracker", etc.
var calculated_risk_unlocked = false

# --- Chef Path ---
var golden_seed_extract_level = 0
var golden_seed_extract_data = [0.0, 0.05, 0.10, 0.15]
var exotic_seeds_level = 0
var exotic_seeds_data = [
	"", # Level 0 - Nothing
	"jumping_bean", # Level 1
	"ghost_pepper", # Level 2
	"iron_cherry",  # Level 3
	"dragon_fruit", # Level 4
	"boost_chance"  # Level 5
]
var the_cookbook_unlocked = false
var active_recipe: Dictionary = {} # Will hold the current recipe's data
var recipe_progress: int = 0      # Tracks which step of the recipe we're on
var expanded_palate_unlocked = false
var golden_glaze_unlocked = false
var custom_cuisine_unlocked = false
var mise_en_place_used_this_run = false
var mise_en_place_unlocked = false

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
		"starting_sp": 69,          # Start with 5 free skill points!
		"start_slots": 10
	},
	"viper": {	#Medium
		"name": "Viper",
		"speed_multiplier": 1.0,  # Normal speed
		"goal_multiplier": 1.0,   # Normal garden goals
		"sp_cost_modifier": 1,    # Upgrades cost +1 SP
		"starting_sp": 0,
		"start_slots": 8
	},
	"basilisk": {	#Hard
		"name": "Basilisk",
		"speed_multiplier": 0.8,  # Faster snake
		"goal_multiplier": 1.25,  # Longer garden goals
		"sp_cost_modifier": 2,    # Upgrades cost +2 SP
		"starting_sp": 0,
		"start_slots": 2
	}
}
#---------CLASS PARAMETERS--------#
var class_data = {
	"speedster": {
		"name": "Speedster",
		"description": "Starts fast.\nSpeed upgrades are more effective.\nDefensive upgrades are more expensive.",
		"start_length": 1,
		"start_speed": 0.18,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.85, # Very good
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	},
	"warlock": {
		"name": "Warlock",
		"description": "Grows faster by default.\nFruit-based upgrades are cheaper.",
		"start_length": 1,
		"start_speed": 0.25,
		"start_fruit_reward": 2, # Starts with a better reward
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 2, # Very good
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": -1, "more_mice": -1, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	},
	"inchworm": {
		"name": "Inchworm",
		"description": "Starts long and slow.\nDefensive and world-expanding upgrades are cheaper.",
		"start_length": 5,
		"start_speed": 0.3,
		"start_fruit_reward": 1,
		"start_max_fruits": 2,
		"start_lives": 0,
		"speed_upgrade_mod": 0.98, # Very bad
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	},
	"phoenix_coil": {
		"name": "Phoenix Coil",
		"description": "Starts with an extra life.\nCan purchase more lives cheaply.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 1, # Starts with an extra life!
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	},
	"sidewinder": {
		"name": "Sidewinder",
		"description": "A trickster. Every time you use an ability,\nthere's a 25% chance the charge is not consumed.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
			
			
		}
	},
	"the_zealot": {
		"name": "The Zealot",
		"description": "Cannot gain extra lives.\nReceives a massive +5 Juice bonus for completing a Garden without dying.",
		"start_length": 1,
		"start_speed": 0.2,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0, # Cannot get more
		"speed_upgrade_mod": 0.9,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 5, # The big bonus!
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	},
	"the_alchemist": {
		"name": "The Alchemist",
		"description": "Does not gain Juice from leveling up. Every fruit has a 10% chance to grant 1 Juice instead.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#-----GEODE/GEOMANCER Modifiers-----#
			"Fertile Ground": 0, "Mineral Rich Soil": 0, "Tectonic Shift": 0,
			"Heavy Foundation": 0, "Rockmuncher": 0, "Geode Cracker": 0, 
			"Kinetic Feast": 0, "Stones Burden": 0, "Calculated Risk": 0,
			#Frenzy Modifiers
			"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0,
			"Juggernaut": 0, "Zenith": 0,
			# Illusionist Modifiers
			"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
			"Fractured Self": 0, "Dazzle Pie": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0,"Geological Survey": 0, 
			"sovereign_trail": 0, "meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Survey Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S+": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	}
}

# Dictionary for upgrades costs and rules
var upgrade_data = {
		# --- CHEF PATH ---
	"Golden Seed Extract": {
		"display_name": "Golden Seed Extract",
		"description": "Increases the spawn chance of valuable Golden Apples.",
		"costs": [3, 4, 5], # Example costs for 3 levels
		"max_level": 3
	},
	"Exotic Seeds": {
		"display_name": "Exotic Seeds",
		"description": "Adds new, rare fruits to the spawn pool with each level.",
		"costs": [3, 3, 4, 4, 5], # 5 levels
		"max_level": 5
	},
	"The Cookbook": {
		"display_name": "The Cookbook",
		"description": "Unlocks the Recipe system, granting temporary buffs for eating fruit in a specific sequence.",
		"costs": [2],
		"max_level": 1,
		"prerequisite": {"upgrade": "Golden Seed Extract", "level": 1}
	},
	"Expanded Palate": {
		"display_name": "Expanded Palate",
		"description": "Adds new, more complex and powerful recipes to your Cookbook.",
		"costs": [4],
		"max_level": 1,
		"prerequisite": {"upgrade": "The Cookbook", "level": 1}
	},
	"Golden Glaze": {
		"display_name": "Golden Glaze",
		"description": "Golden Apples now act as a 'wild card' ingredient for any step in your current recipe.",
		"costs": [4],
		"max_level": 1,
		"prerequisite": {"upgrade": "The Cookbook", "level": 1}
	},
	"Custom Cuisine": {
		"display_name": "Custom Cuisine",
		"description": "Permanently enhances all special fruits with powerful secondary effects.",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "The Cookbook", "level": 1, "and": "Exotic Seeds", "and_level": 1}
	},
	"Mise en Place": {
		"display_name": "Mise en Place",
		"description": "Active Ability (Once per RUN): Instantly transforms all normal fruits on screen into random special fruits.",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "Exotic Seeds", "level": 5}
	},
	
	# --- GEOMANCER PATH ---
	"Fertile Ground": {
		"display_name": "Fertile Ground", "max_level": 3, "costs": [2, 3, 4],
		"description": "Each level grants +1 to Max Fruits but adds +5 rocks to every garden."
	},
	"Mineral Rich Soil": {
		"display_name": "Mineral-Rich Soil", "max_level": 3, "costs": [2, 3, 4],
		"description": "Each level grants +1 to Fruit Reward but adds +5 rocks to every garden."
	},
	"Tectonic Shift": {
		"display_name": "Tectonic Shift", "max_level": 3, "costs": [2, 3, 4],
		"description": "Each level grants a speed boost but adds +5 rocks to every garden."
	},
	"Heavy Foundation": {
		"display_name": "Heavy Foundation", "max_level": 3, "costs": [2, 3, 4],
		"description": "Each level grants a speed decrease but adds +5 rocks to every garden."
	},

	# --- GEOMANCER TIER 2 (ROCKEATERS) ---
	"Rockmuncher": {
		"display_name": "Rockmuncher", "max_level": 1, "costs": [4],
		"description": "You can now eat rocks, which grant +2 growth.",
		"prerequisite": {"upgrade": "Fertile Ground", "level": 3}
	},
	"Geode Cracker": {
		"display_name": "Geode Cracker", "max_level": 1, "costs": [4],
		"description": "You can now eat rocks, which have a chance to grant +1 Juice.",
		"prerequisite": {"upgrade": "Mineral Rich Soil", "level": 3}
	},
	"Kinetic Feast": {
		"display_name": "Kinetic Feast", "max_level": 1, "costs": [4],
		"description": "You can eat rocks and\nyou get a speed boost after eating the rock",
		"prerequisite": {"upgrade": "Tectonic Shift", "level": 3}
	},
	"Stones Burden": {
		"display_name": "Stone's Burden", "max_level": 1, "costs": [4],
		"description": "You can now eat rocks.\nEating a rock temporarily slows you down even further,\nbut it also makes you immune to self-collision for 3 seconds.",
		"prerequisite": {"upgrade": "Heavy Foundation", "level": 3}
	},

	# --- GEOMANCER KEYSTONE ---
	"Calculated Risk": {
		"display_name": "Calculated Risk", "max_level": 1, "costs": [8],
		"description": "Doubles the Juice bonus from Geological Survey.",
		"prerequisite": {"upgrade": "Geological Survey", "level": 1} 
		# The check for having a Rockeater upgrade will be handled in code
	},
	
	
	# --- FRENZY PATH ---
	"Sugar Rush": {
		"display_name": "Sugar Rush",
		"description": "Unlocks the Combo Meter,\nwhich tracks fruits eaten in quick succession.",
		"costs": [1],
		"max_level": 1
	},
	"Chain Reaction": {
		"display_name": "Chain Reaction",
		"description": "Your combo meter now also acts\nas a score multiplier.\nEach level increases the max combo.",
		"costs": [2, 3, 4],
		"max_level": 3,
		"prerequisite": {"upgrade": "Sugar Rush", "level": 1}
	},
	"Overdrive": {
		"display_name": "Overdrive",
		"description": "While combo is active,\nhold your current direction key for a speed boost.",
		"costs": [2, 1], # Lvl 2 is cheap for the cosmetic!
		"max_level": 2,
		"prerequisite": {"upgrade": "Sugar Rush", "level": 1}
	},
	"Lingering Rush": {
		"display_name": "Lingering Rush",
		"description": "Increases the duration of the combo timer,\nmaking it easier to chain fruits.",
		"costs": [2, 2, 3, 3, 4],
		"max_level": 5,
		"prerequisite": {"upgrade": "Sugar Rush", "level": 1}
	},
	"Juggernaut": {
		"display_name": "Juggernaut",
		"description": "While your combo is pure\n(you haven't opened the upgrade menu),\nthe combo timer is paused.",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "Lingering Rush", "level": 5}
	},
	"Zenith": {
		"display_name": "Zenith",
		"description": "Active Ability (Once per Garden):\nInstantly set your combo to 10\nand make the timer not decrease for 10 seconds.",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "Lingering Rush", "level": 5} # Example prerequisite
	},
	
	#------ILLUSIONIST PATH-------#
	"Ghost Tail": {
		"display_name": "Ghost Tail",
		"description": "Your last few tail segments become intangible.\nLvl 1: 7\nLvl 2: 10\nLvl 3: 15\nLvl 4: 20\nLvl 5: 34",
		"costs": [2, 2, 3, 3, 4],
		"max_level": 5
	},
	"Phase Shift": {
		"display_name": "Phase Shift",
		"description": "Active Ability: Become intangible to your own body for a short time.",
		"costs": [3, 4, 5],
		"max_level": 3,
		"exclusive_with": "Blink" # Can't have both
	},
	"Blink": {
		"display_name": "Blink",
		"description": "Active Ability: Instantly teleport forward 3 tiles.",
		"costs": [3, 4, 5],
		"max_level": 3,
		"prerequisite": {"upgrade": "Ghost Tail", "level": 2},
		"exclusive_with": "Phase Shift"
	},
	"3 Card Monty": {
		"display_name": "3-Card Monty",
		"description": "Permanently reduces the Juice cost of all other upgrades by 1 (to a minimum of 1).",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "Ghost Tail", "level": 3}
	},
	"Fractured Self": {
		"display_name": "Fractured Self",
		"description": "Your body is now rendered in 3-segment chunks with a 1-tile gap between each, allowing you to pass through.",
		"costs": [8],
		"max_level": 1,
		"prerequisite": {"upgrade": "Ghost Tail", "level": 5}
	},
	"Dazzle Pie": {
		"display_name": "Dazzle Pie",
		"description": "A permanent, purely aesthetic transformation that adds a chromatic aberration effect to the game.",
		"costs": [8],
		"max_level": 1,
		"prerequisite": {"upgrade": "Ghost Tail", "level": 5},
		"exclusive_with": "Master's Blueprint"
	},
	
		# --- SURVIVOR PATH ---
	"Mulligan Munchie": {
		"display_name": "Mulligan Munchie",
		"description": "Grants one Extra Life.\nThe cost increases dramatically with each purchase.",
		"costs": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], # Example scaling costs
		"max_level": 10
	},
	"Phoenix Dawn": {
		"display_name": "Phoenix Dawn",
		"description": "After using an Extra Life,\nthe next fruit you eat restores 25% of your lost length.",
		"costs": [3], "max_level": 1,
		"prerequisite": {"upgrade": "Mulligan Munchie", "level": 1}
	},
	"Last Stand": {
		"display_name": "Last Stand",
		"description": "While on your final life,\nthe chance for Golden Apples to spawn is significantly increased.",
		"costs": [3], "max_level": 1,
	},
	"Sacrificial Molt": {
		"display_name": "Sacrificial Molt",
		"description": "Active Ability (Once per RUN):\nHalve your current length to instantly gain one Extra Life charge.",
		"costs": [4], "max_level": 1,
		"prerequisite": {"upgrade": "Mulligan Munchie", "level": 1}
	},
	"Death Defied": {
		"display_name": "Death Defied",
		"description": "Every time you use an Extra Life,\npermanently gain +1 to your Fruit Reward and Max Fruits\non Screen for this run.",
		"costs": [5], "max_level": 1,
		"prerequisite": {"upgrade": "Mulligan Munchie", "level": 2}
	},
	"Martyrdom": {
		"display_name": "Martyrdom",
		"description": "Upon your final death, your snake explodes,\nharvesting all fruit on screen\nfor a final score boost.",
		"costs": [5], "max_level": 1,
		"prerequisite": {"upgrade": "Mulligan Munchie", "level": 2}
	},
	"New Game S+": {
		"display_name": "New Game S+",
		"description": "PRESTIGE! If you reach the final Garden without dying,\nyou may choose to restart at Garden 1 with all upgrades\nand double Juice gain.",
		"costs": [1], "max_level": 1,
		# The prerequisite for this one will be handled in code, not here.
	},
	# --- ARCHITECT PATH ---
	"Edge Lord": {
		"display_name": "Edge Lord",
		"description": "Increases the size\nof the play area.\nLvl 1: small\nLvl 2: not so small\nLvl 3: not BIG\nLvl 4: what you're lookin' for",
		"costs": [2, 2, 2, 2, 2],
		"max_level": 5
	},
	"Zoning Ordinance": {
		"display_name": "Zoning Ordinance",
		"description": "Designate a quadrant as a\n'safe zone' with fewer obstacles\nLvl 1: Top Left\nLvl 2: Top Half\nLvl 3: Bottom-Left Safe as well\nLvl 4: Complete control",
		"costs": [2, 3, 3, 4],
		"max_level": 4,
		"prerequisite": {"upgrade": "Edge Lord", "level": 3}
	},
	"Border Czar": {
		"display_name": "Border Czar",
		"description": "Fruit that spawns on the edge\nof the garden has a higher chance to be special\nGolden fruit chances doubled!",
		"costs": [3],
		"max_level": 1,
		"prerequisite": {"upgrade": "Edge Lord", "level": 3}
	},
	"Surveyed Land": {
		"display_name": "Surveyed Land",
		"description": "The quadrant opposite your 'safe zone' becomes\na 'wilderness' with better fruit but more obstacles.",
		"costs": [2],
		"max_level": 1,
		"prerequisite": {"upgrade": "Zoning Ordinance", "level": 1}
	},
	"Burrow": {
		"display_name": "Burrow",
		"description": "Active Ability: Pass through one wall\nand emerge on the opposite side\n+ 1 charge per upgrade\nAbility lasts until next wall hit!",
		"costs": [5, 5, 5],
		"max_level": 3,
		"prerequisite": {"upgrade": "Edge Lord", "level": 4} # This should be 4 to match max_level
	},
	"Pocket Garden": {
		"display_name": "Pocket Garden",
		"description": "Active Ability: Sacrifice tail segments to\ncreate a temporary 5x5 safe zone that spawns fruit.\nLvl 1: 10 segs cost and 20s duration\nLvl 2: 20 segs cost and 30s duration\nLvl 3: 30 segs cost and 60s duration",
		"costs": [5, 5, 7],
		"max_level": 3,
		"prerequisite": {"upgrade": "Edge Lord", "level": 4} # This should be 4
	},
	"Fold Space": {
		"display_name": "Fold Space", 
		"description": "Removes all walls, making the garden wrap around on itself.",
		"costs": [8], 
		"max_level": 1, 
		"prerequisite": {"upgrade": "Edge Lord", "level": 5, "and": "Burrow", "and_level": 3},
		"exclusive_with": "Shatter Reality" # <-- makes it mutually exclusive
	},
	"Shatter Reality": {
		"display_name": "Shatter Reality", 
		"description": "Splits the garden into four quadrants with connecting portals.",
		"costs": [8], 
		"max_level": 1, 
		"prerequisite": {"upgrade": "Edge Lord", "level": 5},
		"exclusive_with": "Fold Space" # <-- makes it mutually exclusive
	},
	"Master's Blueprint": {
		"display_name": "Master's Blueprint", 
		"description": "Transforms the game's visuals into a clean,\nglowing 'blueprint' grid for the rest of the run.\nVisual changes only, enjoy!",
		"costs": [3], 
		"max_level": 1, 
		"prerequisite": {"upgrade": "Edge Lord", "level": 5}
		# This one is independent and has no 'exclusive_with' key
	},

	#------------------------THE ACROBAT--------------------------#
	"Slither Sauce": {
		"display_name": "Slither Sauce",
		"description": "Permanently increases movement speed.\nIf you can handle it...",
		"costs": [1, 1, 2, 2, 3, 3, 4, 4, 5, 5],
		"max_level": 10
	},
	"Tenderizer": {
		"display_name": "Tenderizer",
		"description": "Destroy a rock on impact.\nHas limited charges, which refresh on level up.\nEach level grants another charge.",
		"costs": [2, 3, 4],
		"max_level": 3,
		"prerequisite": {"upgrade": "Slither Sauce", "level": 3}
	},
	"Juke N Jive": {
		"display_name": "Juke 'N Jive",
		"description": "Changing direction 4 times in 1 second\nlets you phase through a single body segment\nGet groovin'",
		"costs": [4],
		"max_level": 1,
		"prerequisite": {"upgrade": "Slither Sauce", "level": 3}
	},
	"Afterburner": {
		"display_name": "Afterburner",
		"description": "Speed boost after eating a fruit?\nLvl 1: 33% faster for 2s\nLvl 2: 66.6% faster for 2.5s\nLvl 3: 3s double speed",
		"costs": [2, 2, 3],
		"max_level": 3,
		"prerequisite": {"upgrade": "Slither Sauce", "level": 3}
	},
	"Pop Rocks": {
		"display_name": "Pop Rocks",
		"description": "When you destroy a rock with Tenderizer,\nit creates a shockwave that destroys adjacent rocks.",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "Tenderizer", "level": 1}
	},
	"Autotomy": {
		"display_name": "Autotomy",
		"description": "Active Ability (once per Garden):\nFor 2s, you can sever your own tail on impact,\nsacrificing score to survive.",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "Slither Sauce", "level": 5}
	},
	
	
	#----------------------------------The Planner--------------------------------------------#
	"diet_slith": {
		"display_name": "Diet Slith",
		"description": "Speed ain't your thing?\nCome take a walk on the Slith side with some Diet Slith!\nDecresae your speed by 10%",
		"costs": [1, 1, 2, 2, 3], # 5 levels total
		"max_level": 5
	},
	"fruit_foresight": {
		"display_name": "Fruit Foresight",
		"description": "Movin' so slow out there,\nit'd be nice to see where the next fruit is gonna go...\nLook no further! One time purchase!",
		"costs": [3], # One-time purchase
		"max_level": 1,
		"prerequisite": {"upgrade": "diet_slith", "level": 2} # Requires Diet Slith Lvl 2
	},
	#New geological survey... ooo lala
	"Geological Survey": {
	"display_name": "Geological Survey", "max_level": 1, "costs": [4],
	"description": "Gain bonus SP at the end of each Garden\nbased on how many rocks are left on screen.",
	"prerequisite": {"upgrade": "diet_slith", "level": 3}
	},
	"sovereign_trail": {
		"display_name": "Sovereign Trail",
		"description": "Leave a trail for 10 segments behind you, wherever you go!\nLvl 1:Fruits can't spawn in your trail!\nLvl 2: Fruits wills spawn VERY close to your trail",
		"costs": [2, 4], # Lvl 1: Repel, Lvl 2: Attract
		"max_level": 2,
		"prerequisite": {"upgrade": "diet_slith", "level": 2}
	},
	"meditative_state": {
		"display_name": "Meditative State",
		"costs": [5, 5, 10],
		"description": "Pause! Need I say more?\nThis grants you the ability to pause your snake for 3 seconds!\nRequires Diet Slith lvl 5",
		"max_level": 3,
		"prerequisite": {"upgrade": "diet_slith", "level": 5}
	},
	"garden_weaver": {
		"display_name": "Garden Weaver",
		"description": "Don't like how far away all those fruits are, slowpoke?\nWith Garden Weaver, reroll the fruits MUCH closer with this ability!\nRequires Diet Slith Lvl 5",
		"costs": [5],
		"max_level": 1,
		"prerequisite": {"upgrade": "diet_slith", "level": 5}
	},
	#----------------------------------------------------------------------------------#
	#-------------------------------------------the glutton----------------------------#
	"elephant_sized_portions": {
		"display_name": "Elephant Sized Portions",
		"description": "Increases the number of segments you grow per fruit.",
		"costs": [1,1,2,2,3,3,4,4,5,5],
		"max_level": 10
	},
	"more_mice": {
		"display_name": "More Mice!",
		"description": "Increases the maximum number of fruits on screen at once.",
		"costs": [2,2,3,3,4,4],
		"max_level": 6,
		"prerequisite": {"upgrade": "elephant_sized_portions", "level": 3}
	},
	"golden_seeds": {
		"display_name": "Golden Seeds",
		"description": "Unlocks a chance for Golden Apples to spawn,\ngranting SP. Each level increases the chance and reward.",
		"costs": [3,3,4,4],
		"max_level": 4,
		"prerequisite": {"upgrade": "elephant_sized_portions", "level": 3}
	},
	"patient_gardener": {
		"display_name": "Patient Gardener",
		"description": "Fruits left on screen will ripen over time,\ngranting bonus growth.",
		"costs": [3,3,4],
		"max_level": 3,
		"prerequisite": {"upgrade": "elephant_sized_portions", "level": 3}
	},
	"banana_bounty": {
		"display_name": "Banana Bounty",
		"description":  "Active Ability: Marks a random fruit.\nEating it grants growth equal\nto your max fruit count * your fruit reward.",
		"costs": [5, 7],
		"max_level": 2,
		"prerequisite": {"upgrade": "elephant_sized_portions", "level": 5}
	},
	"the_satchel": {
		"display_name": "The Satchel",
		"description": "Permanently unlocks a third active ability slot.",
		"costs": [8],
		"max_level": 1,
		"prerequisite": {"upgrade": "elephant_sized_portions", "level": 10, "and": "golden_seeds", "and_level": 4}
	},
}


var meta_upgrade_data = {
	"Synapse Slot": {
		"description": "Unlocks one additional active ability slot.\nA crucial investment for any build.",
		"costs": [10, 25, 50, 75, 100, 150, 200, 300], # Costs for slots 3 through 10
		"max_level": 8 # 8 purchasable slots (2 start unlocked)
	},
	"Serpent's Coffer": {
		"description": "Gain 'interest' on your unspent Pulp at the end of each Garden.",
		"costs": [20, 35, 50, 75],
		"max_level": 4
	},
	"Geode Compass": {
		"description": "Permanently removes a percentage of obstacles from all subsequent gardens.",
		"costs": [15, 25, 40, 60],
		"max_level": 4
	},
	"Four Leaf Clover": {
		"description": "Permanently increases your 'luck,' boosting the chance of all random events.",
		"costs": [30, 45, 60, 80],
		"max_level": 4
	},
	"Chroma Scales": {
		"description": "Unlocks a new cosmetic skin for your snake.",
		"costs": [50, 50, 50, 50],
		"max_level": 4
	}
}



# --- CORRECTED RECIPE DATA ---
var basic_recipes = [
	{
		"name": "Simple Skewer",
		"sequence": [ {"type": "Fruit"}, {"type": "Fruit"} ],
		"buff": {"type": "speed_boost", "value": 0.8, "duration": 5.0}
	},
	{
		"name": "Golden Snack",
		"sequence": [ {"type": "Fruit"}, {"type": "GoldenFruit"} ],
		"buff": {"type": "sp_boost", "value": 1, "duration": 0}
	}
]
var exotic_recipes = [
	{
		"name": "Spicy Surprise",
		"sequence": [ {"type": "Fruit"}, {"type": "GhostPepper"}, {"type": "Fruit"} ],
		"buff": {"type": "full_recharge", "duration": 0}
	},
	{
		"name": "Bountiful Harvest",
		"sequence": [ 
			{"type": "Fruit", "properties": {"is_ripe": true}}, 
			{"type": "IronCherry"} 
		],
		"buff": {"type": "fruit_flood", "duration": 10.0}
	}
]




#----------FUNCTIONS-----------#
func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func get_modified_chance(base_chance: float) -> float:
	var final_chance = base_chance
	# Four Leaf Clover --------
	final_chance += four_leaf_clover_data[four_leaf_clover_level]
	
	return clamp(final_chance, 0.0, 1.0)
	
	
func start_game():
	var p_class_data = class_data[chosen_class]
	var diff_data = difficulty_data[chosen_difficulty]
	# Reset all stats for a new run
	player_level = 1
	juice = 0
	juice += diff_data["starting_sp"]	# add starting sp
	pulp = 0
	score_needed_for_next_level = 5
	score_at_level_start = 0
	current_garden = 1
	has_died_this_garden = false
	run_time = 0.0
	fruits_eaten_this_run = 0
	total_juice_this_run = 0
	total_juice_this_run = juice
	segments_to_restore = 0
	

	juice_spent_this_garden = 0
	abilities_used_this_garden = 0
	garden_start_time = 0.0 
	#----BASE REWARD AND ENGINE---#
	fruit_reward = p_class_data["start_fruit_reward"]
	max_fruits_on_screen = p_class_data["start_max_fruits"]

	# --- "PULP" META-UPGRADE LEVELS ---
	synapse_slots_unlocked = diff_data["start_slots"]
	serpents_coffer_level = 0
	geode_compass_level = 0
	four_leaf_clover_level = 0
	chroma_scales_level = 0
	
	# --- Geomancer Path ---
	fertile_ground_level = 0
	mineral_rich_soil_level = 0
	tectonic_shift_level = 0
	heavy_foundation_level = 0
	# We need to know which Rockeater upgrade they chose
	rockeater_type = "" # e.g., "Rockmuncher", "Geode Cracker", etc.
	calculated_risk_unlocked = false
	
	#------Reset Planner Upgrades-----#
	diet_slith_level = 0
	fruit_foresight_unlocked = false
	ghost_tail_level = 0
	geological_survey_unlocked = false
	sovereign_trail_level = 0
	meditative_state_level = 0
	meditative_state_charges = 0
	garden_weaver_unlocked = false
	garden_weaver_used_this_garden = false
	#-------Reset Glutton Upgrades--------#
	es_portions_level = 0
	more_mice_level = 0
	golden_seeds_level = 0
	patient_gardener_level = 0
	banana_bounty_level = 0
	banana_bounty_charges = 0
	is_bounty_active = false
	the_satchel_unlocked = false
	#------Reset Acrobat Upgrades--------#
	slither_sauce_level = 0 
	tenderizer_level = 0
	tenderizer_charges = 0
	juke_and_jive_unlocked = false
	afterburner_level = 0
	pop_rocks_unlocked = false
	autotomy_unlocked = false
	autotomy_is_active = false
	autotomy_used_this_garden = false
	#-----Reset Architect Upgrades
	# Architect Path
	edge_lord_level = 0
	zoning_ordinance_level = 0
	border_czar_unlocked = false
	surveyed_land_unlocked = false
	burrow_charges = 0
	burrow_level = 0
	pocket_garden_level = 0
	pocket_garden_charges = 0
	active_pocket_garden_rect = null
	fold_space_unlocked = false
	masters_blueprint_unlocked = false
	shatter_reality_unlocked = false
	# SURVIVOR PATH
	extra_lives = 0
	extra_lives += p_class_data["start_lives"]
	phoenix_dawn_unlocked = false
	last_stand_unlocked = false
	sacrificial_molt_used_this_run = false
	sacrificial_molt_unlocked = false
	death_defied_unlocked = false
	martyrdom_unlocked = false
	times_died_this_run = 0
	new_game_s_plus_active = false
	# Illusionist Path
	ghost_tail_level = 0
	phase_shift_level = 0
	phase_shift_charges = 0
	blink_level = 0
	blink_charges = 0
	three_card_monty_unlocked = false
	fractured_self_unlocked = false
	dazzle_pie_unlocked = false
	# --- Frenzy Path ---
	sugar_rush_unlocked = false
	chain_reaction_level = 0
	overdrive_level = 0
	lingering_rush_level = 0
	juggernaut_unlocked = false
	zenith_unlocked = false
	zenith_charges = 0
	is_zenith_active = false
	current_combo = 0
	combo_is_pure = true
		# --- Chef Path ---
	golden_seed_extract_level = 0
	exotic_seeds_level = 0
	the_cookbook_unlocked = false
	active_recipe = {} 
	recipe_progress = 0    
	expanded_palate_unlocked = false
	golden_glaze_unlocked = false
	custom_cuisine_unlocked = false
	iron_cherry_buff_active = false
	dragon_fruit_buff_active = false
	mise_en_place_used_this_run = false
	mise_en_place_unlocked = false
	
	SceneTransition.transition_to("res://Scenes/main.tscn", "spiral")
	get_tree().paused = false
