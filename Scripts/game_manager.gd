extends Node

#------Session State---------#
var chosen_difficulty = "viper"
var chosen_class = "speedster"
var run_time: float = 0.0

# --- CLASS & DIFFICULTY MODIFIERS ---
var juice_on_level_up_disabled: bool = false
var juice_chance_on_eat: float = 0.0
var obstacle_modifier: float = 1.0
var geological_survey_multiplies: bool = false
var all_fruits_special: bool = false
var speed_on_loss: bool = false
var speed_increase_on_eat: bool = false
var disabled_paths: Array = []
var speed_multiplier_class_mod: float = 1.0
var dynamic_max_fruits: bool = false
var dynamic_fruit_reward: bool = false
var global_juice_cost_multiplier: float = 1.0
var max_esp_level: int = 20 # The default max level
var gambling_disabled: bool = false
var juice_menu_disabled: bool = false
var pulp_gain_disabled: bool = false
var juice_tax_rate: float = 0.0
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
	9: {"name": "The Garden of Eatin'", "score_goal": 666, "obstacle_count": 50},
	# --- The END ---
	10: {"name": "Revelations", "score_goal": 777, "obstacle_count": 66},
	11: {"name": "The End", "socre_goal": 1000, "obstacle_count": 150},
	12: {"name": "Genesis", "score_goal": 1200, "obstacle_count": 100},
	# --- Endless ---
	13: {"name": "Victory Lap", "score_goal": 99999, "obstacle_count": 0}
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
var legendary_items_seen_this_run: Array = []

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
var meditate_data = [0.0, 2.0, 3.0, 5.0]
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
var principal_pulp_data = [
	1.0, 1.1, 1.25, 1.5, 1.75, # 0-4
	2.0, 2.5, 3.0, 3.5, 4.2, # 5-9
	5.0, 6.0, 7.0, 8.0, 9.0, # 10-14
	10.0, 12.0, 14.0, 16.0, 18.0, #15-19
	100.0
	] # Lvl 0, 1, 2, 3
var golden_handshake_level = 0
var golden_handshake_data = [1.0,
	1.25, 1.5, 2.0, 2.5, 4.0,
	6.0, 8.0, 10.0, 12.5, 25.0
	]
var juice_press_used_this_garden: bool = false
# Juice Press is an active ability, so it will be handled by our hotbar system
var liquidation_used = false

