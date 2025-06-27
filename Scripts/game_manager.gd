extends Node

#------Session State---------#
var chosen_difficulty = "viper"
var chosen_class = "speedster"
var run_time: float = 0.0
#------Garden Progression----#
var has_died_this_garden = false
var current_garden = 1
var garden_data = {
	# --- The Early Game ---
	1: {"name": "The First Coil", "score_goal": 15, "obstacle_count": 0},
	2: {"name": "The Juice Box", "score_goal": 35, "obstacle_count": 3},
	3: {"name": "The Danger Noodle Den", "score_goal": 60, "obstacle_count": 5},
	
	# --- The Mid-Game ---
	4: {"name": "The Forked Tongue Bistro", "score_goal": 100, "obstacle_count": 8},
	5: {"name": "Rhythm & Haste", "score_goal": 150, "obstacle_count": 12},
	6: {"name": "The Architect's Grid", "score_goal": 222, "obstacle_count": 18},

	# --- The Endgame ---
	7: {"name": "The Basilisk's Lair", "score_goal": 333, "obstacle_count": 25},
	8: {"name": "The Kill Screen Quarry", "score_goal": 420, "obstacle_count": 35},
	9: {"name": "The Garden of Eatin'", "score_goal": 666, "obstacle_count": 50}
}

var garden_bonus_data = {
	"par_time": {"base_reward": 50, "time_limit": 60.0}, # 50 Scales if garden is beaten in under 60s
	"no_death": {"reward": 25}, # 25 Scales for a flawless, no-death garden
	"ascetic": {"reward": 50}, # 100 Scales if no upgrades were purchased this garden
	"pacifist": {"reward": 15}, # 15 Scales if no active abilities were used
	"engagement": {"reward": 2} # +2 Scales for every SP spent on upgrades this garden
}



# --- PERSISTENT CUSTOMIZATION UNLOCKS (Bought with Fangs) ---
# These variables would be saved and loaded in a real game.
var pattern_rate_unlocked = false
var custom_head_color_unlocked = false
var custom_body_color_1_unlocked = false
var custom_body_color_2_unlocked = false
var custom_trail_unlocked = false
var custom_ghost_tail_unlocked = false
var custom_background_unlocked = false
var custom_SFX_unlocked = false
# --- PLAYER'S EQUIPPED COSMETICS ---
var equipped_head_color: Color = Color.LIME_GREEN
var equipped_body_color_1: Color = Color.PURPLE
var equipped_body_color_2: Color = Color.GOLD
var equipped_pattern_rate: int = 5
var equipped_trail_color: Color = Color.LIGHT_PINK
var equipped_ghost_tail_color: Color = Color.STEEL_BLUE
var equipped_background_color: Color = Color.DARK_SLATE_GRAY
#var equipped_SFX: ???



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
var serpents_coffer_level: int = 0
var serpents_coffer_data = [0.0, 0.05, 0.10, 0.15, 0.20]
var geode_compass_level: int = 0
var geode_compass_data = [1.0, 0.9, 0.8, 0.7, 0.6] # % of rocks left
var four_leaf_clover_level: int = 0
var four_leaf_clover_data = [0.0, 0.02, 0.04, 0.07, 0.10] # + % on all luck
var chroma_scales_level: int = 0
var harvest_forecast_level: int = 0
var full_spawn_queue: Array = []


var ability_charges = {}
var equipped_abilities: Array = []
var max_ability_slots: int = 0

#--------Rotating Item Stuff------#
var extra_lives_are_capped: bool = false


	#----Active Ability Flags----#
var burrow_is_active = false
var is_phasing = false 
var is_bounty_active = false
var autotomy_is_active = false
var is_zenith_active = false
var iron_cherry_buff_active = false
var dragon_fruit_buff_active = false

#------------------------------the core(Idle, Planner, Ledger-------------------------------------------------------#
#------The Planner-------#
var diet_slith_level = 0
var fruit_foresight_unlocked = false
var geological_survey_unlocked = false
var sovereign_trail_level = 0
var meditative_data = [0.0, 2.0, 3.0, 5.0]
var garden_weaver_unlocked = false
var garden_weaver_used_this_garden = false

# --- The Ledger Path ---
var chosen_ledger_path = ""
# Path A (Juice Focus)
var liquid_assets_level = 0
var fast_track_unlocked = false
var gluttons_greed_unlocked = false
var market_crash_level = 0
# Path B (Pulp Focus)
var principal_pulp_level = 0
var principal_pulp_data = [1.0, 1.5, 2.0, 3.0] # Lvl 0, 1, 2, 3
var golden_handshake_level = 0
var golden_handshake_data = [1.0, 1.25, 1.5, 2.0]
var juice_press_used_this_garden: bool = false
# Juice Press is an active ability, so it will be handled by our hotbar system
var liquidation_used = false

