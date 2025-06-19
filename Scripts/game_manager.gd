extends Node

#------Session State---------#
var chosen_difficulty = "viper"
var chosen_class = "speedster"
var run_time: float = 0.0
#------Garden Progression----#
var has_died_this_garden = false
var current_garden = 1
var garden_data = {
	1: {"name": "The First Coil", "score_goal": 50, "obstacle_count": 1},
	2: {"name": "Maximum Over-Bite", "score_goal": 125, "obstacle_count": 5},
	3: {"name": "The Juice Box", "score_goal": 250, "obstacle_count": 10},
	4: {"name": "The Forked Tongue Bistro", "score_goal": 420, "obstacle_count": 15},
	5: {"name": "The Garden of Eatin'", "score_goal": 666, "obstacle_count": 20}
}



#-----Player Stats--------#
var player_level = 1
var skill_points = 0
var score_needed_for_next_level = 5
var score_at_level_start = 0
var fruits_eaten_this_run: int = 0
var total_sp_this_run: int = 0
#----Upgrade Data Tracking----#
var fruit_reward = 1
var max_fruits_on_screen = 1

	#-------New Phase Shift Upgrade Shit------#
var phase_shift_level = 0
var phase_shift_charges = 0
	#-------Extra Life Shit-------------#
var extra_lives = 0
	#----Active Ability Flags----#
var burrow_is_active = false
var is_phasing = false 
var is_bounty_active = false
var autotomy_is_active = false

#------The Planner-------#
var diet_slith_level = 0
var fruit_foresight_unlocked = false
var ghost_tail_level = 0
var ghost_tail_data = [0, 7, 10, 15]
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
		"starting_sp": 34          # Start with 5 free skill points!
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
			"increase_burrow_charges": 1, # +1 SP cost
			"increase_phase_charges": 1,  # +1 SP cost
			"increase_grid_size": 2,      # +2 SP cost
			"buy_extra_life": 2,           # +2 SP cost
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
		}
	},
	"warlock": {
		"name": "Warlock",
		"description": "Grows faster by default.\nFruit-based upgrades are cheaper.",
		"start_length": 3,
		"start_speed": 0.25,
		"start_fruit_reward": 2, # Starts with a better reward
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 2, # Very good
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			"increase_burrow_charges": 1,
			"increase_phase_charges": 1,
			"increase_grid_size": 0,
			"buy_extra_life": 1,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": -1, "more_mice": -1, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
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
			"increase_burrow_charges": 1, # +1 SP cost
			"increase_phase_charges": 1,  # +1 SP cost
			"increase_grid_size": -1,      # Cheaper 1 (min. 1)
			"buy_extra_life": 2,           # +2 SP cost
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0, 
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
			"increase_burrow_charges": 0,
			"increase_phase_charges": 0,
			"increase_grid_size": 1,
			"buy_extra_life": -5, # Makes the 10 SP cost only 5
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
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
			"increase_burrow_charges": -3,
			"increase_phase_charges": -1,
			"increase_grid_size": 1,
			"buy_extra_life": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
		}
	},
	"the_zealot": {
		"name": "The Zealot",
		"description": "Cannot gain extra lives.\nReceives a massive +5 SP bonus for completing a Garden without dying.",
		"start_length": 1,
		"start_speed": 0.2,
		"start_fruit_reward": 1,
		"start_max_fruits": 1,
		"start_lives": 0, # Cannot get more
		"speed_upgrade_mod": 0.9,
		"reward_upgrade_mod": 1,
		"sp_on_perfect_garden": 5, # The big bonus!
		"cost_modifiers": {
			"increase_burrow_charges": 0,
			"increase_phase_charges": 0,
			"increase_grid_size": 0,
			"buy_extra_life": 0,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
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
			"increase_burrow_charges": -1,
			"increase_phase_charges": -1,
			"increase_grid_size": 2,
			"buy_extra_life": -1,
			# Planner Path Modifiers
			"diet_slith": 0, "fruit_foresight": 0, "ghost_tail": 0, "sovereign_trail": 0,
			"meditative_state": 0, "garden_weaver": 0,
			# Glutton Modifiers
			"elephant_sized_portions": 0, "more_mice": 0, "golden_seeds": 0,
			"patient_gardener": 0, "banana_bounty": 0, "the_satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke & Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Survey Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Master's Blueprint": 0, 
			"Shatter Reality": 0,
		}
	}
}

# Dictionary for upgrades costs and rules
var upgrade_data = {
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
		"prerequisite": {"upgrade": "Edge Lord", "level": 5},
		"exclusive_with": "Shatter Reality" # <-- NEW: This makes it mutually exclusive
	},
	"Shatter Reality": {
		"display_name": "Shatter Reality", 
		"description": "Splits the garden into four quadrants with connecting portals.",
		"costs": [8], 
		"max_level": 1, 
		"prerequisite": {"upgrade": "Edge Lord", "level": 5},
		"exclusive_with": "Fold Space" # <-- This makes it mutually exclusive
	},
	"Master's Blueprint": {
		"display_name": "Master's Blueprint", 
		"description": "Transforms the game's visuals into a clean,\nglowing 'blueprint' grid for the rest of the run.",
		"costs": [8], 
		"max_level": 1, 
		"prerequisite": {"upgrade": "Edge Lord", "level": 5}
		# This one is independent and has no 'exclusive_with' key
	},
	"increase_phase_charges": {
		"display_name": "Phase Shift Ability",
		"description": "Phase through yourself...whenever you feel like it!\nPress e to pass through your own body for 2 seconds!",
		"costs": [3, 4, 5],
		"max_level": 3
	},
	"buy_extra_life": {
		"display_name": "Mulligan Munchie",
		"description": "We all make mistakes.\nHere's a free life if ya need it!\nReset to 1 length and keep all your buffs!\n3 per run!",
		"costs": [3, 7, 10],
		"max_level": 3
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
	"Juke & Jive": {
		"display_name": "Juke & Jive",
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
	"ghost_tail": {
		"display_name": "Ghost Tail",
		"description": "Makes your tail specifically passable\nLvl 1: 7 seg, Lvl 2: 10 seg, Lvl 3: 15 seg!",
		"costs": [2, 2, 3], # 3 levels (e.g., 7 -> 10 -> 15 segments)
		"max_level": 3,
		"prerequisite": {"upgrade": "diet_slith", "level": 2}
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
	run_time = 0.0
	fruits_eaten_this_run = 0
	total_sp_this_run = 0
	total_sp_this_run = skill_points
	
	fruit_reward = p_class_data["start_fruit_reward"]
	max_fruits_on_screen = p_class_data["start_max_fruits"]

	
	phase_shift_level = 0
	phase_shift_level = 0
	extra_lives = 0
	extra_lives += p_class_data["start_lives"]
	#------Reset Planner Upgrades-----#
	diet_slith_level = 0
	fruit_foresight_unlocked = false
	ghost_tail_level = 0
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
	
	
	SceneTransition.transition_to("res://Scenes/main.tscn", "spiral")
	get_tree().paused = false