# --- Idle Path ---
var snake_clicker_level = 0
var snake_clicker_data = [
	0.0, 0.1, 0.2, 0.35, 0.5, 0.7, 0.95, 1.0, 1.25, 1.5, #Levels 0-9
	1.75, 2.0, 2.4, 2.8, 3.0, 3.5, 4.0, 4.75, 5.5, 6.25, #Levels 10-19
	7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 14.0, 16.0, 18.0, 20.0, #Levels 20-29
	50.0 #Level 30
	]
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
var chain_reaction_data = [1, 5, 10, 15, 20, 999] # Lvl 0, 1, 2, 3, 4, 5
var overdrive_level = 0
var lingering_rush_level = 0
var lingering_rush_data = [5.0, 5.5, 6.0, 6.5, 7.0, 10.0]
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
	Vector2(12, 9),  # Level 0
	Vector2(16, 12), # Level 1
	Vector2(20, 15), # Level 2
	Vector2(24, 18), # Level 3
	Vector2(28, 21), # Level 4
	Vector2(32, 24), # Level 5
	Vector2(36, 27), # Level 6
	Vector2(40, 30)  # Level 7
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
var ghost_tail_data = [0, 7, 10, 15, 20, 34, 50, 100, 150, 200, 300] # Lvl 0-10
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
	# --- TIER 1: Pacts of Binding ---
	"Pact 1": {
		"name": "Pact 1: Juice Box Hero",
		"description": "A gentle start. You begin with a massive head start in resources and power.",
		"juice_cost_modifier": -1, "speed_multiplier": 1.0, "start_slots": 10, "start_juice": 32,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {
			"Elephant Sized Portions": 3, "More Mice": 2, "Snake Clicker": 3
		}
	},
	"Pact 2": {
		"name": "Pact 2: Pulp Friction",
		"description": "The training wheels are off. You start with your power, but no extra Juice.",
		"juice_cost_modifier": 0, "speed_multiplier": 1.0, "start_slots": 7, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {
			"Elephant Sized Portions": 3, "More Mice": 2, "Snake Clicker": 3
		}
	},
	"Pact 3": {
		"name": "Pact 3: Sink or Slither",
		"description": "The pure experience. No starting bonuses. Good luck.",
		"juice_cost_modifier": 0, "speed_multiplier": 1.0, "start_slots": 5, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {}
	},
	"Pact 4": {
		"name": "Pact 4: The Zoomies",
		"description": "The garden moves at a frantic pace, leaving little room for error.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {}
	},
	"Pact 5": {
		"name": "Pact 5: The Blender",
		"description": "The garden is wild and untamed, choked with obstacles.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {},
		"obstacle_modifier": 1.5
	},

	# --- TIER 2: The Three Trials ---
	"Trial of the Harvest": {
		"name": "Seal of the Harvest", "description": "Prove your mastery over consumption. Only The Harvest path is available.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["The Core", "The Redline", "The Ssscale"],
		"start_upgrades": {"Edge Lord": 7}
	},
	"Trial of the Core": {
		"name": "Seal of the Core", "description": "Back to square one. Only Core path available.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["The Harvest", "The Redline", "The Ssscale"],
		"start_upgrades": {"Edge Lord": 7}
	},
	"Trial of the Redline": {
		"name": "Seal of the Redline", "description": "Go fast for once! Redline path only.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["The Core", "The Harvest", "The Ssscale"],
		"start_upgrades": {"Edge Lord": 7}
	},

	# --- TIER 3: The Cursed Pacts ---
	"Cursed Pact 1": {
		"name": "Cursed Pact I: Empty-Handed", "description": "You must earn your power. You start with no ability slots.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {}
	},
	"Cursed Pact 2": {
		"name": "Cursed Pact II: Forced Diet", "description": "The path of gluttony is closed to you.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["Glutton"], "start_upgrades": {}
	},
	"Cursed Pact 3": {
		"name": "Cursed Pact III: Thin Margins", "description": "The path of ledger is closed to you.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["Glutton", "Ledger"], "start_upgrades": {}
	},
	"Cursed Pact 4": {
		"name": "Cursed Pact IV: Extension Granted", "description": "Win after Garden 12",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 12, "locked_paths": ["Glutton", "Ledger"], "start_upgrades": {}
	},

	"Cursed Pact 5": {	#FINAL
		"name": "Cursed Pact V: Black Mamba", "description": "This is it...this is what they asked for!",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 13, "locked_paths": ["Glutton", "Ledger"], "start_upgrades": {}
	}
}
#---------CLASS PARAMETERS--------#
var class_data = {
	"Mulligan": {
		"name": "Mulligan",
		"description": "The balanced, default experience. Starts with an Extra Life and a solid foundation for any build.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Phoenix Dawn": 1
		},
		"start_stats": {
			"extra_lives": 1,
			"max_fruits": 2 # Starts with 2 max fruits instead of the default 1
		},
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Purist": {
		"name": "Purist",
		"description": "A master of the garden with a disdain for the stench of RNG",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Patient Gardener": 3, # Starts with this maxed out
			"Elephant Sized Portions": 3
		},
		"start_stats": {
			"gambling_disabled": true # A new flag to disable the Snake Eyes tab
		},
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Larry": {
		"name": "Larry",
		"description": "The ultimate roguelike challenge. You are at the mercy of fate.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {},
		"start_stats": {
			"juice_menu_disabled": true # A new flag to disable the Juice upgrade menu
		},
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Phoenix Coil": {
		"name": "Phoenix Coil",
		"description": "An immortal being who has traded worldly wealth for eternal life.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Death Defied": 1
		},
		"start_stats": {
			"extra_lives": 9,
			"pulp_gain_disabled": true # A new flag to prevent earning Pulp
		},
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Tycoon": {
		"name": "Tycoon",
		"description": "A master of passive income who must spend to succeed.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Snake Clicker": 7
		},
		"start_stats": {
			"juice_tax_rate": 0.40 # A new custom stat we'll implement
		},
		"cost_modifiers": { #NEED TO DISCOUNT IDEL, INCREASE OTHERS
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Day Trader": { 
		"name": "Day Trader",
		"description": "A fast-start economist who sacrifices raw power for economic velocity.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Liquid Assets": 3,
			"Fast Track": 1
		},
		"start_stats": {
			"max_esp_level": 5 # A new flag to cap the ESP upgrade
		},
		"cost_modifiers": { #NEED TO DISCOUNT JUICE LEDGER PATHA, INCREASE OTHERS
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Manager": {
		"name": "Manager",
		"description": "A patient investor who leverages Pulp for massive late-game power.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Principal Pulp": 5,
			"Juice Press": 1
		},
		"start_stats": {
			"global_juice_cost_multiplier": 1.20 # A new custom stat
		},
		"cost_modifiers": { #NEED TO DISCOUNT LEDGER PATHB, INCREASE OTHERS
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Calculator": {
		"name": "Calculator",
		"description": "A strange being whose power is a reflection of its own state.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {},
		"start_stats": {
			# These two flags will trigger new logic in our helper functions
			"dynamic_fruit_reward": true, 
			"dynamic_max_fruits": true
		},
		"cost_modifiers": { #PROLLY DOESN'T NEED ANY MODIFIERS, WE'LL SEE
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Ghost": {
		"name": "Ghost",
		"description": "An ethereal being who channels their magical nature into raw power.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Ghost Tail": 4,
			"Arcane Flow": 1,
			"Snake Clicker": 3
		},
		"start_stats": {},
		"cost_modifiers": { #discount ILLUSIONIST AND IDLE
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Space": {
		"name": "Space",
		"description": "An absolute master of the garden's layout, with incredible speed to match.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Edge Lord": 7,
			"Shatter Reality": 1
		},
		"start_stats": {
			"speed_multiplier": 0.50, # A 50% speed increase
			"disabled_paths": ["Idle"]
		},
		"cost_modifiers": { #DICOUNT ARCHITECT UPGRADES
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Blinker": {
		"name": "Blinker",
		"description": "A high-skill class focused on a single, powerful reality-bending mechanic.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Fractured Self": 1
		},
		"start_stats": {},
		"cost_modifiers": { #DISCOUNT ILLUSIONIST
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Psychic": {
		"name": "Psychic",
		"description": "A master of foresight whose power creates a dangerous feedback loop.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Fruit Foresight": 1,
			"Diet Slith": 5,
			"Meditate": 3
		},
		"start_stats": {
			# This new flag will trigger our new speed-up logic
			"speed_increase_on_eat": true 
		},
		"cost_modifiers": { #DISCOUNT PLANNER, INCREASE ARCHITECT AND GLUTTON
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Doubles": {
		"name": "Doubles",
		"description": "A pure gambler who thrives on risk and gets faster with every failure.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Coin Flip Curious": 1,
			"Passive Income": 1
		},
		"start_stats": {
			"disabled_paths": ["Planner"],
			"speed_on_loss": true # A new flag for our custom logic
		},
		"cost_modifiers": {# INCREASE GLUTTON AND LEDGER
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Comboisseur": {
		"name": "Comboisseur",
		"description": "The ultimate combo master, with a unique challenge and a massive payoff.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Sugar Rush": 1,
			"Chain Reaction": 1,
			"Overdrive": 2,
			"Lingering Rush": 2,
			"Diet Slith": 3
		},
		"start_stats": {
			"all_fruits_special": true # A new flag for our custom logic
		},
		"cost_modifiers": { #DISCOUNT FRENZY PATH AND CHEF, INCREASE ALL OTHER PATHS NOT REDLINER
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Sniper": {
		"name": "Sniper",
		"description": "A focused predator who lives for the thrill of the hunt.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Banana Bounty": 2,
			"More Mice": 4 # Base 1 + 4 = 5 max fruits
		},
		"start_stats": {
			"disabled_paths": ["Magician"]
		},
		"cost_modifiers": { #DISCOUNT GLUTTON AND INCREASE FRENZY AND GEODE
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Mineral": {
		"name": "Mineral",
		"description": "A true master of the earth who sees rocks not as obstacles, but as investments.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Geological Survey": 1
		},
		"start_stats": {
			"obstacle_modifier": 1.5, # A 50% increase in rocks
			"geological_survey_multiplies": true # A flag for our custom bonus logic
		},
		"cost_modifiers": { #DISCOUNT GEOMANCER, INCREASE ARCHITECT
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Gobble": {
		"name": "Gobble",
		"description": "A master of ingredients who has learned to harness their very essence.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Exotic Seeds": 3,
			"Custom Aftertaste": 1,
			"Snake Clicker": 3
		},
		"start_stats": {},
		"cost_modifiers": { #discount chef and idle, increase glutton
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Gluts": {
		"name": "Gluts",
		"description": "All-in on growth, but with a major logistical challenge.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {},
		"start_stats": {
			"fruit_reward_multiplier": 2.0,
			"max_fruits_cap": 1
		},
		"cost_modifiers": { #discount glutton, nothing else
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Groove": {
		"name": "Groove",
		"description": "A jack-of-all-trades who combines speed and passive income.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {
			"Juke N Jive": 1,
			"Mulligan Munchie": 1,
			"Get Rich Quick": 1,
			"Snake Clicker": 3
		},
		"start_stats": {},
		"cost_modifiers": { #discount all starting skills, increase glutton
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
	"Alchemist": {
		"name": "Alchemist",
		"description": "Does not gain Juice from leveling up. Every fruit has a 10% chance to grant 1 Juice instead.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"start_upgrades": {},
		"start_stats": {
			"juice_on_level_up_disabled": true,
			"juice_chance_on_eat": 0.25
		},
		"cost_modifiers": { #discount chef and glutton and illusionist. increase everything else
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
			"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
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
		"Idle": { #Total Tree cost = 1222
			"Snake Clicker": {
				"display_name": "Snake Clicker",
				"description": "Passively grow over time.\nEach level increases your Growth Per Second (GPS).",
				"costs": [ #1086 total cost
					1, 2, 3, 4, 6,
					10, 12, 14, 16, 18,
					20, 22, 24, 26, 28,
					30, 32, 34, 36, 38,
					40, 44, 48, 52, 56,
					60, 65, 70, 75, 200,
				],
				"max_level": 30
			},
			"Get Rich Quick": {
				"display_name": "Get Rich Quick",
				"description": "Your Speed Hero!\nGain +0.1 GPS for every mL spent in the Acrobat tree.",
				"costs": [24], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1}
			},
			"Custom Aftertaste": {
				"display_name": "Custom Aftertaste",
				"description": "Your Cooking Hero!\nGain +0.1 GPS for every mL spent in the Chef tree.",
				"costs": [24], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1}
			},
			"Arcane Flow": {
				"display_name": "Arcane Flow",
				"description": "Your white mage! Just kidding\nYour Wizard Hero!\nGain +0.1 GPS for every mL spent in the Illusionist tree.",
				"costs": [24], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1}
			},
			"Pulp Reactor": {
				"display_name": "Pulp Reactor",
				"description": "GPS is permanently increased by +1\nfor every 100 Pulp you are currently holding.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Snake Clicker", "level": 3}
			},
			"Unstable Metabolism": {
				"display_name": "Unstable Metabolism",
				"description": "Permanently doubles your total GPS\nThat's it, fetch!",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Snake Clicker", "level": 3}
			}
		},
		
		"Planner": { #900 total
			"Diet Slith": { #555 total
				"display_name": "Diet Slith",
				"description": "Decrease your speed by 5%\nSugar Free!",
				"costs": [
					3, 6, 9, 12, 15,
					20, 25, 30, 35, 40,
					50, 60, 70, 80, 100
					], # 15 levels total
				"max_level": 15
			},
			"Fruit Foresight": {
				"display_name": "Fruit Foresight",
				"description": "See the next fruit!\nUse responsibly",
				"costs": [12], # One-time purchase
				"max_level": 1,
				"prerequisite": {"upgrade": "Diet Slith", "level": 5} # Requires Diet Slith Lvl 2
			},
			#New geological survey... ooo lala
			"Geological Survey": {
			"display_name": "Geological Survey", "max_level": 1, "costs": [16],
			"description": "Gain bonus Juice at end of Garden\nMore rocks = More Juice",
			"prerequisite": {"upgrade": "Diet Slith", "level": 5}
			},
			"Sovereign Trail": { #72 total
				"display_name": "Sovereign Trail",
				"description": "Leave your mark. Your trail affects where new fruits can spawn.",
				"costs": [8, 64], # Lvl 1: Repel, Lvl 2: Attract
				"max_level": 2,
				"prerequisite": {"upgrade": "Diet Slith", "level": 3}
			},
			"Meditate": { #Levels 1-4 195
				"display_name": "Meditate",
				"costs": [15, 30, 60, 100, 200, 500, 1000, 2500, 5000],
				"description": "Pause! Need I say more?\nRequires Diet Slith lvl 7",
				"max_level": 9,
				"prerequisite": {"upgrade": "Diet Slith", "level": 7}
			},
			"Garden Weaver": {
				"display_name": "Garden Weaver",
				"description": "Reroll all the fruits MUCH closer!\nRequires Diet Slith Lvl 7",
				"costs": [50],
				"max_level": 1,
				"prerequisite": {"upgrade": "Diet Slith", "level": 7}
			}
		},
		"Ledger": {
			# --- Tier 1 (The Choice) ---
			"Liquid Assets": { #2501 up to lvl 10
				"display_name": "Liquid Assets", 
				"max_level": 15, 
				"costs": [
					1, 10, 30, 60, 100, #201
					150, 250, 400, 600, 900, #2300
					1200, 1800, 2400, 5000, 9999 #20,399
					],
				"description": "Each level grants\n+1 Juice on level up.",
				"exclusive_with": "Principal Pulp" # This new key locks the other option
			},
			"Principal Pulp": { # 4716mL total
				"display_name": "Principal Pulp",
				"max_level": 20,
				"costs": [
					1, 5, 10, 15, 24, #55
					36, 50, 75, 100, 125, #386
					150, 175, 200, 250, 300, #1075
					400, 500, 600, 700, 1000 #3200
					],
				"description": "Multiplies base Pulp reward\nfrom base score at end of Garden.",
				"exclusive_with": "Liquid Assets"
			},

			# --- Path A (Juice Focus) Upgrades ---
			"Fast Track": {
				"display_name": "Fast-Track", "max_level": 1, "costs": [1],
				"description": "Unlocks the 'Skip Garden' button in the Pulp Stand,\nOn skip, +5mL Juice.",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 1}
			},
			"Gluttons Greed": {
				"display_name": "Glutton's Greed", "max_level": 1, "costs": [16],
				"description": "Quantity or Quality, or...\nIncrease fruit reward by max fruits",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 2}
			},
			"Market Crash": { #1129
				"display_name": "Market Crash", "max_level": 10, "costs": [1, 8, 15, 30, 50, 75, 100, 150, 200, 500],
				"description": "Permanently reduce the Juice cost of all upgrades.\nLvl 1: -1mL\nLvl 2: -2mL",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 3}
			},

			# --- Path B (Pulp Focus) Upgrades ---
			"Golden Handshake": { #567
				"display_name": "Golden Handshake", "max_level": 10, "costs": [3, 4, 5, 15, 25, 40, 65, 90, 120, 200],
				"description": "Multiplies all BONUS Pulp rewards\n(Flawless, Par Time, etc.) at the end of each Garden.",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1}
			},
			"Juice Press": {
				"display_name": "Juice Press", "max_level": 1, "costs": [64],
				"description": "Active Ability (Once per Garden):\nConvert all your current Pulp into Juice\nat a 5mg:1mL ratio.",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1}
			},
			"Liquidation": {
				"display_name": "Liquidation", "max_level": 1, "costs": [1],
				"description": "Instantly double your current Juice\nNo strings attached",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1}
			}
		}
	},#---------------------------------------------------------------------------------------------#
	#---------------------------HARVEST (GLUTTON, CHEF, GEOMANCER-----------------------------------#
	#-----------------------------the glutton----------------------------#
	"The Harvest": {
		"Glutton": { #2760 total
			"Elephant Sized Portions": { #781
				"display_name": "Elephant Sized Portions",
				"description": "Increase growth per fruit.\n+1 per level (depending on class)",
				"costs": [
					3,5,7,9,12, #36
					16,20,24,28,32, #120
					35,40,45,50,55, #225
					60,70,80,90,100 #400
					],
				"max_level": 20
			},
			"More Mice": { #1188
				"display_name": "More Mice!",
				"description": "Increases maximum number of fruits\n+1 per level",
				"costs": [
					5,10,18,30,50,
					75,100,150,250,500
					],
				"max_level": 10,
			},
			"Golden Seeds": { #267
				"display_name": "Golden Seeds",
				"description": "Unlocks Golden Apples, which grant Juice.\nEach level increases their spawn chance and reward.",
				"costs": [7, 35, 75, 150],
				"max_level": 4,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3}
			},
			"Patient Gardener": { #200
				"display_name": "Patient Gardener",
				"description": "Fruits will ripen over time,\ngranting bonus growth\nLvl 3 = X3 bonuse",
				"costs": [16, 64, 128],
				"max_level": 3,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3}
			},
			"Banana Bounty": { #First 5: 260
				"display_name": "Banana Bounty",
				"description":  "Active Ability: Marks a fruit as a\nhigh-value bounty for massive growth.",
				"costs": [16, 32, 48, 64, 100, 250, 500, 1000, 2500],
				"max_level": 9,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 5}
			},
			"The Satchel": { #64
				"display_name": "The Satchel",
				"description": "Permanently unlocks another active ability slot.",
				"costs": [64],
				"max_level": 1,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 10, "and": "Golden Seeds", "and_level": 4}
			}
		},
		
		"Chef": {
			"Golden Seed Extract": { # 79
				"display_name": "Golden Seed Extract",
				"description": "A potent concoction. Increases the spawn chance of valuable Golden Apples.",
				"costs": [3, 12, 64], # Example costs for 3 levels
				"max_level": 3
			},
			"Exotic Seeds": {
				"display_name": "Exotic Seeds",
				"description": "A taste for the strange.\nAdds new, rare fruits to the spawn pool.",
				"costs": [4, 12, 24, 36, 81], # 5 levels
				"max_level": 5
			},
			"The Cookbook": {
				"display_name": "The Cookbook",
				"description": "Unlocks the Recipe system,\ngranting temporary buffs for eating fruit in a specific sequence.",
				"costs": [1],
				"max_level": 1,
				"prerequisite": {"upgrade": "Golden Seed Extract", "level": 1}
			},
			"Expanded Palate": {
				"display_name": "Expanded Palate",
				"description": "Adds new, more complex and powerful recipes to your Cookbook.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1}
			},
			"Golden Glaze": {
				"display_name": "Golden Glaze",
				"description": "Golden Apples now act as a 'wild card' ingredient\nfor any step in your current recipe.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1}
			},
			"Custom Cuisine": {
				"display_name": "Custom Cuisine",
				"description": "Permanently enhances all special fruits with powerful secondary effects!",
				"costs": [50],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1, "and": "Exotic Seeds", "and_level": 1}
			},
			"Mise en Place": {
				"display_name": "Mise en Place",
				"description": "Active Ability (Once per RUN):\nInstantly transforms all normal fruits on screen into random special fruits.",
				"costs": [96],
				"max_level": 1,
				"prerequisite": {"upgrade": "Exotic Seeds", "level": 5}
			}
		},
		
		"Geode": {
			"Fertile Ground": {
				"display_name": "Fertile Ground", "max_level": 3, "costs": [4, 16, 64],
				"description": "Each level grants +1 to Max Fruits\nbut adds +5 rocks to every garden."
			},
			"Mineral Rich Soil": {
				"display_name": "Mineral-Rich Soil", "max_level": 3, "costs": [4, 8, 16],
				"description": "Each level grants +1 to Fruit Reward\nbut adds +5 rocks to every garden."
			},
			"Tectonic Shift": {
				"display_name": "Tectonic Shift", "max_level": 3, "costs": [2, 4, 8],
				"description": "Each level grants a speed boost\nbut adds +5 rocks to every garden."
			},
			"Heavy Foundation": {
				"display_name": "Heavy Foundation", "max_level": 3, "costs": [4, 8, 16],
				"description": "Each level grants a speed decrease\nbut adds +5 rocks to every garden."
			},

			# --- GEOMANCER TIER 2 (ROCKEATERS) ---
			"Rockmuncher": {
				"display_name": "Rockmuncher", "max_level": 1, "costs": [32],
				"description": "You can now eat rocks,\nwhich grant +2 growth.",
				"prerequisite": {"upgrade": "Fertile Ground", "level": 3}
			},
			"Geode Cracker": {
				"display_name": "Geode Cracker", "max_level": 1, "costs": [32],
				"description": "You can now eat rocks,\nwhich have a chance to grant +1 Juice.",
				"prerequisite": {"upgrade": "Mineral Rich Soil", "level": 3}
			},
			"Kinetic Feast": {
				"display_name": "Kinetic Feast", "max_level": 1, "costs": [32],
				"description": "You can eat rocks and\nyou get a speed boost after eating the rock",
				"prerequisite": {"upgrade": "Tectonic Shift", "level": 3}
			},
			"Stones Burden": {
				"display_name": "Stone's Burden", "max_level": 1, "costs": [32],
				"description": "Eating a rock slows you but grants temporary invulnerability.",
				"prerequisite": {"upgrade": "Heavy Foundation", "level": 3}
			},

			# --- GEOMANCER KEYSTONE ---
			"Calculated Risk": {
				"display_name": "Calculated Risk", "max_level": 1, "costs": [64],
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
				"costs": [1, 1, 1, 1, 10, 20, 40, 60, 80, 100],
				"max_level": 10
			},
			"Tenderizer": {
				"display_name": "Tenderizer",
				"description": "Destroy a rock on impact.\nHas limited charges, which refresh on level up.\nEach level grants another charge.",
				"costs": [8, 12, 16, 32, 64, 128, 256, 512, 999],
				"max_level": 9,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 3}
			},
			"Juke N Jive": {
				"display_name": "Juke 'N Jive",
				"description": "Changing direction 4 times in 1 second\nlets you phase through a body segment\nGet groovin'",
				"costs": [12],
				"max_level": 1,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 3}
			},
			"Afterburner": {
				"display_name": "Afterburner",
				"description": "Speed boost after eating a fruit?",
				"costs": [6, 12, 48],
				"max_level": 3,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 3}
			},
			"Pop Rocks": {
				"display_name": "Pop Rocks",
				"description": "When you destroy a rock with Tenderizer,\nit creates a shockwave that destroys adjacent rocks.",
				"costs": [16],
				"max_level": 1,
				"prerequisite": {"upgrade": "Tenderizer", "level": 1}
			},
			"Autotomy": {
				"display_name": "Autotomy",
				"description": " Active Ability: Sever your own tail on impact\nto survive a fatal crash.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 6}
			}
		},
		"Frenzy": {
			"Sugar Rush": {
				"display_name": "Sugar Rush",
				"description": "Unlocks the Combo Meter,\nwhich tracks fruits eaten in quick succession.",
				"costs": [3],
				"max_level": 1
			},
			"Chain Reaction": {
				"display_name": "Chain Reaction",
				"description": "Make the combo meter do something!\nEach level increases the max combo by 5\nLvl 5: no unlimited combo",
				"costs": [5, 10, 15, 20, 32],
				"max_level": 5,
				"prerequisite": {"upgrade": "Sugar Rush", "level": 1}
			},
			"Overdrive": {
				"display_name": "Overdrive",
				"description": "While combo is active,\nhold your current direction key for a speed boost.",
				"costs": [16, 1], # Lvl 2 is cheap for the cosmetic!
				"max_level": 2,
				"prerequisite": {"upgrade": "Sugar Rush", "level": 1}
			},
			"Lingering Rush": {
				"display_name": "Lingering Rush",
				"description": "Increases the duration of the combo timer,\nmaking it easier to chain fruits.",
				"costs": [6, 12, 18, 24, 64],
				"max_level": 5,
				"prerequisite": {"upgrade": "Sugar Rush", "level": 1}
			},
			"Juggernaut": {
				"display_name": "Juggernaut",
				"description": "While your combo is pure\n(you haven't opened the upgrade menu),\nthe combo timer is paused.",
				"costs": [25],
				"max_level": 1,
				"prerequisite": {"upgrade": "Lingering Rush", "level": 5}
			},
			"Zenith": {
				"display_name": "Zenith",
				"description": "Active Ability: Instantly set your combo to 10 and freeze the timer.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Lingering Rush", "level": 5} # Example prerequisite
				}
			},
		"Survivor": {
			"Mulligan Munchie": {
				"display_name": "Mulligan Munchie",
				"description": "Grants one Extra Life.\nYou got it for sure...",
				"costs": [5, 20, 50, 100, 200, 300, 400, 500, 750, 999], # Example scaling costs
				"max_level": 10
			},
			"Phoenix Dawn": {
				"display_name": "Phoenix Dawn",
				"description": "After using an Extra Life,\nthe next fruit you eat restores 25% of your lost length.",
				"costs": [7], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 1}
			},
			"Last Stand": {
				"display_name": "Last Stand",
				"description": "While on your final life,\nthe chance for Golden Apples to spawn is significantly increased.",
				"costs": [32], "max_level": 1,
			},
			"Sacrificial Molt": {
				"display_name": "Sacrificial Molt",
				"description": "Active Ability (Once per RUN):\nHalve your current length to instantly gain one Extra Life charge.",
				"costs": [16], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 1}
			},
			"Death Defied": {
				"display_name": "Death Defied",
				"description": "Every time you use an Extra Life, permanently gain +1 to your Fruit Reward and Max Fruits on Screen for this run.",
				"costs": [20], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 2}
			},
			"Martyrdom": {
				"display_name": "Martyrdom",
				"description": "Upon your final death, your snake explodes,\nharvesting all fruit on screen\nfor a final score boost.",
				"costs": [13], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 2}
			},
			"New Game S Plus": {
				"display_name": "New Game S+",
				"description": "PRESTIGE! Beat the game without dying to restart with all your power",
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
				"description": "Your last few tail segments become intangible.\nLvl 1: 7, Lvl 10: 300",
				"costs": [6, 12, 20, 34, 50, 100, 200, 300, 500, 1000],
				"max_level": 10
			},
			"Phase Shift": {
				"display_name": "Phase Shift",
				"description": "Active Ability: Become intangible to your own body for a short time.\nEach level grants another charge.",
				"costs": [4, 8, 12, 16, 20, 64, 128, 256, 512, 999],
				"max_level": 10,
				"exclusive_with": "Blink" # Can't have both
			},
			"Blink": {
				"display_name": "Blink",
				"description": "Active Ability: Instantly teleport forward 3 tiles.\nPass through your old hole!",
				"costs": [2, 4, 6, 20, 32, 64, 128, 256, 512, 999],
				"max_level": 10,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 2},
				"exclusive_with": "Phase Shift"
			},
			"3 Card Monty": {
				"display_name": "3-Card Monty",
				"description": "Permanently reduces the Juice cost of\nall other upgrades by 1 (to a minimum of 1).",
				"costs": [3],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 5}
			},
			"Fractured Self": {
				"display_name": "Fractured Self",
				"description": "Your body is now rendered in 3-segment chunks",
				"costs": [64],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 5}
			},
			"Dazzle Pie": {
				"display_name": "Dazzle Pie",
				"description": "A permanent, purely aesthetic transformation that adds\na chromatic aberration effect to the game.",
				"costs": [1],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 7},
				"exclusive_with": "Masters Blueprint"
		}
	},	
			
		"Architect": {
			"Edge Lord": {
				"display_name": "Edge Lord",
				"description": "Increases the size of the play area.",
				"costs": [2, 4, 8, 16, 32, 64, 128],
				"max_level": 7
			},
			"Zoning Ordinance": {
				"display_name": "Zoning Ordinance",
				"description": "Designate a quadrant as a 'safe zone' with fewer obstacles\nLvl 1: Top Left\nLvl 2: Top Half\nLvl 3: 1 quadrant not safe\nLvl 4: Complete control",
				"costs": [6, 18, 32, 128],
				"max_level": 4,
				"prerequisite": {"upgrade": "Edge Lord", "level": 2}
			},
			"Border Czar": {
				"display_name": "Border Czar",
				"description": "Control the borders, control the world.\nFruit on the edge is more likely to be special.",
				"costs": [16],
				"max_level": 1,
				"prerequisite": {"upgrade": "Edge Lord", "level": 3}
			},
			"Surveyed Land": {
				"display_name": "Surveyed Land",
				"description": "A double-edged sword.\nCreate a \"wilderness\" with better fruit but more rocks.",
				"costs": [8],
				"max_level": 1,
				"prerequisite": {"upgrade": "Zoning Ordinance", "level": 1}
			},
			"Burrow": {
				"display_name": "Burrow",
				"description": "Active Ability: Pass through one wall\nand emerge on the opposite side.\nAbility lasts until next wall hit!",
				"costs": [7, 12, 20, 34, 64, 128, 256, 512, 999],
				"max_level": 9,
				"prerequisite": {"upgrade": "Edge Lord", "level": 4} # This should be 4 to match max_level
			},
			"Pocket Garden": {
				"display_name": "Pocket Garden",
				"description": "Active Ability: Sacrifice tail segments to\ncreate a temporary 5x5 safe zone that spawns fruit.\nLvl increases duration and segment cost",
				"costs": [16, 32, 128],
				"max_level": 3,
				"prerequisite": {"upgrade": "Edge Lord", "level": 4} # This should be 4
			},
			"Fold Space": {
				"display_name": "Fold Space", 
				"description": "Removes all walls,\nmaking the garden wrap around on itself.",
				"costs": [128], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 5, "and": "Burrow", "and_level": 3},
				"exclusive_with": "Shatter Reality" # <-- makes it mutually exclusive
			},
			"Shatter Reality": {
				"display_name": "Shatter Reality", 
				"description": "Splits the garden into\nfour quadrants with connecting portals.",
				"costs": [128], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 5},
				"exclusive_with": "Fold Space" # <-- makes it mutually exclusive
			},
			"Masters Blueprint": {
				"display_name": "Masters Blueprint", 
				"description": "Transforms the game's visuals into a clean, glowing blueprint grid.",
				"costs": [13], 
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
			"description": "A 50/50 chance.\nEvery fruit grants double growth or zero growth\nGamble Responsibly...",
			"costs": [6],
			"max_level": 1
		},
		"Passive Income": {
			"display_name": "Passive Income",
			"description": "Every bet won results in a +1 to your fruit reward\nYou heard me...get on with it!",
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
		"costs": [200, 250, 500, 750, 1000, 1500, 2000, 3000, 4000, 9999], # Costs for slots 1 through 10
		"max_level": 10 
	},
	"Serpents Coffer": {
		"description": "Gain 'interest' on your unspent\nPulp at the end of each Garden.",
		"costs": [50, 200, 500, 1000],
		"max_level": 4
	},
	"Geode Compass": {
		"description": "Permanently removes a percentage of\nobstacles from all subsequent gardens.",
		"costs": [75, 200, 600, 1250],
		"max_level": 4,
		
	},
	"Four Leaf Clover": {
		"description": "Permanently increases your 'luck,'\nboosting the chance of all random events.",
		"costs": [42, 69, 340, 1000],
		"max_level": 4
	},
	"Chroma Scales": {
		"description": "Activate the cosmetic options\nyou've permanently unlocked in the Fang Fund.",
		"costs": [1, 1, 1, 1, 1, 1],
		"max_level": 6
	},
	"Lasso Larry": {
		"display_name": "Lasso Larry",
		"description": "Active Ability: Randomly rerolls a fruit!\nLvl 1: Pulls 1 fruit.\nLvl 2: Pulls 2 fruits.\nLvl 3: Pulls 3 fruits.",
		"costs": [125, 500, 1000],
		"max_level": 3
	},
	"Harvest Forecast": {
		"display_name": "Harvest Forecast",
		"description": "Adds a UI element showing the next\nspecial fruits in the spawn queue.\nLvl 1-3: Shows 1-3 special fruit.\nLvl 4: Shows the next 5 fruits",
		"costs": [100, 200, 300, 1000],
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
		"cost": 30,
		"rarity": "Common",
		"max_level": 1
	}
]	# ... (add more common items here later)