# --- Idle Path ---
var snake_clicker_level = 0
var snake_clicker_data = [0.0, 0.1, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 7.5, 10.0, 25.0]
var get_rich_quick_unlocked = false
var custom_aftertaste_unlocked = false
var arcane_flow_unlocked = false
var pulp_reactor_unlocked = false
var unstable_metabolism_unlocked = false
# track the total passive GPS
var passive_gps = 0.0

#-------------------------------the harvest(Glutton, Chef, Geomancer)------------------------------#
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
var the_satchel_unlocked = false

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

# --- Geomancer Path ---
var fertile_ground_level = 0
var mineral_rich_soil_level = 0
var tectonic_shift_level = 0
var heavy_foundation_level = 0
# We need to know which Rockeater upgrade they chose
var rockeater_type = "" # e.g., "Rockmuncher", "Geode Cracker", etc.
var calculated_risk_unlocked = false

#-------------------------------the redline(Acrobat, Frenzy, Survivor)-----------------------------#
#----------ACROBAT PATH-----#
var slither_sauce_level = 0 
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

# --- Frenzy Path ---
var sugar_rush_unlocked = false
var chain_reaction_level = 0
var chain_reaction_data = [1, 5, 10, 999] # Lvl 0, 1, 2, 3
var overdrive_level = 0
var lingering_rush_level = 0
var lingering_rush_data = [5.0, 5.5, 6.0, 6.5, 7.0, 7.5]
var juggernaut_unlocked = false
# track the combo itself
var current_combo = 0
var combo_is_pure = true

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

#------------------------------the ssscale(Architect, Illusionist/Magician)------------------------#
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

#-----------#illusionist------------#
var ghost_tail_level = 0
var ghost_tail_data = [0, 7, 10, 15, 20, 34] # Lvl 0, 1, 2, 3, 4, 5
var three_card_monty_unlocked = false
var fractured_self_unlocked = false
var dazzle_pie_unlocked = false


#------------------------------------snakeeyes(GAMBA)----------------------------------------------#
#------------Gambler Path--------------
var coin_flip_curious_unlocked = false
var passive_income_unlocked = false
var correct_bets_this_run = 0
var block_market_portfolio: Dictionary = {} # Format: {"stock_name": shares_owned}
var block_market_prices: Dictionary = {
	"Orange Block": {"price": 10, "currency": "Juice"},
	"Apple Block":  {"price": 10, "currency": "Juice"},
	"Light Block":  {"price": 25, "currency": "Pulp"},
	"Extra Block":  {"price": 25, "currency": "Pulp"}
}

#^^^^^^^^^^^^^^^^--------------------------------------------------------------^^^^^^^^^^^^^^^^#
#||||||||||||||||--------------------------------------------------------------||||||||||||||||#
#________________||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||________________#
#________________VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV________________#

#---------Difficulty parameters-------#
var difficulty_data = {
	"hatchling": {	#Easy
		"name": "Hatchling",
		"speed_multiplier": 1.1,  # Slower snake (higher wait_time)
		"goal_multiplier": 0.8,   # Shorter garden goals
		"juice_cost_modifier": 0,    # Upgrades cost the normal amount
		"starting_juice": 69,          # Start with 5 free skill points!
		"start_slots": 10
	},
	"viper": {	#Medium
		"name": "Viper",
		"speed_multiplier": 1.0,  # Normal speed
		"goal_multiplier": 1.0,   # Normal garden goals
		"juice_cost_modifier": 1,    # Upgrades cost +1 SP
		"starting_juice": 10,
		"start_slots": 6
	},
	"basilisk": {	#Hard
		"name": "Basilisk",
		"speed_multiplier": 0.8,  # Faster snake
		"goal_multiplier": 1.25,  # Longer garden goals
		"juice_cost_modifier": 2,    # Upgrades cost +2 SP
		"starting_juice": 0,
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
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
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
		"start_fruit_reward": 5, # Starts with a better reward
		"start_max_fruits": 1,
		"start_lives": 0,
		"speed_upgrade_mod": 0.95,
		"reward_upgrade_mod": 2, # Very good
		"sp_on_perfect_garden": 0,
		"cost_modifiers": {
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": -1, "More Mice": -1, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
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
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
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
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
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
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
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
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Surveyed Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
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
			#--------Idle Modifiers-------#
			"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
			"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
			#------Gambling Modifiers--------#
			"Coin Flip Curious": 0, "Passive Income": 0,
			#------The Ledger Modifiers------#
			"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
			"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
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
			"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
			"Sovereign Trail": 0, "Meditative State": 0, "Garden Weaver": 0,
			# Glutton Modifiers
			"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
			"Patient Gardener": 0, "Banana Bounty": 0, "The Satchel": 0,
			# Acrobat Modifiers
			"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
			"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
			# Architect Modifiers
			"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Survey Land": 0,
			"Burrow": 0, "Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
			"Shatter Reality": 0,
			# Survivor Modifiers
			"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0, "Sacrificial Molt": 0,
			"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
			# Chef Modifiers
			"Golden Seed Extract": 0, "Exotic Seeds": 0, "The Cookbook": 0, "Expanded Palate": 0,
			"Golden Glaze": 0, "Mise en Place": 0, "Custom Cuisine": 0
		}
	}
}

