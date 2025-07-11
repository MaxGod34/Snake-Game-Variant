extends Node

#------Session State---------#
var chosen_difficulty = "viper"
var chosen_class = "speedster"
var run_time: float = 0.0
# --- RUN-SPECIFIC TRACKING ---
var total_juice_earned_this_run: int = 0
var total_pulp_earned_this_run: int = 0
var rocks_destroyed_this_run: int = 0
var upgrades_purchased_this_run: int = 0
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


# --- EASTER EGG TRACKING (for the current run) ---
var ascension_steps_completed: Dictionary = {}
var paradox_engine_active: bool = false
var paradox_engine_is_upgraded: bool = false
var special_fruit_chance_doubled: bool = false
# --- OUROBOROS BOSS STATE ---
var is_ouroboros_fight_active: bool = false
var ouroboros_phase: int = 1 # Can be 1, 2, or 3
var current_trial_key: String = ""
var trial_failed: bool = false
# --- TRIAL-SPECIFIC TRACKERS ---
var trial_haste_fruits_eaten: int = 0
var trial_patience_fruits_eaten: int = 0
var trial_illusion_phases: int = 0
var trial_memory_sequence: Array = []
var trial_memory_progress: int = 0
# --- SUPER EE TRACKERS --- #
var super_egg_step_10_complete: bool = false
var super_egg_step_11_complete: bool = false
var garden_10_special_fruits_eaten: Array = []
var garden_11_juke_count: int = 0
var highest_combo_this_garden: int = 0
var should_spawn_corrupted_ouroboros: bool = false
#----------END GAME FLAGS--------#
var free_upgrades_unlocked: bool = false
var roll_credits_unlocked: bool = false
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
		"display_name": "Pact 1: Juice Box Hero",
		"description": "A gentle start. You begin with a massive head start in resources and power.",
		"juice_cost_modifier": -1, "speed_multiplier": 1.0, "start_slots": 10, "start_juice": 3200,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {
			"Elephant Sized Portions": 3, "More Mice": 2, "Snake Clicker": 3
		},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png",
	},
	"Pact 2": {
		"display_name": "Pact 2: Pulp Friction",
		"description": "The training wheels are off. You start with your power, but no extra Juice.",
		"juice_cost_modifier": 0, "speed_multiplier": 1.0, "start_slots": 7, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {
			"Elephant Sized Portions": 3, "More Mice": 2, "Snake Clicker": 3
		},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_2.png",
	},
	"Pact 3": {
		"display_name": "Pact 3: Sink or Slither",
		"description": "The pure experience. No starting bonuses. Good luck.",
		"juice_cost_modifier": 0, "speed_multiplier": 1.0, "start_slots": 5, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_3.png",
	},
	"Pact 4": {
		"display_name": "Pact 4: The Zoomies",
		"description": "The garden moves at a frantic pace, leaving little room for error.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_4.png",
	},
	"Pact 5": {
		"display_name": "Pact 5: The Blender",
		"description": "The garden is wild and untamed, choked with obstacles.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": [], "start_upgrades": {},
		"obstacle_modifier": 1.5,
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_5.png",
	},

	# --- TIER 2: The Three Trials ---
	"Trial of the Harvest": {
		"display_name": "Seal of the Harvest", "description": "Prove your mastery over consumption. Only The Harvest path is available.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["The Core", "The Redline", "The Ssscale"],
		"start_upgrades": {"Edge Lord": 7},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_6.png",
	},
	"Trial of the Core": {
		"display_name": "Seal of the Core", "description": "Back to square one. Only Core path available.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["The Harvest", "The Redline", "The Ssscale"],
		"start_upgrades": {"Edge Lord": 7},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_6.png",
	},
	"Trial of the Redline": {
		"display_name": "Seal of the Redline", "description": "Go fast for once! Redline path only.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 2, "start_juice": 0,
		"campaign_length": 9, "locked_paths": ["The Core", "The Harvest", "The Ssscale"],
		"start_upgrades": {"Edge Lord": 7},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_6.png",
	},

	# --- TIER 3: The Cursed Pacts ---
	"Cursed Pact 1": {
		"display_name": "Cursed Pact I: Empty-Handed", "description": "You must earn your power. You start with no ability slots.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 12, "locked_paths": [], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png",
	},
	"Cursed Pact 2": {
		"display_name": "Cursed Pact II: Forced Diet", "description": "The path of gluttony is closed to you.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 12, "locked_paths": ["Glutton"], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_2.png",
	},
	"Cursed Pact 3": {
		"display_name": "Cursed Pact III: Thin Margins", "description": "The path of ledger is closed to you.",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 12, "locked_paths": ["Glutton", "Ledger"], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_3.png",
	},
	"Cursed Pact 4": {
		"display_name": "Cursed Pact IV: Extension Granted", "description": "Win after Garden 12",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 12, "locked_paths": ["Glutton", "Ledger"], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_4.png",
	},

	"Cursed Pact 5": {	#FINAL
		"display_name": "Cursed Pact V: Black Mamba", "description": "This is it...this is what they asked for!",
		"juice_cost_modifier": 0, "speed_multiplier": 0.8, "start_slots": 0, "start_juice": 0,
		"campaign_length": 12, "locked_paths": ["Glutton", "Ledger"], "start_upgrades": {},
		"icon_path": "res://Assets/PNGs/ghost_pepper_icon.png",
	}
}
#---------CLASS PARAMETERS--------#
var class_data = {
	"Mulligan": {
		"display_name": "Mulligan",
		"description": "The balanced, default experience. Starts with an Extra Life and a solid foundation for any build.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_fruit_red.png",
		"fang_cost": 0,
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
		"display_name": "Purist",
		"description": "A master of the garden with a disdain for the stench of RNG",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_fruit_red.png",
		"fang_cost": 100,
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
		"display_name": "Larry",
		"description": "The ultimate roguelike challenge. You are at the mercy of fate.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_fruit_red.png",
		"fang_cost": 100,
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
		"display_name": "Phoenix Coil",
		"description": "An immortal being who has traded worldly wealth for eternal life.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_fruit_red.png",
		"fang_cost": 100,
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
		"display_name": "Tycoon",
		"description": "A master of passive income who must spend to succeed.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/golden_fruit_icon.png",
		"fang_cost": 0,
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
		"display_name": "Day Trader",
		"description": "A fast-start economist who sacrifices raw power for economic velocity.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/golden_fruit_icon.png",
		"fang_cost": 100,
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
		"display_name": "Manager",
		"description": "A patient investor who leverages Pulp for massive late-game power.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/golden_fruit_icon.png",
		"fang_cost": 100,
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
		"display_name": "Calculator",
		"description": "A strange being whose power is a reflection of its own state.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/golden_fruit_icon.png",
		"fang_cost": 100,
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
		"display_name": "Ghost",
		"description": "An ethereal being who channels their magical nature into raw power.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/ghost_pepper_icon.png",
		"fang_cost": 0,
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
		"display_name": "Space",
		"description": "An absolute master of the garden's layout, with incredible speed to match.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/ghost_pepper_icon.png",
		"fang_cost": 100,
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
		"display_name": "Blinker",
		"description": "A high-skill class focused on a single, powerful reality-bending mechanic.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/ghost_pepper_icon.png",
		"fang_cost": 100,
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
		"display_name": "Psychic",
		"description": "A master of foresight whose power creates a dangerous feedback loop.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/ghost_pepper_icon.png",
		"fang_cost": 100,
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
		"display_name": "Doubles",
		"description": "A pure gambler who thrives on risk and gets faster with every failure.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_break.png",
		"fang_cost": 0,
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
		"display_name": "Comboisseur",
		"description": "The ultimate combo master, with a unique challenge and a massive payoff.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_break.png",
		"fang_cost": 100,
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
		"display_name": "Sniper",
		"description": "A focused predator who lives for the thrill of the hunt.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_break.png",
		"fang_cost": 100,
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
		"display_name": "Mineral",
		"description": "A true master of the earth who sees rocks not as obstacles, but as investments.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/snake_break.png",
		"fang_cost": 100,
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
		"display_name": "Gobble",
		"description": "A master of ingredients who has learned to harness their very essence.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/dragon_fruit_icon.png",
		"fang_cost": 0,
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
		"display_name": "Gluts",
		"description": "All-in on growth, but with a major logistical challenge.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/dragon_fruit_icon.png",
		"fang_cost": 100,
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
		"display_name": "Groove",
		"description": "A jack-of-all-trades who combines speed and passive income.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/dragon_fruit_icon.png",
		"fang_cost": 100,
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
		"display_name": "Alchemist",
		"description": "Does not gain Juice from leveling up. Every fruit has a 10% chance to grant 1 Juice instead.",
		"artwork_path": "res://Assets/PNGs/RotatingItemIcons/handicap_icon.png", #Fix icon path
		"icon_path": "res://Assets/PNGs/dragon_fruit_icon.png",
		"fang_cost": 100,
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
				"max_level": 30,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/SnakeClickerIcon.png",
				"type": "Passive"
			},
			"Get Rich Quick": {
				"display_name": "Get Rich Quick",
				"description": "Your Speed Hero!\nGain +0.1 GPS for every mL spent in the Acrobat tree.",
				"costs": [24], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/get_rich_quick_icon.png",
				"type": "Passive"
			},
			"Custom Aftertaste": {
				"display_name": "Custom Aftertaste",
				"description": "Your Cooking Hero!\nGain +0.1 GPS for every mL spent in the Chef tree.",
				"costs": [24], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/CustomAfterTasteIcon.png",
				"type": "Passive"
			},
			"Arcane Flow": {
				"display_name": "Arcane Flow",
				"description": "Your white mage! Just kidding\nYour Wizard Hero!\nGain +0.1 GPS for every mL spent in the Illusionist tree.",
				"costs": [24], "max_level": 1, "prerequisite": {"upgrade": "Snake Clicker", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ArcaneFlowIcon.png",
				"type": "Passive"
			},
			"Pulp Reactor": {
				"display_name": "Pulp Reactor",
				"description": "GPS is permanently increased by +1\nfor every 100 Pulp you are currently holding.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Snake Clicker", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PulpReactorIcon.png",
				"type": "Keystone"
			},
			"Unstable Metabolism": {
				"display_name": "Unstable Metabolism",
				"description": "Permanently doubles your total GPS\nThat's it, fetch!",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Snake Clicker", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/UnstableMetabolismIcon.png",
				"type": "Keystone"
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
				"max_level": 15,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/DietSlithIcon.png",
				"type": "Passive"
			},
			"Fruit Foresight": {
				"display_name": "Fruit Foresight",
				"description": "See the next fruit!\nUse responsibly",
				"costs": [12], # One-time purchase
				"max_level": 1,
				"prerequisite": {"upgrade": "Diet Slith", "level": 5}, # Requires Diet Slith Lvl 2
				"icon_path": "res://Assets/PNGs/UpgradeIcons/FruitForesightIcon.png",
				"type": "Passive"
			},
			#New geological survey... ooo lala
			"Geological Survey": {
				"display_name": "Geological Survey", "max_level": 1, "costs": [16],
				"description": "Gain bonus Juice at end of Garden\nMore rocks = More Juice",
				"prerequisite": {"upgrade": "Diet Slith", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GeologicalSurveyIcon.png",
				"type": "Passive"
			},
			"Sovereign Trail": { #72 total
				"display_name": "Sovereign Trail",
				"description": "Leave your mark. Your trail affects where new fruits can spawn.",
				"costs": [8, 64], # Lvl 1: Repel, Lvl 2: Attract
				"max_level": 2,
				"prerequisite": {"upgrade": "Diet Slith", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/SovereignTrailIcon.png",
				"type": "Passive"
			},
			"Meditate": { #Levels 1-4 195
				"display_name": "Meditate",
				"costs": [15, 30, 60, 100, 200, 500, 1000, 2500, 5000],
				"description": "Pause! Need I say more?\nRequires Diet Slith lvl 7",
				"max_level": 9,
				"prerequisite": {"upgrade": "Diet Slith", "level": 7},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MeditateIcon.png",
				"type": "Active Ability"
			},
			"Garden Weaver": {
				"display_name": "Garden Weaver",
				"description": "Reroll all the fruits MUCH closer!\nRequires Diet Slith Lvl 7",
				"costs": [50],
				"max_level": 1,
				"prerequisite": {"upgrade": "Diet Slith", "level": 7},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GardenWeaverIcon.png",
				"type": "Keystone"
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
				"exclusive_with": "Principal Pulp", # This new key locks the other option
				"icon_path": "res://Assets/PNGs/UpgradeIcons/LiquidAssetsIcon.png",
				"type": "Passive"
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
				"exclusive_with": "Liquid Assets",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PrincipalPulpIcon.png",
				"type": "Passive"
			},

			# --- Path A (Juice Focus) Upgrades ---
			"Fast Track": {
				"display_name": "Fast-Track", "max_level": 1, "costs": [1],
				"description": "Unlocks the 'Skip Garden' button in the Pulp Stand,\nOn skip, +5mL Juice.",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/WormholeIcon.png",
				"type": "In-Active Ability"
			},
			"Gluttons Greed": {
				"display_name": "Glutton's Greed", "max_level": 1, "costs": [16],
				"description": "Quantity or Quality, or...\nIncrease fruit reward by max fruits",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 2},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GluttonsGreedIcon.png",
				"type": "Boost"
			},
			"Market Crash": { #1129
				"display_name": "Market Crash", "max_level": 10, "costs": [1, 8, 15, 30, 50, 75, 100, 150, 200, 500],
				"description": "Permanently reduce the Juice cost of all upgrades.\nLvl 1: -1mL\nLvl 2: -2mL",
				"prerequisite": {"upgrade": "Liquid Assets", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MarketCrashIcon.png",
				"type": "Keystone"
			},

			# --- Path B (Pulp Focus) Upgrades ---
			"Golden Handshake": { #567
				"display_name": "Golden Handshake", "max_level": 10, "costs": [3, 4, 5, 15, 25, 40, 65, 90, 120, 200],
				"description": "Multiplies all BONUS Pulp rewards\n(Flawless, Par Time, etc.) at the end of each Garden.",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenHandshakeIcon.png",
				"type": "Passive"
			},
			"Juice Press": {
				"display_name": "Juice Press", "max_level": 1, "costs": [64],
				"description": "Active Ability (Once per Garden):\nConvert all your current Pulp into Juice\nat a 5mg:1mL ratio.",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/JuicePressIcon.png",
				"type": "Active Ability"
			},
			"Liquidation": {
				"display_name": "Liquidation", "max_level": 1, "costs": [1],
				"description": "Instantly double your current Juice\nNo strings attached",
				"prerequisite": {"upgrade": "Principal Pulp", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/LiquidationIcon.png",
				"type": "Keystone"
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
				"max_level": 20,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ESPortionsIcon.png",
				"type": "Passive"
			},
			"More Mice": { #1188
				"display_name": "More Mice!",
				"description": "Increases maximum number of fruits\n+1 per level",
				"costs": [
					5,10,18,30,50,
					75,100,150,250,500
					],
				"max_level": 10,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MoreMiceIcon.png",
				"type": "Passive"
			},
			"Golden Seeds": { #267
				"display_name": "Golden Seeds",
				"description": "Unlocks Golden Apples, which grant Juice.\nEach level increases their spawn chance and reward.",
				"costs": [7, 35, 75, 150],
				"max_level": 4,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenSeedsIcon.png",
				"type": "Passive"
			},
			"Patient Gardener": { #200
				"display_name": "Patient Gardener",
				"description": "Fruits will ripen over time,\ngranting bonus growth\nLvl 3 = X3 bonuse",
				"costs": [16, 64, 128],
				"max_level": 3,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PatientGardenerIcon.png",
				"type": "Passive"
			},
			"Banana Bounty": { #First 5: 260
				"display_name": "Banana Bounty",
				"description":  "Active Ability: Marks a fruit as a\nhigh-value bounty for massive growth.",
				"costs": [16, 32, 48, 64, 100, 250, 500, 1000, 2500],
				"max_level": 9,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/BananaBountyIcon.png",
				"type": "Active Ability"
			},
			"The Satchel": { #64
				"display_name": "The Satchel",
				"description": "Permanently unlocks another active ability slot.",
				"costs": [64],
				"max_level": 1,
				"prerequisite": {"upgrade": "Elephant Sized Portions", "level": 10, "and": "Golden Seeds", "and_level": 4},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/TheSatchelIcon.png",
				"type": "Passive"
			}
		},
		
		"Chef": {
			"Golden Seed Extract": { # 79
				"display_name": "Golden Seed Extract",
				"description": "A potent concoction. Increases the spawn chance of valuable Golden Apples.",
				"costs": [3, 12, 64], # Example costs for 3 levels
				"max_level": 3,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenSeedExtractIcon.png",
				"type": "Passive"
			},
			"Exotic Seeds": {
				"display_name": "Exotic Seeds",
				"description": "A taste for the strange.\nAdds new, rare fruits to the spawn pool.",
				"costs": [4, 12, 24, 36, 81], # 5 levels
				"max_level": 5,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ExoticSeedsIcon.png",
				"type": "Passive"
			},
			"The Cookbook": {
				"display_name": "The Cookbook",
				"description": "Unlocks the Recipe system,\ngranting temporary buffs for eating fruit in a specific sequence.",
				"costs": [1],
				"max_level": 1,
				"prerequisite": {"upgrade": "Golden Seed Extract", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/TheCookbookIcon.png",
				"type": "Passive"
			},
			"Expanded Palate": {
				"display_name": "Expanded Palate",
				"description": "Adds new, more complex and powerful recipes to your Cookbook.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ExpandedPalateIcon.png",
				"type": "Passive"
			},
			"Golden Glaze": {
				"display_name": "Golden Glaze",
				"description": "Golden Apples now act as a 'wild card' ingredient\nfor any step in your current recipe.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenGlazeIcon.png",
				"type": "Passive"
			},
			"Custom Cuisine": {
				"display_name": "Custom Cuisine",
				"description": "Permanently enhances all special fruits with powerful secondary effects!",
				"costs": [50],
				"max_level": 1,
				"prerequisite": {"upgrade": "The Cookbook", "level": 1, "and": "Exotic Seeds", "and_level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/CustomCuisineIcon.png",
				"type": "Keystone"
			},
			"Mise en Place": {
				"display_name": "Mise en Place",
				"description": "Active Ability (Once per RUN):\nInstantly transforms all normal fruits on screen into random special fruits.",
				"costs": [96],
				"max_level": 1,
				"prerequisite": {"upgrade": "Exotic Seeds", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MiseenPlaceIcon.png",
				"type": "Keystone"
			}
		},
		
		"Geode": {
			"Fertile Ground": {
				"display_name": "Fertile Ground", "max_level": 3, "costs": [4, 16, 64],
				"description": "Each level grants +1 to Max Fruits\nbut adds +5 rocks to every garden.",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/FertileGroundIcon.png",
				"type": "Passive"
			},
			"Mineral Rich Soil": {
				"display_name": "Mineral-Rich Soil", "max_level": 3, "costs": [4, 8, 16],
				"description": "Each level grants +1 to Fruit Reward\nbut adds +5 rocks to every garden.",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MineralRichSoilIcon.png",
				"type": "Passive"
			},
			"Tectonic Shift": {
				"display_name": "Tectonic Shift", "max_level": 3, "costs": [2, 4, 8],
				"description": "Each level grants a speed boost\nbut adds +5 rocks to every garden.",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/TectonicShiftIcon.png",
				"type": "Passive"
			},
			"Heavy Foundation": {
				"display_name": "Heavy Foundation", "max_level": 3, "costs": [4, 8, 16],
				"description": "Each level grants a speed decrease\nbut adds +5 rocks to every garden.",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/HeavyFoundationIcon.png",
				"type": "Passive"
			},

			# --- GEOMANCER TIER 2 (ROCKEATERS) ---
			"Rockmuncher": {
				"display_name": "Rockmuncher", "max_level": 1, "costs": [32],
				"description": "You can now eat rocks,\nwhich grant +2 growth.",
				"prerequisite": {"upgrade": "Fertile Ground", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/RockmuncherIcon.png",
				"type": "Passive"
			},
			"Geode Cracker": {
				"display_name": "Geode Cracker", "max_level": 1, "costs": [32],
				"description": "You can now eat rocks,\nwhich have a chance to grant +1 Juice.",
				"prerequisite": {"upgrade": "Mineral Rich Soil", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GeodeCrackerIcon.png",
				"type": "Passive"
			},
			"Kinetic Feast": {
				"display_name": "Kinetic Feast", "max_level": 1, "costs": [32],
				"description": "You can eat rocks and\nyou get a speed boost after eating the rock",
				"prerequisite": {"upgrade": "Tectonic Shift", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/KineticFeastIcon.png",
				"type": "Passive"
			},
			"Stones Burden": {
				"display_name": "Stone's Burden", "max_level": 1, "costs": [32],
				"description": "Eating a rock slows you but grants temporary invulnerability.",
				"prerequisite": {"upgrade": "Heavy Foundation", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/StonesBurdenIcon.png",
				"type": "Passive"
			},

			# --- GEOMANCER KEYSTONE ---
			"Calculated Risk": {
				"display_name": "Calculated Risk", "max_level": 1, "costs": [64],
				"description": "Doubles the Juice bonus from Geological Survey.",
				"prerequisite": {"upgrade": "Geological Survey", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/CalculatedRiskIcon.png",
				"type": "Keystone"
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
				"max_level": 10,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/SlitherSauceIcon.png",
				"type": "Passive"
			},
			"Tenderizer": {
				"display_name": "Tenderizer",
				"description": "Destroy a rock on impact.\nHas limited charges, which refresh on level up.\nEach level grants another charge.",
				"costs": [8, 12, 16, 32, 64, 128, 256, 512, 999],
				"max_level": 9,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/TenderizerIcon.png",
				"type": "Active Ability"
			},
			"Juke N Jive": {
				"display_name": "Juke 'N Jive",
				"description": "Changing direction 4 times in 1 second\nlets you phase through a body segment\nGet groovin'",
				"costs": [12],
				"max_level": 1,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/JukeNJiveIcon.png",
				"type": "Passive/Ability"
			},
			"Afterburner": {
				"display_name": "Afterburner",
				"description": "Speed boost after eating a fruit?",
				"costs": [6, 12, 48],
				"max_level": 3,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/AfterburnerIcon.png",
				"type": "Passive"
			},
			"Pop Rocks": {
				"display_name": "Pop Rocks",
				"description": "When you destroy a rock with Tenderizer,\nit creates a shockwave that destroys adjacent rocks.",
				"costs": [16],
				"max_level": 1,
				"prerequisite": {"upgrade": "Tenderizer", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PopRocksIcon.png",
				"type": "Passive"
			},
			"Autotomy": {
				"display_name": "Autotomy",
				"description": " Active Ability: Sever your own tail on impact\nto survive a fatal crash.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Slither Sauce", "level": 6},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/AutotomyIcon.png",
				"type": "Keystone Ability"
			}
		},
		"Frenzy": {
			"Sugar Rush": {
				"display_name": "Sugar Rush",
				"description": "Unlocks the Combo Meter,\nwhich tracks fruits eaten in quick succession.",
				"costs": [3],
				"max_level": 1,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/SugarRushIcon.png",
				"type": "Passive"
			},
			"Chain Reaction": {
				"display_name": "Chain Reaction",
				"description": "Make the combo meter do something!\nEach level increases the max combo by 5\nLvl 5: no unlimited combo",
				"costs": [5, 10, 15, 20, 32],
				"max_level": 5,
				"prerequisite": {"upgrade": "Sugar Rush", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ChainReactionIcon.png",
				"type": "Passive"
			},
			"Overdrive": {
				"display_name": "Overdrive",
				"description": "While combo is active,\nhold your current direction key for a speed boost.",
				"costs": [16, 1], # Lvl 2 is cheap for the cosmetic!
				"max_level": 2,
				"prerequisite": {"upgrade": "Sugar Rush", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/OverdriveIcon.png",
				"type": "Passive"
			},
			"Lingering Rush": {
				"display_name": "Lingering Rush",
				"description": "Increases the duration of the combo timer,\nmaking it easier to chain fruits.",
				"costs": [6, 12, 18, 24, 64],
				"max_level": 5,
				"prerequisite": {"upgrade": "Sugar Rush", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/LingeringRushIcon.png",
				"type": "Passive"
			},
			"Juggernaut": {
				"display_name": "Juggernaut",
				"description": "While your combo is pure\n(you haven't opened the upgrade menu),\nthe combo timer is paused.",
				"costs": [25],
				"max_level": 1,
				"prerequisite": {"upgrade": "Lingering Rush", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/JuggernautIcon.png",
				"type": "Keystone"
			},
			"Zenith": {
				"display_name": "Zenith",
				"description": "Active Ability: Instantly set your combo to 10 and freeze the timer.",
				"costs": [32],
				"max_level": 1,
				"prerequisite": {"upgrade": "Lingering Rush", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ZenithIcon.png",
				"type": "Keystone Ability"
				}
			},
		"Survivor": {
			"Mulligan Munchie": {
				"display_name": "Mulligan Munchie",
				"description": "Grants one Extra Life.\nYou got it for sure...",
				"costs": [5, 20, 50, 100, 200, 300, 400, 500, 750, 999], # Example scaling costs
				"max_level": 10,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MulliganMunchieIcon.png",
				"type": "Passive"
			},
			"Phoenix Dawn": {
				"display_name": "Phoenix Dawn",
				"description": "After using an Extra Life,\nthe next fruit you eat restores 25% of your lost length.",
				"costs": [7], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PhoenixDawnIcon.png",
				"type": "Passive"
			},
			"Last Stand": {
				"display_name": "Last Stand",
				"description": "While on your final life,\nthe chance for Golden Apples to spawn is significantly increased.",
				"costs": [32], "max_level": 1,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/LastStandIcon.png",
				"type": "Passive"
			},
			"Sacrificial Molt": {
				"display_name": "Sacrificial Molt",
				"description": "Active Ability (Once per RUN):\nHalve your current length to instantly gain one Extra Life charge.",
				"costs": [16], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/SacrificialMoltIcon.png",
				"type": "Active Ability"
			},
			"Death Defied": {
				"display_name": "Death Defied",
				"description": "Every time you use an Extra Life, permanently gain +1 to your Fruit Reward and Max Fruits on Screen for this run.",
				"costs": [20], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 2},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/DeathDefiedIcon.png",
				"type": "Passive"
			},
			"Martyrdom": {
				"display_name": "Martyrdom",
				"description": "Upon your final death, your snake explodes,\nharvesting all fruit on screen\nfor a final score boost.",
				"costs": [13], "max_level": 1,
				"prerequisite": {"upgrade": "Mulligan Munchie", "level": 2},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MartyrdomIcon.png",
				"type": "On-Death Ability"
			},
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
				"max_level": 10,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/GhostTailIcon.png",
				"type": "Passive"
			},
			"Phase Shift": {
				"display_name": "Phase Shift",
				"description": "Active Ability: Become intangible to your own body for a short time.\nEach level grants another charge.",
				"costs": [4, 8, 12, 16, 20, 64, 128, 256, 512, 999],
				"max_level": 10,
				"exclusive_with": "Blink", # Can't have both
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PhaseShiftIcon.png",
				"type": "Active Ability"
			},
			"Blink": {
				"display_name": "Blink",
				"description": "Active Ability: Instantly teleport forward 3 tiles.\nPass through your old hole!",
				"costs": [2, 4, 6, 20, 32, 64, 128, 256, 512, 999],
				"max_level": 10,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 2},
				"exclusive_with": "Phase Shift",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/BlinkIcon.png",
				"type": "Active Ability"
			},
			"3 Card Monty": {
				"display_name": "3-Card Monty",
				"description": "Permanently reduces the Juice cost of\nall other upgrades by 1 (to a minimum of 1).",
				"costs": [3],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/3CardMontyIcon.png",
				"type": "Passive"
			},
			"Fractured Self": {
				"display_name": "Fractured Self",
				"description": "Your body is now rendered in 3-segment chunks",
				"costs": [64],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 5},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/FracturedSelfIcon.png",
				"type": "Keystone"
			},
			"Dazzle Pie": {
				"display_name": "Dazzle Pie",
				"description": "A permanent, purely aesthetic transformation that adds\na chromatic aberration effect to the game.",
				"costs": [1],
				"max_level": 1,
				"prerequisite": {"upgrade": "Ghost Tail", "level": 7},
				"exclusive_with": "Masters Blueprint",
				"icon_path": "res://Assets/PNGs/UpgradeIcons/DazzlePieIcon.png",
				"type": "Keystone"
		}
	},	
			
		"Architect": {
			"Edge Lord": {
				"display_name": "Edge Lord",
				"description": "Increases the size of the play area.",
				"costs": [2, 4, 8, 16, 32, 64, 128],
				"max_level": 7,
				"icon_path": "res://Assets/PNGs/UpgradeIcons/EdgeLordIcon.png",
				"type": "Passive"
			},
			"Zoning Ordinance": {
				"display_name": "Zoning Ordinance",
				"description": "Designate a quadrant as a 'safe zone' with fewer obstacles\nLvl 1: Top Left\nLvl 2: Top Half\nLvl 3: 1 quadrant not safe\nLvl 4: Complete control",
				"costs": [6, 18, 32, 128],
				"max_level": 4,
				"prerequisite": {"upgrade": "Edge Lord", "level": 2},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ZoningOrdinanceIcon.png",
				"type": "Passive"
			},
			"Border Czar": {
				"display_name": "Border Czar",
				"description": "Control the borders, control the world.\nFruit on the edge is more likely to be special.",
				"costs": [16],
				"max_level": 1,
				"prerequisite": {"upgrade": "Edge Lord", "level": 3},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/BorderCzarIcon.png",
				"type": "Passive"
			},
			"Surveyed Land": {
				"display_name": "Surveyed Land",
				"description": "A double-edged sword.\nCreate a \"wilderness\" with better fruit but more rocks.",
				"costs": [8],
				"max_level": 1,
				"prerequisite": {"upgrade": "Zoning Ordinance", "level": 1},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/SurveyedLandIcon.png",
				"type": "Passive"
			},
			"Burrow": {
				"display_name": "Burrow",
				"description": "Active Ability: Pass through one wall\nand emerge on the opposite side.\nAbility lasts until next wall hit!",
				"costs": [7, 12, 20, 34, 64, 128, 256, 512, 999],
				"max_level": 9,
				"prerequisite": {"upgrade": "Edge Lord", "level": 4}, # This should be 4 to match max_level
				"icon_path": "res://Assets/PNGs/UpgradeIcons/BurrowIcon.png",
				"type": "Active Ability"
			},
			"Pocket Garden": {
				"display_name": "Pocket Garden",
				"description": "Active Ability: Sacrifice tail segments to\ncreate a temporary 5x5 safe zone that spawns fruit.\nLvl increases duration and segment cost",
				"costs": [16, 32, 128],
				"max_level": 3,
				"prerequisite": {"upgrade": "Edge Lord", "level": 4}, # This should be 4
				"icon_path": "res://Assets/PNGs/UpgradeIcons/PocketGardenIcon.png",
				"type": "Active Ability"
			},
			"Fold Space": {
				"display_name": "Fold Space", 
				"description": "Removes all walls,\nmaking the garden wrap around on itself.",
				"costs": [128], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 7, "and": "Burrow", "and_level": 3},
				"exclusive_with": "Shatter Reality", # <-- makes it mutually exclusive
				"icon_path": "res://Assets/PNGs/UpgradeIcons/FoldSpaceIcon.png",
				"type": "Keystone"
			},
			"Shatter Reality": {
				"display_name": "Shatter Reality", 
				"description": "Splits the garden into\nfour quadrants with connecting portals.",
				"costs": [128], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 7},
				"exclusive_with": "Fold Space", # <-- makes it mutually exclusive
				"icon_path": "res://Assets/PNGs/UpgradeIcons/ShatterRealityIcon.png",
				"type": "Keystone"
			},
			"Masters Blueprint": {
				"display_name": "Masters Blueprint", 
				"description": "Transforms the game's visuals into a clean, glowing blueprint grid.",
				"costs": [13], 
				"max_level": 1, 
				"prerequisite": {"upgrade": "Edge Lord", "level": 7},
				"icon_path": "res://Assets/PNGs/UpgradeIcons/MastersBlueprintIcon.png",
				"type": "Keystone"
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
			"max_level": 1,
			"icon_path": "res://Assets/PNGs/UpgradeIcons/CoinFlipCuriousIcon.png",
			"type": "Passive"
		},
		"Passive Income": {
			"display_name": "Passive Income",
			"description": "Every bet won results in a +1 to your fruit reward\nYou heard me...get on with it!",
			"costs": [13],
			"max_level": 1,
			"icon_path": "res://Assets/PNGs/UpgradeIcons/PassiveIncomeIcon.png",
			"type": "Passive"
		}
	}
	}

}


var meta_upgrade_data = {
	"Synapse Slot": {
		"description": "Unlocks one additional active ability slot.\nA crucial investment for any build.",
		"costs": [200, 250, 500, 750, 1000, 1500, 2000, 3000, 4000, 9999], # Costs for slots 1 through 10
		"max_level": 10,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/SynapseSlotIcon.png",
		"type": "Slot"
	},
	"Serpents Coffer": {
		"description": "Gain 'interest' on your unspent\nPulp at the end of each Garden.",
		"costs": [50, 200, 500, 1000],
		"max_level": 4,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/SerpentsCofferIcon.png",
		"type": "Passive"
	},
	"Geode Compass": {
		"description": "Permanently removes a percentage of\nobstacles from all subsequent gardens.",
		"costs": [75, 200, 600, 1250],
		"max_level": 4,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/GeodeCompassIcon.png",
		"type": "Passive"
		
	},
	"Four Leaf Clover": {
		"description": "Permanently increases your 'luck,'\nboosting the chance of all random events.",
		"costs": [42, 69, 340, 1000],
		"max_level": 4,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/FourLeafCloverIcon.png",
		"type": "Passive"
	},
	"Chroma Scales": {
		"description": "Activate the cosmetic options\nyou've permanently unlocked in the Fang Fund.",
		"costs": [1, 1, 1, 1, 1, 1],
		"max_level": 6,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/ChromaScalesIcon.png",
		"type": "Aesthetic"
	},
	"Lasso Larry": {
		"display_name": "Lasso Larry",
		"description": "Active Ability: Randomly rerolls a fruit!\nLvl 1: Pulls 1 fruit.\nLvl 2: Pulls 2 fruits.\nLvl 3: Pulls 3 fruits.",
		"costs": [125, 500, 1000],
		"max_level": 3,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/LassoLarryIcon.png",
		"type": "Active Ability"
	},
	"Harvest Forecast": {
		"display_name": "Harvest Forecast",
		"description": "Adds a UI element showing the next\nspecial fruits in the spawn queue.\nLvl 1-3: Shows 1-3 special fruit.\nLvl 4: Shows the next 5 fruits",
		"costs": [100, 200, 300, 1000],
		"max_level": 4,
		"icon_path": "res://Assets/PNGs/UpgradeIcons/HarvestForecastIcon.png",
		"type": "QoL"
	}
}

var cosmetic_data = {
	"Colors": {
		"Default Lime": {"name": "Default Lime", "fang_cost": 0, "hex_code": "#00ff00", "description": "Default Lime"},
		"Default Purple": {"name": "Default Purple", "fang_cost": 0, "hex_code": "#27002d", "description": "Default Purple"},
		"Default White": {"name": "Default White", "fang_cost": 0, "hex_code": "#ffffff", "description": "Default White"},
		"Default Gray": {"name": "Default Gray", "fang_cost": 0, "hex_code": "#444444", "description": "Default Gray"},
		"Ectoplasm Green": {"name": "Ectoplasm Green", "fang_cost": 50, "hex_code": "#7ED321", "description": "Add a little color to your game!"},
		"Molten Gold": {"name": "Molten Gold", "fang_cost": 50, "hex_code": "#F5A623", "description": "Add a little color to your game!"},
		"Void Purple": {"name": "Void Purple", "fang_cost": 50, "hex_code": "#BD10E2", "description": "Add a little color to your game!"},
		"Electric Lime": {"name": "Electric Lime", "fang_cost": 50, "hex_code": "#AFFF00", "description": "Add a little color to your game!"},
		"Venom Pink": {"name": "Venom Pink", "fang_cost": 50, "hex_code": "#FF5CA3", "description": "Add a little color to your game!"},
		"Plasma Teal": {"name": "Plasma Teal", "fang_cost": 50, "hex_code": "#00FFD5", "description": "Add a little color to your game!"},
		"Infrared Orange": {"name": "Infrared Orange", "fang_cost": 50, "hex_code": "#FF6A00", "description": "Add a little color to your game!"},
		"Royal Slime": {"name": "Royal Slime", "fang_cost": 50, "hex_code": "#98DE00", "description": "Add a little color to your game!"},
		"Ultraviolet": {"name": "Ultraviolet", "fang_cost": 50, "hex_code": "#9D00FF", "description": "Add a little color to your game!"},
		"Radioactive Gold": {"name": "Radioactive Gold", "fang_cost": 50, "hex_code": "#FFD700", "description": "Add a little color to your game!"},
		"Cyber Blue": {"name": "Cyber Blue", "fang_cost": 50, "hex_code": "#00AFFF", "description": "Add a little color to your game!"},
		"Witch Green": {"name": "Witch Green", "fang_cost": 50, "hex_code": "#00FF7F", "description": "Add a little color to your game!"},
		"Crimson Curse": {"name": "Crimson Curse", "fang_cost": 50, "hex_code": "#D1003C", "description": "Add a little color to your game!"},
		"Ghost White": {"name": "Ghost White", "fang_cost": 50, "hex_code": "#F8F8FF", "description": "Add a little color to your game!"},
		"Vanta Violet": {"name": "Vanta Violet", "fang_cost": 50, "hex_code": "#7D00A3", "description": "Add a little color to your game!"},
		"Peach Fuzz": {"name": "Peach Fuzz", "fang_cost": 50, "hex_code": "#FFB07C", "description": "Add a little color to your game!"},
		"Steel Cyan": {"name": "Steel Cyan", "fang_cost": 50, "hex_code": "#38E5FF", "description": "Add a little color to your game!"},
		"Dream Tangerine": {"name": "Dream Tangerine", "fang_cost": 50, "hex_code": "#FF9472", "description": "Add a little color to your game!"},
	},
	"Patterns": {
		"Default": {
			"name": "Default Pattern", "fang_cost": 0, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png",
			"description": "Default Pattern", 
			"sequence": [0]
		},
		"Tiger Stripes": {
			"name": "Tiger Stripes Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/GambleSprites/PlusOne.png", 
			"description": "Add a nice pattern to your snake!",
			"sequence": [0,1]
		},
		"Dimer": {
			"name": "Dimer Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/GambleSprites/PlusOne.png", 
			"description": "Add a nice pattern to your snake!",
			"sequence": [0,0,0,0,0,0,0,0,0,0,
						1,1,1,1,1,1,1,1,1,1]
		},
		"Simple Spread": {
			"name": "Simple Spread Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "Add a nice pattern to your snake!",
			"sequence": [0,1,1,1,0]
		},
		"Slith Spread": {
			"name": "Slith Spread Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "Add a nice pattern to your snake!",
			"sequence": [0,1,2,3,2,1]
		},
		"MAX AURA": {
			"name": "MAX AURA Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "Add a nice pattern to your snake!",
			"sequence": [0,1,2,3,4]
		},
		"Fading Fast": {
			"name": "Fading Fast Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "Add a nice pattern to your snake!",
			"sequence": [4,4,4,4,4,3,2,1,0,1,2,3,]
		},
		
	},
	"Backgrounds": {
		"Default": {
			"name": "Default", "fang_cost": 0, "type": "solid_color", "color": "#222222", 
			"icon_path": "res://Assets/PNGs/GambleSprites/PlusOne.png", "description": "Default Background"
		},
		"The Void": {
			"name": "The Void", "fang_cost": 200, "type": "particles", "effect_name": "Void",
			"icon_path": "res://Assets/PNGs/dragon_fruit_icon.png", "description": "The Void..."
		},
		"The Undergrowth": {
			"name": "The Undergrowth", "fang_cost": 200, "type": "particles", "effect_name": "Undergrowth",
			"icon_path": "res://Assets/PNGs/golden_fruit_icon.png", "description": "Get Growin'"
		},
		"The Digital Stream": {
			"name": "The Digital Stream", "fang_cost": 250, "type": "shader", "shader_name": "DigitalStream",
			"icon_path": "res://Assets/PNGs/iron_cherry_icon.png", "description": "Let's Get Digital, Digital"
		},
		"The Blueprint": {
			"name": "The Blueprint", "fang_cost": 150, "type": "shader", "shader_name": "Blueprint",
			"icon_path": "res://Assets/PNGs/UpgradeIcons/MastersBlueprintIcon.png", "description": "Who moved my T-square?!"
		},
		"The Cove": {
			"name": "The Cove", "fang_cost": 200, "type": "particles", "effect_name": "Cove", 
			"icon_path": "res://Assets/PNGs/UpgradeIcons/GeologicalSurveyIcon.png", "description": "Dark Stormy Night"
		},

	},
	"Avatars": {
		"Default": {"name": "Snake break", "fang_cost": 0, "icon_path": "res://Assets/PNGs/snake_break.png", "description": "Default Avatar"},
		#Class Icons/Avatars
		"Mulligan Icon": {"name": "Mulligan Icon", "fang_cost": 50, "icon_path": "", "descripton": "unlock the mulligan class icon as a pfp!"},
		#Upgrade Icons/Avatars
		"3 Card Monty Icon": {"name": "3-Card Monty Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/3CardMontyIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Afterburner Icon": {"name": "Afterburner Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/AfterburnerIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Arcane Flow Icon": {"name": "Arcane Flow", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ArcaneFlowIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Autotomy Icon": {"name": "Autotomy Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/AutotomyIcon.png", "description": "Get this exclusive upgrade icon as a pfp!" },
		"Banana Bounty Icon": {"name": "Banana Bounty Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/BananaBountyIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Blink Icon": {"name": "Blink Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/BlinkIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Border Czar Icon": {"name": "Border Czar Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/BorderCzarIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Burrow Icon": {"name": "Burrow Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/BurrowIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Calculated Risk Icon": {"name": "Calculated Risk Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CalculatedRiskIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Chain Reaction Icon": {"name": "Chain Reaction Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ChainReactionIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Chorma Scaled Icon": {"name": "Chroma Scales Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ChromaScalesIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Coin Flip Curious Icon": {"name": "Coin Flip Curious Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CoinFlipCuriousIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Custom Aftertaste Icon": {"name": "Custom Aftertaste Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CustomAfterTasteIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Custom Cuisine Icon": {"name": "Custom Cuisine Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CustomCuisineIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Dazzle Pie Icon": {"name": "Dazzle Pie Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/DazzlePieIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Death Defied Icon": {"name": "Death Defied Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/DeathDefiedIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Diet Slith Icon": {"name": "Diet Slith Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/DietSlithIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Edge Lord Icon": {"name": "Edge Lord Icon", "fang_cost": 50, " icon_path": "res://Assets/PNGs/UpgradeIcons/EdgeLordIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Elephant Sized Portions Icon": {"name": "Elephant Sized Portions Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ESPortionsIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Exotic Seeds Icon": {"name": "Exotic Seeds Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ExoticSeedsIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Expanded Palate Icon": {"name": "Expanded Palate Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ExpandedPalateIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fertile Ground Icon": {"name": "Fertile Ground Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FertileGroundIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fold Space Icon": {"name": "Fold Space Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FoldSpaceIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Four Leaf Clover Icon": {"name": "Four Leaf Clover Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FourLeafCloverIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fractured Self Icon": {"name": "Four Leaf Clover Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FracturedSelfIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fruit Foresight Icon": {"name": "Fruit Foresight Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FruitForesightIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Garden Weaver Icon": {"name": "Garden Weaver Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GardenWeaverIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Geode Compass Icon": {"name": "Geode Compass Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GeodeCompassIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Geode Cracker Icon": {"name": "Geode Cracker Icon", "fang_cost": 50, "icon_path":"res://Assets/PNGs/UpgradeIcons/GeodeCrackerIcon.png", "description": "Get this exclusive upgrade icon as a pfp!" },
		"Geological Survey Icon": {"name": "Geological Survey Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GeologicalSurveyIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Get Rich Quick Icon": {"name": "Get Rich Quick Icon", "fang_cost": 50, "icon_path":"res://Assets/PNGs/UpgradeIcons/get_rich_quick_icon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Ghost Tail Icon": {"name": "Ghost Tail Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GhostTailIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Gluttons Greed Icon": {"name": "Glutton's Greed Icon", "fang_cost": 50, "icon_path":"res://Assets/PNGs/UpgradeIcons/GluttonsGreedIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Golden Glaze Icon": {"name": "Golden Glaze Icon", "fang_cost": 50, "icon_path":"res://Assets/PNGs/UpgradeIcons/GoldenGlazeIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Golden Handshake Icon": {"name": "Golden Handshake Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenHandshakeIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Golden Seed Extract Icon": {"name": "Golden Seed Extract Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenSeedExtractIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Golden Seeds Icon": {"name": "Golden Seeds Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/GoldenSeedsIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Harvest Forecast Icon": {"name": "Harvest Forecast Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/HarvestForecastIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Heavy Foundation Icon": {"name": "Heavy Foundation Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/HeavyFoundationIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Juggernaut Icon": {"name": "Juggernaut Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/JuggernautIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Juice Press Icon": {"name": "Juice Press Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/JuicePressIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Juke N Jive Icon": {"name": "Juke 'N Jive Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/JukeNJiveIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Kinetic Feast Icon": {"name": "Kinetc Feast Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/KineticFeastIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Lasso Larry Icon": {"name": "Lasso Larry Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/LassoLarryIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Last Stand Icon": {"name": "Last Stand Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/LastStandIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Lingering Rush Icon": {"name": "Lingering Rush Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/LingeringRushIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Liquid Assets Icon": {"name": "Liquid Assets Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/LiquidAssetsIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Liquidation Icon": {"name": "Liquidation Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/LiquidationIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Market Crash Icon": {"name": "Market Crash Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MarketCrashIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Martyrdom Icon": {"name": "Martyrdom Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MartyrdomIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Masters Blueprint Icon": {"name": "Master's Blueprint Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MastersBlueprintIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Meditate Icon": {"name": "Meditate Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MeditateIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Mineral Rich Soil Icon": {"name": "Mineral-Rich Soil Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MineralRichSoilIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Mise en Place Icon": {"name": "Mise en Place Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MiseenPlaceIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"More Mice Icon": {"name": "More Mice Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MoreMiceIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Mulligan Munchie Icon": {"name": "Mulligan Munchie Icon","fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MulliganMunchieIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"New Game S Plus Icon": {"name": "New Game S Plus Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/NewGameSPlusIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Overdrive Icon": {"name": "Overdrive Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/OverdriveIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Passive Income Icon": {"name": "Passive Income Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PassiveIncomeIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Patient Gardener Icon": {"name": "Patient Gradener Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PatientGardenerIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Phase Shift Icon": {"name": "Phase Shift Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PhaseShiftIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Phoenix Dawn Icon": {"name": "Phoenix Dawn Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PhoenixDawnIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Pocket Garden Icon": {"name": "Pocket Garden Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PocketGardenIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Pop Rocks Icon": {"name": "Pop Rocks Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PopRocksIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Principal Pulp Icon": {"name": "Principal Pulp Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PrincipalPulpIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Pulp Reactor Icon": {"name": "Pulp Reactor Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/PulpReactorIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Rockmuncher Icon": {"name": "Rockmuncher Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/RockmuncherIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Sacrifical Molt Icon": {"name": "Sacrificial Molt Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SacrificialMoltIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Serpents Coffer Icon": {"name": "Serpent's Coffer Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SerpentsCofferIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Shatter Reality Icon": {"name": "Shatter Reality Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ShatterRealityIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Slither Sauce Icon": {"name": "Slither Sauce Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SlitherSauceIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Snake Clicker Icon": {"name": "Snake Clicker Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SnakeClickerIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Sovereign Trail Icon": {"name": "Sovereign Trail Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SovereignTrailIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Stones Burden Icon": {"name": "Stones Burden Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/StonesBurdenIcon.png", "description": "Get this exclusive upgrade icon as a pfp!",},
		"Sugar Rush Icon": {"name": "Sugar Rush Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SugarRushIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Surveyed Land Icon": {"name": "Surveyed Land Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SurveyedLandIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Synapse Slot Icon": {"name": "Synapse Slot Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/SynapseSlotIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Tectonic Shift Icon": {"name": "Tectonic Shift Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/TectonicShiftIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Tenderizer Icon": {"name": "Tenderizer Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/TenderizerIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"The Cookbook Icon": {"name": "The Cookbook Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/TheCookbookIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"The Satchel Icon": {"name": "The Satchel Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/TheSatchelIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Unstable Metabolism Icon": {"name": "Unstable Metabolism Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/UnstableMetabolismIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Wormhole Icon": {"name": "Wormhole Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/WormholeIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Zenith Icon": {"name": "Zenith Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ZenithIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Zoning Ordinance Icon": {"name": "Zoning Ordinance Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ZoningOrdinanceIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		#Fruit Avatars
		"OG Fruit Icon": {"name": "OG Fruit Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/snake_fruit_red.png", "description": "Get this exclusive fruit icon as a pfp!"},
		"Golden Fruit Icon": {"name": "Golden Fruit Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/golden_fruit_icon.png", "description": "Get this exclusive fruit icon as a pfp!"},
		"Jumping Bean Icon": {"name": "Jumping Bean Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/jumping_bean_icon.png", "description": "Get this exclusive fruit icon as a pfp!"},
		"Ghost Pepper Icon": {"name": "Ghost Pepper Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/ghost_pepper_icon.png", "description": "Get this exclusive fruit icon as a pfp!"},
		"Iron Cherry Icon": {"name": "Iron Cherry Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/iron_cherry_icon.png", "description": "Get this exclusive fruit icon as a pfp!"},
		"Dragon Fruit Icon": {"name": "Dragon Fruit Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/dragon_fruit_icon.png", "description": "Get this exclusive fruit icon as a pfp!"},
		#Rock Avatars
		#Snake Avatars
		#Misc Avatars
	},
	"Banners": {
		"Default": {
			"fang_cost": 0,
			"name": "Default Banner",
			"icon_path": "res://Assets/PNGs/snake_break.png",
			"description": "The standard issue, reliable and clean.",
			"type": "flat",
			"bg_color": "#333333",
			"border_color": "#FFFFFF"
		},
		"Gilded": {
			"fang_cost": 500,
			"name": "Gilded Banner",
			"icon_path": "res://Assets/PNGs/jumping_bean_icon.png",
			"description": "A touch of class for the discerning serpent.",
			"type": "flat",
			"bg_color": "#4a4a4a",
			"border_color": "#F5A623" # A rich gold
		},
		"SnakeCoin Casino": {
			"fang_cost": 250, 
			"name": "SnakeCoin Casino Banner", 
			"icon_path": "res://Assets/PNGs/GambleSprites/snake_poker_chip_tails.png",
			"description": "Show off your love of the game. The house always wins.",
			"type": "texture",
			"texture_path": "res://Assets/PNGs/snake_poker_chip_white.png"
		}
	},
	"Frames": {
		"Default": {
			"name": "Default Frame", "fang_cost": 0,"type": "flat", "color": "#FFFFFF",
			"icon_path": "res://Assets/PNGs/snake_border.png", "description": "Default Frame"
		},
		"Golden Frame": {
			"name": "Golden Frame", "fang_cost": 75,"type": "flat", "color": "#F5A623",
			"icon_path": "res://Assets/PNGs/snake_border.png", "description": "Golden Frame"
		},
		"Cursed Frame": {
			"name": "Cursed Frame", "fang_cost": 75,"type": "texture", "texture_path": "#FFFFFF",
			"icon_path": "res://Assets/PNGs/snake_border.png", "description": "Cursed Frame"
		},
	}
}

var qol_upgrade_data = {
	"Faster Tickers": {
		"display_name": "Faster Tickers", "fang_cost": [50, 100, 150], "max_level": 3,
		"description": "Increases the scroll speed of the news tickers in the upgrade menu.",
		"icon_path": "res://Assets/PNGs/snake_chart_logo.png"
	},
	"Rock Variety": {
		"display_name": "Rock Variety", "fang_cost": [75, 75, 75], "max_level": 3,
		"description": "Unlocks new cosmetic styles for the rocks in the garden.",
		"icon_path": "res://Assets/PNGs/UpgradeIcons/GeodeCrackerIcon.png"
	},
	"The Randomizer": {
		"display_name": "The Randomizer", "fang_cost": [500], "max_level": 1,
		"description": "Adds a 'Random Run' button to the selection screen.",
		"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_3.png"
	}
}

var lore_unlock_data = {
	"Codex of Feats": {"fang_cost": 100, "icon_path": "res://..."},
	"Ouroboros Cipher 1": {"fang_cost": 1, "icon_path": "res://..."}, #first clue, there is an easter egg
	"Ouroboros Cipher 2": {"fang_cost": 1000, "icon_path": "res://..."}, #new game s+
	"Ouroboros Cipher 3": {"fang_cost": 1000, "icon_path": "res://..."}, #only 3 fruits G1
	"Ouroboros Cipher 4": {"fang_cost": 1000, "icon_path": "res://..."}, #win a coin toss G2
	"Ouroboros Cipher 5": {"fang_cost": 1000, "icon_path": "res://..."}, #use 1 ability G3
	"Ouroboros Cipher 6": {"fang_cost": 1000, "icon_path": "res://..."}, #hold 25 mL juice G4
	"Ouroboros Cipher 7": {"fang_cost": 1000, "icon_path": "res://..."}, #hold 5 mL or less juice G5
	"Ouroboros Cipher 8": {"fang_cost": 1000, "icon_path": "res://..."}, #win dice roll G6
	"Ouroboros Cipher 9": {"fang_cost": 1000, "icon_path": "res://..."}, #no upgrades G7
	"Ouroboros Cipher 10": {"fang_cost": 1000, "icon_path": "res://..."}, #no fruit 60 sec G8
	"Ouroboros Cipher 11": {"fang_cost": 2000, "icon_path": "res://..."}, #super egg exists
	"Ouroboros Cipher 12": {"fang_cost": 2000, "icon_path": "res://..."}, # 4 diff fruits G10
	"Ouroboros Cipher 13": {"fang_cost": 2000, "icon_path": "res://..."}, # JukeNJive + combo 11
	"Tome of the Splice": {"fang_cost": 250, "icon_path": "res://..."}, #special fruits/fruit
	"Tome of the Ledger": {"fang_cost": 250, "icon_path": "res://..."}, #block market
	"Tome of the Atlas": {"fang_cost": 250, "icon_path": "res://..."}, #gardens
	"Tome of the Pantheon": {"fang_cost": 250, "icon_path": "res://..."}, #classes
	"Tome of the Compendium": {"fang_cost": 250, "icon_path": "res://..."}, #pacts
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
	score_needed_for_next_level = 5 # Or initial starting value
	
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
	
	if special_fruit_chance_doubled:
		total_chance *= 2.0
			
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

func start_new_game_s_plus():
	print("Starting New Game S+!")
	current_garden = 1
	start_game(true)
	
func start_game(is_prestige_run: bool = false):
	if not is_prestige_run:
		# If it's a totally new run, we reset EVERYTHING.
		_reset_career_variables()
	_reset_garden_variables()
	var diff_data = difficulty_data.get(chosen_difficulty, {})
	var class_data_chosen = class_data.get(chosen_class, {})
	# --- 3. Apply Modifiers from the chosen DIFFICULTY ---
	# We only add starting Juice on a non-prestige run.
	if not is_prestige_run:
		juice += diff_data.get("start_juice", 0)
		max_ability_slots = diff_data.get("start_slots", 0)
	
	var diff_upgrades = diff_data.get("start_upgrades", {})
	for upgrade_key in diff_upgrades:
		_apply_starting_upgrade(upgrade_key, diff_upgrades[upgrade_key])
	
	# --- 4. Apply Modifiers from the chosen CLASS ---
	var class_upgrades = class_data_chosen.get("start_upgrades", {})
	for upgrade_key in class_upgrades:
		_apply_starting_upgrade(upgrade_key, class_upgrades[upgrade_key])
	var class_stats = class_data_chosen.get("start_stats", {})
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
	new_game_s_plus_active = is_prestige_run
	reset_for_new_garden()
	SceneTransition.transition_to("res://Scenes/main.tscn", "spiral")
	get_tree().paused = false

#per garden reset
func _reset_garden_variables():
	print("Resetting stats for new garden.")
	player_level = 1
	score_needed_for_next_level = 5
	score_at_level_start = 0
	has_died_this_garden = false
	juice_spent_this_garden = 0
	abilities_used_this_garden = 0
	garden_start_time = run_time # Set the start time to the current run time
	segments_to_restore = 0
	passive_gps = 0.0
	
	
	# Reset any "once per garden" flags
	juice_press_used_this_garden = false
	garden_weaver_used_this_garden = false
	
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
	#---EE stuff---#
	highest_combo_this_garden = 0
	garden_11_juke_count = 0
	garden_10_special_fruits_eaten = []
	
	# Reset easter egg progress if it's not a prestige run
	if not new_game_s_plus_active:
		ascension_steps_completed.clear()
		paradox_engine_active = false

# Fresh run reset
func _reset_career_variables():
	#-----Base Stat Reset------
	juice = 0
	pulp = 0
	current_garden = 1
	
	#--------Run Stat Tracking----------#
	run_time = 0.0
	total_juice_earned_this_run = 0
	total_juice_earned_this_run = juice
	total_pulp_earned_this_run = 0
	rocks_destroyed_this_run = 0
	upgrades_purchased_this_run = 0
	times_died_this_run = 0
	fruits_eaten_this_run = 0
	#---EE Tracking for Super EE---#
	super_egg_step_10_complete = false
	super_egg_step_11_complete = false
	#---END GAME FLAGS---------
	free_upgrades_unlocked = false
	roll_credits_unlocked = false
	# --- Reset all upgrade levels and unlocks ---
		# --- "PULP" META-UPGRADE LEVELS ---
	serpents_coffer_level = 0
	geode_compass_level = 0
	four_leaf_clover_level = 0
	chroma_scales_level = 0
	harvest_forecast_level = 0
	#-----------The Core-------------
		#Idle
	snake_clicker_level = 0
	get_rich_quick_unlocked = false
	custom_aftertaste_unlocked = false
	arcane_flow_unlocked = false
	pulp_reactor_unlocked = false
	unstable_metabolism_unlocked = false
		#Planner
	diet_slith_level = 0
	fruit_foresight_unlocked = false
	ghost_tail_level = 0
	geological_survey_unlocked = false
	sovereign_trail_level = 0
	garden_weaver_unlocked = false
		#Ledger
	chosen_ledger_path = ""
			# Path A (Juice Focus)
	liquid_assets_level = 0
	fast_track_unlocked = false
	gluttons_greed_unlocked = false
	market_crash_level = 0
			# Path B (Pulp Focus)
	principal_pulp_level = 0
	golden_handshake_level = 0
			# Juice Press is an active ability, so it will be handled by hotbar system
	liquidation_used = false
	#-----------The Harvest-------------
		#Glutton
	es_portions_level = 0
	more_mice_level = 0
	golden_seeds_level = 0
	patient_gardener_level = 0
	is_bounty_active = false
	the_satchel_unlocked = false
		#Chef
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
		#Geomancer
	fertile_ground_level = 0
	mineral_rich_soil_level = 0
	tectonic_shift_level = 0
	heavy_foundation_level = 0
	rockeater_type = "" # e.g., "Rockmuncher", "Geode Cracker", etc.
	calculated_risk_unlocked = false
	#-----------The Redline-------------
		#Acrobat
	slither_sauce_level = 0 
	juke_and_jive_unlocked = false
	afterburner_level = 0
	pop_rocks_unlocked = false
	autotomy_unlocked = false
	autotomy_is_active = false
	autotomy_used_this_garden = false
		#Frenzy
	sugar_rush_unlocked = false
	chain_reaction_level = 0
	overdrive_level = 0
	lingering_rush_level = 0
	juggernaut_unlocked = false
	is_zenith_active = false
	current_combo = 0
	combo_is_pure = true
		#SURVIVOR
	extra_lives = 0
	phoenix_dawn_unlocked = false
	last_stand_unlocked = false
	sacrificial_molt_used_this_run = false
	sacrificial_molt_unlocked = false
	death_defied_unlocked = false
	martyrdom_unlocked = false
	#-----------The Ssscale-------------
		#Architect
	edge_lord_level = 0
	zoning_ordinance_level = 0
	border_czar_unlocked = false
	surveyed_land_unlocked = false
	active_pocket_garden_rect = null
	fold_space_unlocked = false
	masters_blueprint_unlocked = false
	shatter_reality_unlocked = false
		#Magician/Illusionist
	ghost_tail_level = 0
	three_card_monty_unlocked = false
	fractured_self_unlocked = false
	dazzle_pie_unlocked = false
	#-----------Snake Eyes-------------
	coin_flip_curious_unlocked = false
	passive_income_unlocked = false
	correct_bets_this_run = 0
	block_market_portfolio.clear()
	block_market_prices = {
		"Orange Block": {"price": 10, "currency": "Juice"},
		"Apple Block":  {"price": 10, "currency": "Juice"},
		"Light Block":  {"price": 25, "currency": "Pulp"},
		"Extra Block":  {"price": 25, "currency": "Pulp"}
	}
	#-----Clear Abilities-----
	ability_charges.clear()
	equipped_abilities.clear()
	legendary_items_seen_this_run.clear()
	#----Reset Easter Egg Progress----#
	paradox_engine_active = false
	paradox_engine_is_upgraded = false
	special_fruit_chance_doubled = false
	ascension_steps_completed.clear()
	# --- OUROBOROS BOSS STATE ---
	is_ouroboros_fight_active = false
	ouroboros_phase = 1 # Can be 1, 2, or 3
	current_trial_key = ""
	trial_failed = false
	# --- TRIAL-SPECIFIC TRACKERS ---
	trial_haste_fruits_eaten = 0
	trial_patience_fruits_eaten = 0
	trial_illusion_phases = 0
	trial_memory_sequence = []
	trial_memory_progress = 0
	# --- Super Egg Boss Flag --- #
	should_spawn_corrupted_ouroboros = false

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