var rare_items = [
	{
		"id": "handicap",
		"name": "Handicap",
		"description": "A deal with the devil.\nInstantly unlock a new Ability Slot,\nbut your maximum Extra Lives is now permanently capped at 0.",
		"cost": 0,
		"rarity": "Rare",
		"max_level": 1
	},
	# ... (add more rare items here later)
]

var legendary_items = [
	{
		"id": "elephant_devoured",
		"name": "Elephant Devoured",
		"description": "A truly legendary meal.\nInstantly raises your 'Elephant Sized Portions'\nupgrade to its maximum level.",
		"cost": 150,
		"rarity": "Legendary",
		"max_level": 1,
		"targets_upgrade": "Elephant Sized Portions"
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
			while es_portions_level < upgrade_data["The Harvest"]["Elephant Sized Portions"]["max_level"]:
				apply_esp_level_up()


func reset_for_new_garden():
	# This function resets all stats that should be fresh for a new garden.
	
	# Reset the player's level back to 1.
	player_level = 1
	
	# Reset the XP and goals back to their starting values.
	score_at_level_start = 0
	score_needed_for_next_level = 5 # Or your initial starting value
	
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
	
	if all_fruits_special:
		if not unlocked_specials.is_empty():
			for i in range(100):
				fruit_deck.append(unlocked_specials.pick_random())
	else:
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


func get_upgrade_rules(upgrade_key: String) -> Dictionary:
	for path_key in GameManager.upgrade_data:
		for sub_path_key in GameManager.upgrade_data[path_key]:
			if upgrade_key in GameManager.upgrade_data[path_key][sub_path_key]:
				var rules = GameManager.upgrade_data[path_key][sub_path_key][upgrade_key]
				rules["path"] = path_key
				rules["sub_path"] = sub_path_key
				return rules
	return {}


func check_prerequisites(upgrade_key: String) -> bool:
	var rules = GameManager.get_upgrade_rules(upgrade_key)
	if not rules.has("prerequisite"): return true
	if rules.is_empty(): return false # Double check this line

	var prereq_data = rules["prerequisite"]
	if get_upgrade_level_from_key(prereq_data["upgrade"]) < prereq_data["level"]:
		return false
		
	if prereq_data.has("and") and get_upgrade_level_from_key(prereq_data["and"]) < prereq_data["and_level"]:
		return false
		
	return true

func calculate_upgrade_cost(upgrade_key: String) -> int:
	var rules = get_upgrade_rules(upgrade_key)
	var current_level = get_upgrade_level_from_key(upgrade_key)
	
	if current_level >= rules.max_level: return 999 # A high number for "unaffordable"
	
	var base_cost = rules.costs[current_level]
	var diff_mod = difficulty_data[GameManager.chosen_difficulty]["juice_cost_modifier"]
	var class_mod = class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
	var final_cost = base_cost + diff_mod + class_mod
	
	# Apply cost reduction upgrades
	if GameManager.three_card_monty_unlocked and upgrade_key != "3 Card Monty":
		final_cost -= 1
	if GameManager.market_crash_level > 0 and upgrade_key != "Market Crash":
		final_cost -= GameManager.market_crash_level
		
	return max(1, final_cost)

func get_upgrade_level_from_key(upgrade_key: String) -> int:
	if upgrade_key == "Elephant Sized Portions":
		return es_portions_level
	
	if upgrade_key == "Mulligan Munchie":
		return extra_lives
	
	if upgrade_key in ability_charges:
		return ability_charges[upgrade_key].total
	
	var var_name_level = upgrade_key.to_snake_case().replace(" ", "") + "_level"
	if var_name_level in GameManager:
		return GameManager.get(var_name_level)
		
	var var_name_unlocked = upgrade_key.to_snake_case().replace(" ", "") + "_unlocked"
	if var_name_unlocked in GameManager:
		return 1 if GameManager.get(var_name_unlocked) else 0

	return 0

func apply_esp_level_up():
	# It now uses its OWN helper function to get the rules.
	var rules = get_upgrade_rules("Elephant Sized Portions")
	
	# We check against the max_level defined in the rules.
	if es_portions_level < rules.get("max_level", 20):
		es_portions_level += 1
		# The fruit_reward is now handled by get_effective_fruit_reward,
		# so we no longer need to change it here. This is much cleaner.
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
	var diff_data = difficulty_data.get(chosen_difficulty, {})
	# Reset all stats for a new run
	player_level = 1
	juice = 0
	juice += diff_data.get("start_juice", 0)	# add starting sp
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
	
	
	
	
		# --- CLASS & DIFFICULTY MODIFIERS ---
	juice_on_level_up_disabled = false
	juice_chance_on_eat = 0.0
	obstacle_modifier = 1.0
	geological_survey_multiplies = false
	all_fruits_special = false
	speed_on_loss = false
	speed_increase_on_eat = false
	disabled_paths = []
	speed_multiplier_class_mod = 1.0
	dynamic_max_fruits = false
	dynamic_fruit_reward = false
	global_juice_cost_multiplier = 1.0
	max_esp_level = 20 # The default max level
	gambling_disabled = false
	juice_menu_disabled = false
	pulp_gain_disabled = false
	juice_tax_rate = 0.0
	
	
	# --- NEW ABILITY SYSTEM RESET ---
	ability_charges.clear()
	equipped_abilities.clear()
	legendary_items_seen_this_run.clear()


	juice_spent_this_garden = 0
	abilities_used_this_garden = 0
	garden_start_time = 0.0 
	#----BASE REWARD AND ENGINE---#

	# --- "PULP" META-UPGRADE LEVELS ---
	max_ability_slots = diff_data.get("start_slots", 0)
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
	
	
	#------apply difficulty multipliers--------
	var diff_upgrades = diff_data.get("start_upgrades", {})
	for upgrade_key in diff_upgrades:
		_apply_starting_upgrade(upgrade_key, diff_upgrades[upgrade_key])

	# --- 4. Apply Modifiers from the chosen CLASS ---
	var class_upgrades = class_data.get("start_upgrades", {})
	for upgrade_key in class_upgrades:
		_apply_starting_upgrade(upgrade_key, class_upgrades[upgrade_key])
		
	var class_stats = class_data.get("start_stats", {})
	for stat_key in class_stats:
		match stat_key:
			"extra_lives": extra_lives += class_stats[stat_key]
			"max_fruits": max_fruits_on_screen = class_stats[stat_key]
			"fruit_reward_multiplier": fruit_reward *= class_stats[stat_key]
			"max_fruits_cap": max_fruits_on_screen = class_stats[stat_key] # This will need a check in the "More Mice" upgrade
			"juice_tax_rate": juice_tax_rate = class_stats[stat_key]
			"max_esp_level": max_esp_level = class_stats[stat_key]
			"global_juice_cost_multiplier": global_juice_cost_multiplier = class_stats[stat_key]
			"speed_multiplier": speed_multiplier_class_mod = class_stats[stat_key]
			"obstacle_modifier": obstacle_modifier = class_stats[stat_key]
			"disabled_paths": disabled_paths = class_stats[stat_key]
			# --- Boolean Flags ---
			"juice_on_level_up_disabled": juice_on_level_up_disabled = true
			"juice_chance_on_eat": juice_chance_on_eat = class_stats[stat_key]
			"geological_survey_multiplies": geological_survey_multiplies = true
			"all_fruits_special": all_fruits_special = true
			"speed_on_loss": speed_on_loss = true
			"speed_increase_on_eat": speed_increase_on_eat = true
			"dynamic_max_fruits": dynamic_max_fruits = true
			"dynamic_fruit_reward": dynamic_fruit_reward = true
			"gambling_disabled": gambling_disabled = true
			"juice_menu_disabled": juice_menu_disabled = true
			"pulp_gain_disabled": pulp_gain_disabled = true
	
	#-------------finally------------
	reset_for_new_garden()
	SceneTransition.transition_to("res://Scenes/main.tscn", "spiral")
	get_tree().paused = false



func _apply_starting_upgrade(upgrade_key: String, levels_to_add: int):
	print("Applying starting upgrade: %s, Level: %s" % [upgrade_key, levels_to_add])
	
	# Define a list of all possible active abilities.
	var active_abilities = [
		"Burrow", "Phase Shift", "Blink", "Pocket Garden", "Banana Bounty", 
		"Sacrificial Molt", "Meditate", "Mise en Place", "Zenith", "Autotomy", 
		"Tenderizer", "Juice Press"
	]

	for i in range(levels_to_add):
		# Check if the upgrade is an active ability.
		if upgrade_key in active_abilities:
			# If yes, we use our new, powerful helper function.
			purchase_or_upgrade_ability(upgrade_key)
		elif upgrade_key == "Elephant Sized Portions": apply_esp_level_up()
		elif upgrade_key == "Juke N Jive": juke_and_jive_unlocked = true
		elif upgrade_key == "Mulligan Munchie": extra_lives += 1
		else:
			# If it's a passive upgrade, we handle it directly.
			var var_name_level = upgrade_key.to_snake_case().replace("'", "").replace("-", "_") + "_level"
			var var_name_unlocked = upgrade_key.to_snake_case().replace("'", "").replace("-", "_") + "_unlocked"

			if var_name_level in self:
				set(var_name_level, get(var_name_level) + 1)
			elif var_name_unlocked in self:
				set(var_name_unlocked, true)
		
	
func purchase_or_upgrade_ability(ability_key: String):
	# Check if we already own this ability.
	if not ability_key in ability_charges:
		# If not, check if we have an empty slot.
		if equipped_abilities.size() < max_ability_slots:
			equipped_abilities.append(ability_key)
			# Create the new entry with 1 charge.
			ability_charges[ability_key] = {"current": 1, "total": 1}
	else:
		# If we already own it, just add to both current and total charges.
		ability_charges[ability_key].current += 1
		ability_charges[ability_key].total += 1