# Dictionary for upgrades costs and rules
var upgrade_data = {
#------------------------------THE CORE (IDLE, PLANNER, LEDGER)-------------------------------------#
	"The Core": {
		"Idle": {
			"Snake Clicker": {
				"display_name": "Snake Clicker",
				"description": "The foundation of passive growth.\nEach level grants a flat bonus to your Growth Per Second (GPS).\nLvl 1: 0.1 GPS\n2: 0.25 GPS\n3: 0.5 GPS\n4: 1.0 GPS\n5: 2.0 GPS\n6: 3.0 GPS\n7: 5.0 GPS\n8: 7.5 GPS\n9: 10.0 GPS\n10: 25.0 GPS",
				"costs": [
					2, 2, 2, 2, 2,
					2, 2, 2, 2, 30
				],
				"max_level": 10
			},
			"Get Rich Quick": {
				"display_name": "Get Rich Quick",
				"description": "An investment in speed.\nGain +0.1 GPS for every point of Juice spent in the Acrobat skill tree.",
				"costs": [4], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1}
			},
			"Custom Aftertaste": {
				"display_name": "Custom Aftertaste",
				"description": "An investment in flavor.\nGain +0.1 GPS for every point of Juice spent in the Chef skill tree.",
				"costs": [4], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1}
			},
			"Arcane Flow": {
				"display_name": "Arcane Flow",
				"description": "An investment in deception.\nGain +0.1 GPS for every point of Juice spent in the Illusionist skill tree.",
				"costs": [4], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1}
			},
			"Pulp Reactor": {
				"display_name": "Pulp Reactor",
				"description": "A powerful economic synergy. Your GPS is permanently increased by +1 for every 100 Pulp you are currently holding.",
				"costs": [8],
				"max_level": 1,
				"prerequisite": {"upgrade": "Snake Clicker", "level": 3}
			},
			"Unstable Metabolism": {
				"display_name": "Unstable Metabolism",
				"description": "The ultimate power spike. Permanently doubles your total GPS for the rest of the run.",
				"costs": [10],
				"max_level": 1,
				"prerequisite": {"upgrade": "Snake Clicker", "level": 3}
			}
		},
		
		"Planner": {
			"Diet Slith": {
				"display_name": "Diet Slith",
				"description": "Speed ain't your thing?\nCome take a walk on the Slith side with some Diet Slith!\nDecresae your speed by 10%",
				"costs": [1, 1, 2, 2, 3], # 5 levels total
				"max_level": 5
			},
			"Fruit Foresight": {
				"display_name": "Fruit Foresight",
				"description": "Movin' so slow out there,\nit'd be nice to see where the next fruit is gonna go...\nLook no further! One time purchase!",
				"costs": [3], # One-time purchase
				"max_level": 1,
				"prerequisite": {"upgrade": "Diet Slith", "level": 2} # Requires Diet Slith Lvl 2
			},
			#New geological survey... ooo lala
			"Geological Survey": {
			"display_name": "Geological Survey", "max_level": 1, "costs": [4],
			"description": "Gain bonus SP at the end of each Garden\nbased on how many rocks are left on screen.",
			"prerequisite": {"upgrade": "Diet Slith", "level": 3}
			},
			"Sovereign Trail": {
				"display_name": "Sovereign Trail",
				"description": "Leave a trail for 10 segments behind you, wherever you go!\nLvl 1:Fruits can't spawn in your trail!\nLvl 2: Fruits wills spawn VERY close to your trail",
				"costs": [2, 4], # Lvl 1: Repel, Lvl 2: Attract
				"max_level": 2,
				"prerequisite": {"upgrade": "Diet Slith", "level": 2}
			},
			"Meditative State": {
				"display_name": "Meditative State",
				"costs": [5, 5, 10],
				"description": "Pause! Need I say more?\nThis grants you the ability to pause your snake for 3 seconds!\nRequires Diet Slith lvl 5",
				"max_level": 3,
				"prerequisite": {"upgrade": "Diet Slith", "level": 5}
			},
			"Garden Weaver": {
				"display_name": "Garden Weaver",
				"description": "Don't like how far away all those fruits are, slowpoke?\nWith Garden Weaver, reroll the fruits MUCH closer with this ability!\nRequires Diet Slith Lvl 5",
				"costs": [5],
				"max_level": 1,
				"prerequisite": {"upgrade": "Diet Slith", "level": 5}
			}
		},
		"Ledger": {
			# --- Tier 1 (The Choice) ---
			"Liquid Assets": {
				"display_name": "Liquid Assets", "max_level": 5, "costs": [2, 2, 3, 3, 4],
				"description": "The path of the Day Trader. Each level grants +1 Juice every time you level up.",
				"exclusive_with": "Principal Pulp" # This new key locks the other option
			},
			"Principal Pulp": {
				"display_name": "Principal Pulp", "max_level": 3, "costs": [2, 3, 4],
				"description": "The path of the Hedge Fund Manager. Multiplies the base Pulp reward from your score at the end of each Garden.",
				"exclusive_with": "Liquid Assets"
			},

			# --- Path A (Juice Focus) Upgrades ---
			"Fast Track": {
				"display_name": "Fast-Track", "max_level": 1, "costs": [3],
				"description": "Unlocks a 'Skip Garden' button in the Pulp-sicle Stand, letting you trade potential Pulp for +5 immediate Juice.",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 1}
			},
			"Gluttons Greed": {
				"display_name": "Glutton's Greed", "max_level": 1, "costs": [6],
				"description": "Your Fruit Reward is permanently increased by your current Max Fruits on Screen.",
				"prerequisite": {"upgrade": "Fast Track", "level": 1}
			},
			"Market Crash": {
				"display_name": "Market Crash", "max_level": 3, "costs": [8, 8, 8],
				"description": "Permanently reduces the Juice cost of all other upgrades.\nLvl 1: -1 Juice Cost\nLvl 2: -2 Juice Cost",
				"prerequisite": {"upgrade": "Gluttons Greed", "level": 1}
			},

			# --- Path B (Pulp Focus) Upgrades ---
			"Golden Handshake": {
				"display_name": "Golden Handshake", "max_level": 3, "costs": [3, 4, 5],
				"description": "Multiplies all BONUS Pulp rewards (Flawless, Par Time, etc.) at the end of each Garden.",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1}
			},
			"Juice Press": {
				"display_name": "Juice Press", "max_level": 1, "costs": [5],
				"description": "Active Ability (Once per Garden): Convert all your current Pulp into Juice at a 5:1 ratio.",
				"prerequisite": {"upgrade": "Golden Handshake", "level": 1}
			},
			"Liquidation": {
				"display_name": "Liquidation", "max_level": 1, "costs": [1],
				"description": "A one-time purchase. Instantly doubles your current held Juice.",
				"prerequisite": {"upgrade": "Juice Press", "level": 1}
			}
		}
	},#---------------------------------------------------------------------------------------------#
	#---------------------------HARVEST (GLUTTON, CHEF, GEOMANCER-----------------------------------#
	#-----------------------------the glutton----------------------------#
	"The Harvest": {
		"Glutton": {
			"Elephant Sized Portions": {
				"display_name": "Elephant Sized Portions",
				"description": "Increases the number of segments you grow per fruit.\n+1 per level (depending on class)",
				"costs": [1,1,2,2,3,3,4,4,5,5],
				"max_level": 10
			},
			"More Mice": {
				"display_name": "More Mice!",
				"description": "Increases the maximum number of fruits on screen at once.\n+1 per level",
				"costs": [2,2,3,3,4,4],
				"max_level": 6,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3}
			},
			"Golden Seeds": {
				"display_name": "Golden Seeds",
				"description": "Unlocks a chance for Golden Apples to spawn,\ngranting SP. Each level increases the chance and reward.\nLvl 1: 5%\nLvl 2: 10\nLvl 3: 20\nLvl 4: 33%",
				"costs": [3,3,4,4],
				"max_level": 4,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3}
			},
			"Patient Gardener": {
				"display_name": "Patient Gardener",
				"description": "Fruits left on screen will ripen over time,\ngranting bonus growth.",
				"costs": [3,3,4],
				"max_level": 3,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3}
			},
			"Banana Bounty": {
				"display_name": "Banana Bounty",
				"description":  "Active Ability: Marks a random fruit.\nEating it grants growth equal\nto your max fruit count * your fruit reward.",
				"costs": [5, 7],
				"max_level": 2,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 5}
			},
			"The Satchel": {
				"display_name": "The Satchel",
				"description": "Permanently unlocks another active ability slot.",
				"costs": [8],
				"max_level": 1,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 10, "and": "Golden Seeds", "and_level": 4}
			}
		},
		
		"Chef": {
			"Golden Seed Extract": {
				"display_name": "Golden Seed Extract",
				"description": "Increases the spawn chance of valuable Golden Apples.\nEach level adds a 5% chance!",
				"costs": [3, 4, 5], # Example costs for 3 levels
				"max_level": 3
			},
			"Exotic Seeds": {
				"display_name": "Exotic Seeds",
				"description": "Adds new, rare fruits to the spawn pool with each level.\nLvl 1: Jumping Bean\nLvl 2: Ghost Pepper\nLvl 3: Iron Cherry\nLvl 4: Dragon Fruit\nLvl 5: Double odds of these special fruits spawning",
				"costs": [3, 3, 4, 4, 5], # 5 levels
				"max_level": 5
			},
			"The Cookbook": {
				"display_name": "The Cookbook",
				"description": "Unlocks the Recipe system,\ngranting temporary buffs for eating fruit in a specific sequence.",
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
				"description": "Golden Apples now act as a 'wild card' ingredient\nfor any step in your current recipe.",
				"costs": [4],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1}
			},
			"Custom Cuisine": {
				"display_name": "Custom Cuisine",
				"description": "Permanently enhances all special fruits with powerful secondary effects!",
				"costs": [5],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1, "and": "Exotic Seeds", "and_level": 1}
			},
			"Mise en Place": {
				"display_name": "Mise en Place",
				"description": "Active Ability (Once per RUN):\nInstantly transforms all normal fruits on screen into random special fruits.",
				"costs": [5],
				"max_level": 1,
				"prerequisite": {"upgrade": "Exotic Seeds", "level": 5}
			}
		},
		
		"Geode": {
			"Fertile Ground": {
				"display_name": "Fertile Ground", "max_level": 3, "costs": [2, 3, 4],
				"description": "Each level grants +1 to Max Fruits\nbut adds +5 rocks to every garden."
			},
			"Mineral Rich Soil": {
				"display_name": "Mineral-Rich Soil", "max_level": 3, "costs": [2, 3, 4],
				"description": "Each level grants +1 to Fruit Reward\nbut adds +5 rocks to every garden."
			},
			"Tectonic Shift": {
				"display_name": "Tectonic Shift", "max_level": 3, "costs": [2, 3, 4],
				"description": "Each level grants a speed boost\nbut adds +5 rocks to every garden."
			},
			"Heavy Foundation": {
				"display_name": "Heavy Foundation", "max_level": 3, "costs": [2, 3, 4],
				"description": "Each level grants a speed decrease\nbut adds +5 rocks to every garden."
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
			}
		}
	},
	#----------------------------------------------------------------------------------------------#
	#-----------------------------REDLINE (ACROBAT, FRENZY, SURVIVOR-------------------------------#
	#--------------THE ACROBAT-------------#
	"The Redline": {
		"Acrobat": {
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
			}
		},
		"Frenzy": {
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
				}
			},
		"Survivor": {
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
			"New Game S Plus": {
				"display_name": "New Game S+",
				"description": "PRESTIGE! If you reach the final Garden without dying,\nyou may choose to restart at Garden 1 with all upgrades\nand double Juice gain.",
				"costs": [1], "max_level": 1,
				# The prerequisite for this one will be handled in code, not here.
			}
		}
	},#----------------------------------------------------------------------------------------------#
#---------------------------------------SSSCALE(ILLUSIONIST, ARCHITECT-------------------------------#
	#------ILLUSIONIST PATH-------#
	"The Ssscale": {
		"Illusionist": {
			"Ghost Tail": {
				"display_name": "Ghost Tail",
				"description": "Your last few tail segments become intangible.\nLvl 1: 7\nLvl 2: 10\nLvl 3: 15\nLvl 4: 20\nLvl 5: 34",
				"costs": [2, 2, 3, 3, 4],
				"max_level": 5
			},
			"Phase Shift": {
				"display_name": "Phase Shift",
				"description": "Active Ability: Become intangible to your own body for a short time.\nEach level grants another charge.",
				"costs": [3, 4, 5],
				"max_level": 3,
				"exclusive_with": "Blink" # Can't have both
			},
			"Blink": {
				"display_name": "Blink",
				"description": "Active Ability: Instantly teleport forward 3 tiles.\nPass through your old hole!",
				"costs": [3, 4, 5],
				"max_level": 3,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 2},
				"exclusive_with": "Phase Shift"
			},
			"3 Card Monty": {
				"display_name": "3-Card Monty",
				"description": "Permanently reduces the Juice cost of\nall other upgrades by 1 (to a minimum of 1).",
				"costs": [5],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 3}
			},
			"Fractured Self": {
				"display_name": "Fractured Self",
				"description": "Your body is now rendered in 3-segment chunks\nwith a 3-tile gap between each, allowing you to pass through.",
				"costs": [8],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 5}
			},
			"Dazzle Pie": {
				"display_name": "Dazzle Pie",
				"description": "A permanent, purely aesthetic transformation that adds\na chromatic aberration effect to the game.",
				"costs": [8],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 5},
				"exclusive_with": "Masters Blueprint"
		}
	},	
			
		"Architect": {
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
				"description": "Removes all walls,\nmaking the garden wrap around on itself.",
				"costs": [8], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 5, "and": "Burrow", "and_level": 3},
				"exclusive_with": "Shatter Reality" # <-- makes it mutually exclusive
			},
			"Shatter Reality": {
				"display_name": "Shatter Reality", 
				"description": "Splits the garden into\nfour quadrants with connecting portals.",
				"costs": [8], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 5},
				"exclusive_with": "Fold Space" # <-- makes it mutually exclusive
			},
			"Masters Blueprint": {
				"display_name": "Masters Blueprint", 
				"description": "Transforms the game's visuals into a clean,\nglowing 'blueprint' grid for the rest of the run.\nVisual changes only, enjoy!",
				"costs": [3], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 5}
				# This one is independent and has no 'exclusive_with' key
			}
		}
	},
#---------------------------------SNAKEEYES(GAMBLER)-----------------------------------------------#
	"Snake Eyes": {
		"Passives": {
			"Coin Flip Curious": {
			"display_name": "CoinFlip Curious",
			"description": "From now on...\nEvery fruit eaten now has a 50/50 effect\nEffect 1: Double Growth\nEffect 2: NO GROWTH\nGamble Responsibly...",
			"costs": [10],
			"max_level": 1
		},
		"Passive Income": {
			"display_name": "Passive Income",
			"description": "From now on...\nEvery bet won results in a +1 to your fruit reward\nYou heard me...get on with it!",
			"costs": [13],
			"max_level": 1
		}
	}
	}
		#----Gambleer----#
		
}


var meta_upgrade_data = {
	"Synapse Slot": {
		"description": "Unlocks one additional active ability slot.\nA crucial investment for any build.",
		"costs": [10, 25, 50, 75, 100, 150, 200, 300, 500, 1000], # Costs for slots 3 through 10
		"max_level": 10 
	},
	"Serpent's Coffer": {
		"description": "Gain 'interest' on your unspent\nPulp at the end of each Garden.",
		"costs": [20, 35, 50, 75],
		"max_level": 4
	},
	"Geode Compass": {
		"description": "Permanently removes a percentage of\nobstacles from all subsequent gardens.",
		"costs": [15, 25, 40, 60],
		"max_level": 4,
		
	},
	"Four Leaf Clover": {
		"description": "Permanently increases your 'luck,'\nboosting the chance of all random events.",
		"costs": [30, 45, 60, 80],
		"max_level": 4
	},
	"Chroma Scales": {
		"description": "Activate the cosmetic options\nyou've permanently unlocked in the Fang Fund.",
		"costs": [10, 20, 30, 40, 50, 60],
		"max_level": 6
	},
	"Lasso Larry": {
		"display_name": "Lasso Larry",
		"description": "Active Ability: Pulls nearby fruit directly to you.\nLvl 1: Pulls 1 fruit.\nLvl 2: Pulls 2 fruits.\nLvl 3: Pulls 3 fruits.",
		"costs": [10, 20, 30],
		"max_level": 3
	},
	"Harvest Forecast": {
		"display_name": "Harvest Forecast",
		"description": "Adds a UI element showing the next special fruits in the spawn queue.\nLvl 1: Shows 1 fruit.\nLvl 2: Shows 2 fruits.\nLvl 3: Shows 3 fruits.\nLvl 4: Shows the next 5 fruits",
		"costs": [30, 30, 30, 30],
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
		"buff": {"type": "juice_boost", "value": 1, "duration": 0}
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

# --- ROTATING SHOP ITEM POOLS ---

var common_items = [
	{
		"id": "juice_box",
		"name": "Juice Box",
		"description": "A refreshing treat!\nInstantly grants Juice equal to the current Garden number.",
		"cost": 30
	}
]	# ... (add more common items here later)

var rare_items = [
	{
		"id": "handicap",
		"name": "Handicap",
		"description": "A deal with the devil.\nInstantly unlock a new Ability Slot,\nbut your maximum Extra Lives is now permanently capped at 0.",
		"cost": 0 
	},
	# ... (add more rare items here later)
]

var legendary_items = [
	{
		"id": "elephant_devoured",
		"name": "Elephant Devoured",
		"description": "A truly legendary meal.\nInstantly raises your 'Elephant Sized Portions'\nupgrade to its maximum level.",
		"cost": 150
	},
	# ... (add more legendary items here later)
]

func apply_meta_upgrade(item_id: String):
	match item_id:
		"juice_box":
			juice += current_garden
		"handicap":
			max_ability_slots += 1
			# We'll need a new flag to enforce this cap
			extra_lives_are_capped = true 
		"elephant_devoured":
			# Set the level directly to the max defined in its upgrade_data
			while es_portions_level < upgrade_data["Elephant Sized Portions"]["max_level"]:
				apply_esp_level_up()


func reset_for_new_garden():
	# This function resets all stats that should be fresh for a new garden.
	
	# Reset the player's level back to 1.
	player_level = 1
	
	# Reset the XP and goals back to their starting values.
	score_at_level_start = 0
	score_needed_for_next_level = 10 # Or your initial starting value
	
	# Crucially, we do NOT reset juice, pulp, or any purchased upgrades.




#----------FUNCTIONS-----------#
func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func get_modified_chance(base_chance: float) -> float:
	var final_chance = base_chance
	# Four Leaf Clover --------
	final_chance += four_leaf_clover_data[four_leaf_clover_level]
	
	return clamp(final_chance, 0.0, 1.0)

func generate_full_spawn_queue():
	# This function now just creates a shuffled deck based on base probabilities.
	# It does NOT handle situational bonuses like Last Stand.
	full_spawn_queue.clear()
	var fruit_deck: Array = []
	
	# 1. Get the final chance, including the Four-Leaf Clover bonus.
	var final_special_chance = get_modified_chance(get_base_special_fruit_chance())
	var num_special_fruits = roundi(100 * final_special_chance)
	
	# 2. Get the list of unlocked special fruits.
	var unlocked_specials = get_unlocked_special_fruits()
	
	# 3. Build and shuffle the deck.
	if unlocked_specials.is_empty():
		for i in range(100): fruit_deck.append("Fruit")
	else:
		for i in range(num_special_fruits):
			fruit_deck.append(unlocked_specials.pick_random())
		for i in range(100 - num_special_fruits):
			fruit_deck.append("Fruit")
			
	fruit_deck.shuffle()
	full_spawn_queue = fruit_deck
	print("New full spawn queue generated!")


func get_unlocked_special_fruits() -> Array:
	# This function dynamically builds a list of all unlocked special fruits.
	var unlocked_specials = []
	
	if golden_seed_extract_level > 0 or golden_seeds_level > 0:
		unlocked_specials.append("GoldenFruit")
	if exotic_seeds_level >= 1:
		unlocked_specials.append("JumpingBean")
	if exotic_seeds_level >= 2:
		unlocked_specials.append("GhostPepper")
	if exotic_seeds_level >= 3:
		unlocked_specials.append("IronCherry")
	if exotic_seeds_level >= 4:
		unlocked_specials.append("DragonFruit")
		
	return unlocked_specials

func get_base_special_fruit_chance() -> float:
	# This function now calculates the BASE chance for ANY special fruit.
	# We will add Golden Apple chance and Exotic Seeds chance together.
	var total_chance = 0.0
	
	# Add chance from Golden Seed Extract
	if golden_seed_extract_level > 0:
		total_chance += golden_seed_extract_data[golden_seed_extract_level]
		
	# Add base chance from Exotic Seeds
	if exotic_seeds_level > 0:
		total_chance += 0.10 # Base 10%
		if exotic_seeds_level >= 5:
			total_chance += 0.10 # The Lvl 5 bonus adds another 10%
			
	return total_chance


func apply_esp_level_up():
	if es_portions_level < upgrade_data["The Harvest"]["Glutton"]["Elephant Sized Portions"]["max_level"]:
		es_portions_level += 1
		fruit_reward += class_data[chosen_class]["reward_upgrade_mod"]
		print("Elephant Sized Portions leveled up! New level: ", es_portions_level)



func update_block_market():
	print("Updating the Block Market!")
	
	# This loop goes through each stock and changes its price.
	for stock_name in block_market_prices.keys():
		var stock_data = block_market_prices[stock_name]
		var current_price = stock_data.price
		
		# Calculate the volatility (how much the price can change).
		var base_volatility = 0.50 # Base 50% swing
		var volatility = base_volatility + (four_leaf_clover_level * 0.10)
		
		# Get a random change percentage.
		var change_percent = randf_range(-volatility, volatility)
		
		# Calculate the new price and make sure it doesn't go below 1.
		var new_price = max(1, roundi(current_price * (1 + change_percent)))
		
		block_market_prices[stock_name].price = new_price
		print("%s new price: %s" % [stock_name, new_price])


func get_total_juice_spent_in_path(path_upgrades: Array) -> int:
	var total_spent = 0
	
	# Loop through every upgrade key in the path we're checking.
	for upgrade_key in path_upgrades:
		var rules = upgrade_data.get(upgrade_key)
		if not rules: continue

		var current_level = 0
		
		# --- THIS IS THE FIX ---
		# We now correctly check for each property type.
		
		# Is it a multi-level active ability?
		if upgrade_key in ability_charges:
			current_level = ability_charges[upgrade_key].total
		else:
			# If not, it must be a passive upgrade.
			# We build the snake_case variable name for both _level and _unlocked versions.
			var level_var_name = upgrade_key.to_snake_case().replace("'", "") + "_level"
			var unlocked_var_name = upgrade_key.to_snake_case().replace("'", "") + "_unlocked"

			# Check if the _level variable exists on this script.
			if level_var_name in self:
				current_level = get(level_var_name)
			# Else, check if the _unlocked variable exists.
			elif unlocked_var_name in self:
				if get(unlocked_var_name) == true:
					current_level = 1

		# Now that we have the correct level, add up the costs.
		if current_level > 0:
			for i in range(current_level):
				if i < rules.costs.size():
					total_spent += rules.costs[i]
			
	return total_spent


	
func start_game():
	var p_class_data = class_data[chosen_class]
	var diff_data = difficulty_data[chosen_difficulty]
	# Reset all stats for a new run
	player_level = 1
	juice = 0
	juice += diff_data["starting_juice"]	# add starting sp
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
	passive_gps = 0.0
	
	# --- NEW ABILITY SYSTEM RESET ---
	ability_charges.clear()
	equipped_abilities.clear()


	juice_spent_this_garden = 0
	abilities_used_this_garden = 0
	garden_start_time = 0.0 
	#----BASE REWARD AND ENGINE---#
	fruit_reward = p_class_data["start_fruit_reward"]
	max_fruits_on_screen = p_class_data["start_max_fruits"]

	# --- "PULP" META-UPGRADE LEVELS ---
	max_ability_slots = diff_data["start_slots"]
	serpents_coffer_level = 0
	geode_compass_level = 0
	four_leaf_clover_level = 0
	chroma_scales_level = 0
	harvest_forecast_level = 0
	
	#-----------The Core-------------
	# --- Idle Path ---
	snake_clicker_level = 0
	get_rich_quick_unlocked = false
	custom_aftertaste_unlocked = false
	arcane_flow_unlocked = false
	pulp_reactor_unlocked = false
	unstable_metabolism_unlocked = false
	#------Reset Planner Upgrades-----#
	diet_slith_level = 0
	fruit_foresight_unlocked = false
	ghost_tail_level = 0
	geological_survey_unlocked = false
	sovereign_trail_level = 0
	garden_weaver_unlocked = false
	garden_weaver_used_this_garden = false
	# --- The Ledger Path ---
	chosen_ledger_path = ""
	# Path A (Juice Focus)
	liquid_assets_level = 0
	fast_track_unlocked = false
	gluttons_greed_unlocked = false
	market_crash_level = 0
	# Path B (Pulp Focus)
	principal_pulp_level = 0
	golden_handshake_level = 0
	juice_press_used_this_garden = false
	# Juice Press is an active ability, so it will be handled by our hotbar system
	liquidation_used = false
	#------------------------///////////////////////////////////////////////-------------------------
	#-----------The Harvest-------------
	#-------Reset Glutton Upgrades---
	es_portions_level = 0
	more_mice_level = 0
	golden_seeds_level = 0
	patient_gardener_level = 0
	is_bounty_active = false
	the_satchel_unlocked = false
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
	# --- Geomancer Path ---
	fertile_ground_level = 0
	mineral_rich_soil_level = 0
	tectonic_shift_level = 0
	heavy_foundation_level = 0
	# We need to know which Rockeater upgrade they chose
	rockeater_type = "" # e.g., "Rockmuncher", "Geode Cracker", etc.
	calculated_risk_unlocked = false
	#--------------------------||||||||||||||||||\\\\\\\\\\\\\\\\\\\\\\\\///////////////////////////
	#-----------The Redline-------------
		#------Reset Acrobat Upgrades--------#
	slither_sauce_level = 0 
	juke_and_jive_unlocked = false
	afterburner_level = 0
	pop_rocks_unlocked = false
	autotomy_unlocked = false
	autotomy_is_active = false
	autotomy_used_this_garden = false
		# --- Frenzy Path ---
	sugar_rush_unlocked = false
	chain_reaction_level = 0
	overdrive_level = 0
	lingering_rush_level = 0
	juggernaut_unlocked = false
	is_zenith_active = false
	current_combo = 0
	combo_is_pure = true
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
	#-----------The Ssscale-------------
		# Architect Path
	edge_lord_level = 0
	zoning_ordinance_level = 0
	border_czar_unlocked = false
	surveyed_land_unlocked = false
	active_pocket_garden_rect = null
	fold_space_unlocked = false
	masters_blueprint_unlocked = false
	shatter_reality_unlocked = false
		# Illusionist Path
	ghost_tail_level = 0
	three_card_monty_unlocked = false
	fractured_self_unlocked = false
	dazzle_pie_unlocked = false
	#-----------Snake Eyes-------------
	#-------Gambler Path--------
	coin_flip_curious_unlocked = false
	passive_income_unlocked = false
	correct_bets_this_run = 0
	block_market_portfolio = {}
	block_market_prices = {"Orange Block": {"price": 10, "currency": "Juice"}, "Apple Block":  {"price": 10, "currency": "Juice"}, "Light Block":  {"price": 25, "currency": "Pulp"}, "Extra Block":  {"price": 25, "currency": "Pulp"}}	
	
	#-------------finally------------
	reset_for_new_garden()
	SceneTransition.transition_to("res://Scenes/main.tscn", "spiral")
	get_tree().paused = false
