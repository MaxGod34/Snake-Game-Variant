extends Node


signal pulp_changed(new_amount: int)
signal pulp_bundle_recorded(bundle: PulpBundleData)
signal ability_slots_changed(new_slots: int)
signal market_recession_changed(is_active: bool)
signal go_back_garden_requested


# --- Pulp Stand State Machine ---
var claimed_pulp_bundles: Dictionary = {}
var pulp_bundle_history: Array[PulpBundleData] = []
## Curse / special-effect flags
var controls_reversed: bool = false
var market_in_recession: bool = false
var chroma_scales_enabled: bool = true


#------Session State---------#
var chosen_difficulty = "viper"
var current_difficulty_tier: int = 0
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
	2: {"name": "The Juice Box", "score_goal": 60, "obstacle_count": 3},
	3: {"name": "The Danger Noodle Den", "score_goal": 95, "obstacle_count": 5},
	
	# --- The Mid-Game ---
	4: {"name": "The Forked Tongue Bistro", "score_goal": 140, "obstacle_count": 8},
	5: {"name": "Rhythm & Haste", "score_goal": 180, "obstacle_count": 12},
	6: {"name": "The Architect's Grid", "score_goal": 225, "obstacle_count": 18},

	# --- The Endgame ---
	7: {"name": "The Basilisk's Lair", "score_goal": 275, "obstacle_count": 25},
	8: {"name": "The Kill Screen Quarry", "score_goal": 340, "obstacle_count": 35},
	9: {"name": "The Garden of Eatin'", "score_goal": 420, "obstacle_count": 50},
	# --- The END ---
	10: {"name": "Revelations", "score_goal": 2500, "obstacle_count": 66},
	11: {"name": "The End", "score_goal": 10000, "obstacle_count": 150},
	12: {"name": "Genesis", "score_goal": 30000, "obstacle_count": 100},
	# --- Endless ---
	13: {"name": "Victory Lap", "score_goal": 999999, "obstacle_count": 0}
}

var garden_bonus_data = {
	"par_time": {"base_reward": 500, "time_limit": 60.0}, # 50 mg if garden is beaten in under 60s
	"no_death": {"reward": 250}, # 25 mg for a flawless, no-death garden
	"ascetic": {"reward": 100}, # 100 mg if no upgrades were purchased this garden
	"pacifist": {"reward": 100}, # 15 mg if no active abilities were used
	"engagement": {"reward": 2} # +2 mg for every L spent on upgrades this garden
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
var player_level: int = 1
var juice: int = 0
var pulp: int = 0
var score_needed_for_next_level = 5
var score_at_level_start = 0

var fruits_eaten_this_run: int = 0
var total_juice_this_run: int = 0
var segments_to_restore = 0

# --- BONUS TRACKING VARS ---
var juice_spent_this_garden: int = 0
var abilities_used_this_garden: int = 0
var garden_start_time: float = 0.0

#----Upgrade Data Tracking----#
var fruit_reward = 1
var max_fruits_on_screen: int = 1

# --- "PULP" META-UPGRADE LEVELS ---
const META_UPGRADES_DIR = "res://Convenience/MetaUpgrades/"
var meta_upgrades: Dictionary = {}

var chroma_scales_level: int = 0
var four_leaf_clover_level: int = 0
var themed_tickers_level: int = 0
var the_gambit_level: int = 0
var compound_interest_level: int = 0

# --- UPGRADES ---
const UPGRADES_DIR = "res://Convenience/Upgrades/"
var upgrades: Dictionary = {}

var ability_charges = {}
var equipped_abilities: Array = []
var max_ability_slots: int = 0
const ACTIVE_ABILITIES: Array[String] = [
	"Burrow", "Phase Shift", "Blink", "Pocket Garden", "Banana Bounty",
	"Meditate", "Zenith", "Autotomy", "Tenderizer", "Juice Press", "Lasso Larry"
]

#--------Rotating Item Stuff------#
var extra_lives_are_capped: bool = false
var legendary_items_seen_this_run: Array = []

	#----Active Ability Flags----#
var burrow_is_active = false
var is_phasing = false 
var is_bounty_active = false
var autotomy_is_active = false
var is_zenith_active = false


#------------------------------the core(Idle, Planner, Ledger-------------------------------------------------------#
#------The Planner-------#
var diet_slith_level = 0
var fruit_foresight_unlocked = false
var geological_survey_unlocked = false
var sovereign_trail_level = 0
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
var golden_handshake_level = 0
var juice_press_used_this_garden: bool = false
# Juice Press is an active ability, so it will be handled by our hotbar system
var liquidation_unlocked = false

# --- Idle Path ---
var snake_clicker_level = 0
var get_rich_quick_unlocked = false
var custom_aftertaste_unlocked = false
var arcane_flow_unlocked = false
var pulp_reactor_unlocked = false
var unstable_metabolism_unlocked = false
# track the total passive GPS
var passive_gps: float = 0.0

#-------------------------------the harvest(Glutton, Chef, Geomancer)------------------------------#
#-----------THE GLUTTON----------------#
var es_portions_level: int = 0
var more_mice_level: int = 0
var golden_seeds_level = 0
var patient_gardener_level = 0
var golden_seed_extract_level = 0

# --- Wrangler Path ---
var extended_reach_level: int = 0
var active_gratification_level: int = 0
var double_lasso_unlocked: bool = false
var lasso_rhythm_unlocked: bool = false
var lasso_rhythm_counter: int = 0
# --- Geomancer Path ---
var fertile_ground_level: int = 0
var mineral_rich_soil_level: int = 0
var rockmuncher_unlocked: bool = false
var geode_cracker_unlocked: bool = false
var calculated_risk_unlocked: bool = false

#-------------------------------the redline(Acrobat, Frenzy, Survivor)-----------------------------#
#----------ACROBAT PATH-----#
var slither_sauce_level: int = 0 
var juke_and_jive_unlocked: bool = false
var afterburner_level: int = 0
var pop_rocks_unlocked: bool = false
var autotomy_unlocked: bool = false
var autotomy_used_this_garden: bool = false

# --- Frenzy Path ---
var sugar_rush_unlocked = false
var chain_reaction_level = 0
var overdrive_level = 0
var lingering_rush_level = 0
# track the combo itself
var current_combo = 0
var combo_is_pure = true

#---------SURVIVOR PATH----------#
var extra_lives = 0
var phoenix_dawn_unlocked = false
var last_stand_unlocked = false
var death_defied_unlocked = false
var martyrdom_unlocked = false
var times_died_this_run = 0
var new_game_s_plus_active = false 

#------------------------------the ssscale(Architect, Illusionist/Magician)------------------------#
#------------THE ARCHITECT-----------#
var edge_lord_level = 0
var zoning_ordinance_level = 0
var border_czar_unlocked = false
var active_pocket_garden_rect = null
# Ultimate Keystones
var fold_space_unlocked = false
var masters_blueprint_unlocked = false
var shatter_reality_unlocked = false
#------------------------------------#

#-----------#illusionist------------#
var ghost_tail_level = 0
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
	"Light Block":  {"price": 100, "currency": "Pulp"},
	"Extra Block":  {"price": 100, "currency": "Pulp"}
}

var juice_spent_per_sub_path: Dictionary = {}

#^^^^^^^^^^^^^^^^--------------------------------------------------------------^^^^^^^^^^^^^^^^#
#||||||||||||||||--------------------------------------------------------------||||||||||||||||#
#________________||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||________________#
#________________VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV________________#
var difficulty_data = {
	"Tier 0": preload("res://Convenience/Difficulty/diff_tier0.tres"),
	"Tier 1": preload("res://Convenience/Difficulty/diff_tier1.tres"),
	"Tier 2": preload("res://Convenience/Difficulty/diff_tier2.tres"),
	"Tier 3": preload("res://Convenience/Difficulty/diff_tier3.tres"),
	"Tier 4": preload("res://Convenience/Difficulty/diff_tier4.tres"),
	"Tier 5": preload("res://Convenience/Difficulty/diff_tier5.tres"),
	"Tier 6": preload("res://Convenience/Difficulty/diff_tier6.tres"),
	"Tier 7": preload("res://Convenience/Difficulty/diff_tier7.tres"),
	"Tier 8": preload("res://Convenience/Difficulty/diff_tier8.tres"),
	"Tier 9": preload("res://Convenience/Difficulty/diff_tier9.tres"),
}   #===================================================================================
#---------CLASS PARAMETERS--------#
var class_data = {#~1000 lines saved
#| PhoenixDawn(1) | Extra Lives: 1 | 2 max_fruits |
	"Mulligan": preload("res://Convenience/Classes/class_Mulligan.tres"),
#| PatientGardener(3) | ESP(3) | NO GAMBLING |
	"Purist": preload("res://Convenience/Classes/class_Purist.tres"),
#| Roguelite Class (Rotating item) |
	"Larry": preload("res://Convenience/Classes/class_Larry.tres"),
#| DeathDefied(1) | Extra lives: 9 | No pulp |
	"Phoenix Coil": preload("res://Convenience/Classes/class_PhoenixCoil.tres"),
#| SClicker(7) | juice_tax_rate: 0.40 |
	"Tycoon": preload("res://Convenience/Classes/class_Tycoon.tres"),
#| ESP cap at lvl5 | LiquidAssets(3) | FastTrack(1) |
	"Day Trader": preload("res://Convenience/Classes/class_DayTrader.tres"),
#| Global juice cost modifier: 1.20 | PrinPulp(5) | Juice Press(1)
	"Manager": preload("res://Convenience/Classes/class_Manager.tres"),
#| Dynamic reward and max fruits |
	"Calculator": preload("res://Convenience/Classes/class_Calculator.tres"),
#| Illusionist ghost path | GhostTail(4) | ArcaneFlow(1) | SnakeClicker(3) |
	"Ghost": preload("res://Convenience/Classes/class_Ghost.tres"),
#| EdgeLord(7) | ShatterReality(1) | 100% faster | IDLE path disabled |
	"Space": preload("res://Convenience/Classes/class_Space.tres"),
#| Cheaper Illusionist path with Fractured self off the rip |
	"Blinker": preload("res://Convenience/Classes/class_Blinker.tres"),
#| FruitForesight(1) | DietSlith(5) | Meditate(3) | speed_increase_on_eat |
	"Psychic": preload("res://Convenience/Classes/class_Psychic.tres"),
#| CFlipCurious(1) | PassiveIncome(1) | No Planner Path | speed_on_loss |
	"Doubles": preload("res://Convenience/Classes/class_Doubles.tres"),
#| SugarRush(1) | ChainReaction(1) | Overdrive(2) | LingeringRush(2) | DietSlith(3) | all_fruits_special |
	"Comboisseur": preload("res://Convenience/Classes/class_Comboisseur.tres"),
#| BananaBounty(2) | MoreMice(4) | Illusionist disabled |
	"Sniper": preload("res://Convenience/Classes/class_Sniper.tres"),
#| GeoSurvey(1) | obstacle_modifier: 1.50 | geological_survey_multiplies: true |
	"Mineral": preload("res://Convenience/Classes/class_Mineral.tres"),
#| ExoticSeeds(3) | CustomAftertaste(1) | SnakeClicker(3) |
	"Gobble": preload("res://Convenience/Classes/class_Gobble.tres"),
#| Double all fruit reward | only 1 fruit |
	"Gluts": preload("res://Convenience/Classes/class_Gluts.tres"),
#| JukenJive(1) | Mulligan(1) | GetRichQuick(1) | SnakeClicker(3) |
	"Groove": preload("res://Convenience/Classes/class_Groove.tres"),
#| 25% chance to get juice from fruit, not from leveling at all make cheaper stuff idk |
	"Alchemist": preload("res://Convenience/Classes/class_Alchemist.tres")}
# Dictionary for upgrades costs and rules



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
			"description": "Default Pattern.\nSlot 1 only.", 
			"sequence": [0]
		},
		"Tiger Stripes": {
			"name": "Tiger Stripes Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/GambleSprites/PlusOne.png", 
			"description": "Add a nice stripe to your snake!\nAlternate Slot 1 & 2.",
			"sequence": [0,1]
		},
		"Dimer": {
			"name": "Dimer Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/GambleSprites/PlusOne.png", 
			"description": "Every 10 segments, alternate colors!\nAlternate Slot 1 & 2",
			"sequence": [0,0,0,0,0,0,0,0,0,0,
						1,1,1,1,1,1,1,1,1,1]
		},
		"Simple Spread": {
			"name": "Simple Spread Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "1, 2, 2, 2, 1\nAlternate Slot 1 & 2",
			"sequence": [0,1,1,1,0]
		},
		"Slith Spread": {
			"name": "Slith Spread Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "1, 2, 3, 4, 3, 2, 1\nUtilize Slot 1,2,3,4",
			"sequence": [0,1,2,3,2,1]
		},
		"MAX AURA": {
			"name": "MAX AURA Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "1, 2, 3, 4, 5\nUtilize all slots!",
			"sequence": [0,1,2,3,4]
		},
		"Fading Fast": {
			"name": "Fading Fast Pattern","fang_cost": 75, 
			"icon_path": "res://Assets/PNGs/Dice/snake_dice_128_dice_1.png", 
			"description": "Dev Custom #1",
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
			"icon_path": "res://Assets/PNGs/DifficultyPics/CursedPact4Icon.png", "description": "The Void..."
		},
		"The Undergrowth": {
			"name": "The Undergrowth", "fang_cost": 200, "type": "particles", "effect_name": "Undergrowth",
			"icon_path": "res://Assets/PNGs/golden_fruit_icon.png", "description": "Get Growin'"
		},
		"The Digital Stream": {
			"name": "The Digital Stream", "fang_cost": 250, "type": "shader", "shader_name": "DigitalStream",
			"icon_path": "res://Assets/PNGs/UpgradeIcons/WormholeIcon.png", "description": "Let's Get Digital, Digital"
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
		"Mulligan Icon": {"name": "Mulligan Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/MulliganMunchieIcon.png", "description": "unlock the mulligan class icon as a pfp!"},
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
		"Chroma Scales Icon": {"name": "Chroma Scales Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ChromaScalesIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Coin Flip Curious Icon": {"name": "Coin Flip Curious Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CoinFlipCuriousIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Custom Aftertaste Icon": {"name": "Custom Aftertaste Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CustomAfterTasteIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Custom Cuisine Icon": {"name": "Custom Cuisine Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/CustomCuisineIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Dazzle Pie Icon": {"name": "Dazzle Pie Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/DazzlePieIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Death Defied Icon": {"name": "Death Defied Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/DeathDefiedIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Diet Slith Icon": {"name": "Diet Slith Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/DietSlithIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Edge Lord Icon": {"name": "Edge Lord Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/EdgeLordIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Elephant Sized Portions Icon": {"name": "Elephant Sized Portions Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ESPortionsIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Exotic Seeds Icon": {"name": "Exotic Seeds Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ExoticSeedsIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Expanded Palate Icon": {"name": "Expanded Palate Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/ExpandedPalateIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fertile Ground Icon": {"name": "Fertile Ground Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FertileGroundIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fold Space Icon": {"name": "Fold Space Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FoldSpaceIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Four Leaf Clover Icon": {"name": "Four Leaf Clover Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FourLeafCloverIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
		"Fractured Self Icon": {"name": "Fractured Self Icon", "fang_cost": 50, "icon_path": "res://Assets/PNGs/UpgradeIcons/FracturedSelfIcon.png", "description": "Get this exclusive upgrade icon as a pfp!"},
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
			"icon_path": "res://Assets/Templates/snake_lime.png",
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
			"name": "Default Frame", "fang_cost": 0,"type": "flat", "color": "#282828",
			"icon_path": "res://Assets/PNGs/snake_border.png", "description": "Default Frame"
		},
		"Golden Frame": {
			"name": "Golden Frame", "fang_cost": 75,"type": "flat", "color": "#F5A623",
			"icon_path": "res://Assets/PNGs/snake_border.png", "description": "Golden Frame"
		},
		"Cursed Frame": {
			"name": "Cursed Frame", "fang_cost": 75,"type": "flat", "texture_path": "#FFFFFF",
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

var milestone_data = {
	"total_deaths": {
		"display_name": "Fated to Fail",
		"description": "Reach a total number of deaths across all runs.",
		"icon_path": "res://Assets/PNGs/MilestoneIcons/DeathsMilestoneIcon.png",
		"tiers": [
			{"goal": 5, "reward": 100, "key": "deaths_1"},
			{"goal": 25, "reward": 300, "key": "deaths_2"},
			{"goal": 50, "reward": 700, "key": "deaths_3"},
			{"goal": 100, "reward": 1000, "key": "deaths_4"}

		]
	},
	"upgrades_purchased": {
		"display_name": "Juice Fiend",
		"description": "Buy upgrades. Plain and simple.",
		"icon_path": "res://Assets/PNGs/MilestoneIcons/JuiceFiendMilestoneIcon.png",
		"tiers":[
			{"goal": 50, "reward": 100, "key": "upgrades_1"},
			{"goal": 200, "reward": 300, "key": "upgrades_2"},
			{"goal": 1000, "reward": 700, "key": "upgrades_3"},
			{"goal": 2500, "reward": 1000, "key": "upgrades_4"}
		]
	},
	"highest_garden_reached": {
		"display_name": "Explorer",
		"description": "Successfully conquer higher gardens.",
		"icon_path": "res://Assets/PNGs/MilestoneIcons/HighestGardenMilestoneIcon.png",
		"tiers": [
			{"goal": 9, "reward": 300, "key": "garden_9"},
			{"goal": 12, "reward": 700, "key": "garden_12"},
			{"goal": 13, "reward": 2500, "key": "garden_13"}
		]
	},
	"prestiges_completed": {
		"display_name": "Time Looper",
		"description": "Enter New Game S+",
		"icon_path": "res://Assets/PNGs/MilestoneIcons/TimeLooperMilestoneIcon.png",
		"tiers": [
			{"goal": 3, "reward": 250, "key": "prestige_1"},
			{"goal": 5, "reward": 750, "key": "prestige_2"},
			{"goal": 10, "reward": 1000, "key": "prestige_3"},
			{"goal": 25, "reward": 2500, "key": "prestige_4"}
		]
	}
}


# --- ROTATING SHOP ITEM POOLS ---

var common_items = [
	{
		"id": "juice_box",
		"name": "Juice Box",
		"description": "A refreshing treat!\nInstantly grants Juice equal to the current Garden number.",
		"cost": 30,
		"rarity": "Common",
		"max_level": 1,
		"icon_path": "res://Assets/PNGs/RotatingItemIcons/juice_box_icon.png"
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
		"targets_upgrade": "Elephant Sized Portions",
		"icon_path": "res://Assets/PNGs/RotatingItemIcons/elephant_devoured_icon.png"
	},
	# ... (add more legendary items here later)
]

var cursed_items = [
	{
		"id": "handicap",
		"name": "Handicap",
		"description": "A deal with the devil.\nInstantly unlock a new Ability Slot,\nbut your maximum Extra Lives is now permanently capped at 0.",
		"cost": 0,
		"rarity": "Cursed",
		"max_level": 1
	},
	# ... (add more rare items here later)
]


func _ready():
	_load_all_upgrades(UPGRADES_DIR)
	_load_all_meta_upgrades(META_UPGRADES_DIR)
	
func _load_all_upgrades(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("Could not open upgrades foler: " + dir_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		
		var full_path = dir_path.path_join(file_name)
		if dir.current_is_dir():
			_load_all_upgrades(full_path)
		elif file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
			var res = load(full_path.trim_suffix(".remap"))
			if res is UpgradeData:
				var key = res.id if res.id != "" else res.display_name
				upgrades[key] = res
		
		file_name = dir.get_next()
		
	dir.list_dir_end()

func _load_all_meta_upgrades(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("Could not find meta upgrades folder: " + dir_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		
		var full_path = dir_path.path_join(file_name)
		if dir.current_is_dir():
			_load_all_meta_upgrades(full_path)
		elif file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
			var res = load(full_path.trim_suffix(".remap"))
			if res is MetaUpgradeData and res.enabled:
				var key = res.id if res.id != "" else res.display_name
				meta_upgrades[key] = res
		
		file_name = dir.get_next()
	dir.list_dir_end()


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
			while es_portions_level < upgrades["Elephant Sized Portions"].max_level:
				apply_esp_level_up()


func reset_for_new_garden():
	# This function resets all stats that should be fresh for a new garden.
	
	# Reset the player's level back to 1.
	player_level = 1
	
	# Reset the XP and goals back to their starting values.
	score_at_level_start = 1
	score_needed_for_next_level = get_length_for_level(2)
	
	# Crucially, we do NOT reset juice, pulp, or any purchased upgrades.




#----------FUNCTIONS-----------#
func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	



func get_golden_fruit_chance() -> float:
	if all_fruits_special:
		return 1.0

	var total_chance: float = 0.0
	
	var gs_rules = get_upgrade_rules("Golden Seeds") as DualStatUpgrade
	if gs_rules:
		total_chance += gs_rules.get_stat_a(golden_seeds_level, 0.0)
	
	if golden_seed_extract_level > 0:
		var gse_rules = get_upgrade_rules("Golden Seed Extract")
		if gse_rules:
			total_chance += gse_rules.get_value_at_level(golden_seed_extract_level, 0.0)
	
	if special_fruit_chance_doubled:
		total_chance *= 2.0
	
	return clampf(total_chance, 0.0, 1.0)


func get_upgrade_rules(upgrade_key: String) -> UpgradeData:
	return upgrades.get(upgrade_key)


func check_prerequisites(upgrade_key: String) -> bool:
	var upgrade = get_upgrade_rules(upgrade_key)
	if not upgrade:
		return false

	for req_key in upgrade.prerequisites:
		var raw_val = upgrade.prerequisites[req_key]


		if typeof(req_key) != TYPE_STRING:
			push_warning("Swapped prerequisite key/value on '%s': %s -> %s" % [upgrade_key, req_key, raw_val])
			continue


		var req_level: int = int(raw_val)
		if get_upgrade_level_from_key(req_key) < req_level:
			return false

	return true

func calculate_upgrade_cost(upgrade_key: String) -> int:
	var upgrade = get_upgrade_rules(upgrade_key)
	if not upgrade: return 999
	
	var current_level = get_upgrade_level_from_key(upgrade_key)
	if current_level >= upgrade.max_level: return 999 # A high number for "unaffordable"
	
	var diff_data = difficulty_data.get(chosen_difficulty)
	var chosen_class_data = class_data.get(chosen_class)
	var base_cost = upgrade.costs[current_level]
	var diff_mod = diff_data.juice_cost_modifier if diff_data else 0
	var class_mod = chosen_class_data.cost_modifiers.get(upgrade_key, 0) if chosen_class_data else 0
	var final_cost = base_cost + diff_mod + class_mod
	
	# Apply cost reduction upgrades
	if GameManager.three_card_monty_unlocked and upgrade_key != "3 Card Monty":
		final_cost -= 1
	if GameManager.market_crash_level > 0 and upgrade_key != "Market Crash":
		final_cost -= GameManager.market_crash_level
		
	return max(1, final_cost)

func get_upgrade_level_from_key(upgrade_key: String) -> int:
	match upgrade_key:
		"Elephant Sized Portions": return es_portions_level
		"Mulligan Munchie": return extra_lives
		"3 Card Monty": return 1 if three_card_monty_unlocked else 0
		"Juke N Jive": return 1 if juke_and_jive_unlocked else 0

	if upgrade_key in ability_charges:
		return ability_charges[upgrade_key].total

	var clean_name = upgrade_key.to_snake_case().replace("'", "").replace("-", "_")
	var var_name_level = clean_name + "_level"
	if var_name_level in self:
		return get(var_name_level)

	var var_name_unlocked = clean_name + "_unlocked"
	if var_name_unlocked in self:
		return 1 if get(var_name_unlocked) else 0

	return 0

func apply_esp_level_up():
	var upgrade = get_upgrade_rules("Elephant Sized Portions")
	var max_lvl = upgrade.max_level if upgrade else 20
	if es_portions_level < max_lvl:
		es_portions_level += 1


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
		var rules = upgrades.get(upgrade_key)
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
	var diff_data = difficulty_data.get(chosen_difficulty)
	var class_data_chosen = class_data.get(chosen_class)
	# --- 3. Apply Modifiers from the chosen DIFFICULTY ---
	# We only add starting Juice on a non-prestige run.
	if diff_data:
		current_difficulty_tier = diff_data.tier
		if not is_prestige_run:
			juice += diff_data.start_juice
			max_ability_slots = 0 if is_tier_active(3) else diff_data.start_slots

		for upgrade_key in diff_data.start_upgrades:
			_apply_starting_upgrade(upgrade_key, diff_data.start_upgrades[upgrade_key])
	
	# --- 4. Apply Modifiers from the chosen CLASS ---
	if class_data_chosen:
		for upgrade_key in class_data_chosen.start_upgrades:
			_apply_starting_upgrade(upgrade_key, class_data_chosen.start_upgrades[upgrade_key])
		
		for stat_key in class_data_chosen.start_stats:
			match stat_key:
				"extra_lives": extra_lives += class_data_chosen.start_stats[stat_key]
				"max_fruits": max_fruits_on_screen = class_data_chosen.start_stats[stat_key]
				"fruit_reward_multiplier": fruit_reward *= class_data_chosen.start_stats[stat_key]
				"max_fruits_cap": max_fruits_on_screen = class_data_chosen.start_stats[stat_key] 
				# This will need a check in the "More Mice" upgrade
				"juice_tax_rate": juice_tax_rate = class_data_chosen.start_stats[stat_key]
				"max_esp_level": max_esp_level = class_data_chosen.start_stats[stat_key]
				"global_juice_cost_multiplier": global_juice_cost_multiplier = class_data_chosen.start_stats[stat_key]
				"speed_multiplier": speed_multiplier_class_mod = class_data_chosen.start_stats[stat_key]
				"obstacle_modifier": obstacle_modifier = class_data_chosen.start_stats[stat_key]
				"disabled_paths": disabled_paths = class_data_chosen.start_stats[stat_key]
				# --- Boolean Flags/ Other ---
				"juice_on_level_up_disabled": juice_on_level_up_disabled = true
				"juice_chance_on_eat": juice_chance_on_eat = class_data_chosen.start_stats[stat_key]
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
	four_leaf_clover_level = 0
	chroma_scales_level = 0
	themed_tickers_level = 0
	compound_interest_level = 0
	the_gambit_level = 0
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
	liquidation_unlocked = false
	#-----------The Harvest-------------
		#Glutton
	es_portions_level = 0
	more_mice_level = 0
	golden_seeds_level = 0
	patient_gardener_level = 0
	is_bounty_active = false
	golden_seed_extract_level = 0
		#Wrangler
	extended_reach_level = 0
	active_gratification_level = 0
	double_lasso_unlocked = false
	lasso_rhythm_unlocked = false
	lasso_rhythm_counter = 0
		#Geomancer
	fertile_ground_level = 0
	mineral_rich_soil_level = 0
	rockmuncher_unlocked = false
	geode_cracker_unlocked = false
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
	is_zenith_active = false
	current_combo = 0
	combo_is_pure = true
		#SURVIVOR
	extra_lives = 0
	phoenix_dawn_unlocked = false
	last_stand_unlocked = false
	death_defied_unlocked = false
	martyrdom_unlocked = false
	#-----------The Ssscale-------------
		#Architect
	edge_lord_level = 0
	zoning_ordinance_level = 0
	border_czar_unlocked = false
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
	#---Floating ledger for juice per upgrade---#
	juice_spent_per_sub_path.clear()
	
	reset_pulp_stand_run_state()


func _apply_starting_upgrade(upgrade_key: String, levels_to_add: int):
	print("Applying starting upgrade: %s, Level: %s" % [upgrade_key, levels_to_add])
	
	# Define a list of all possible active abilities.
	var active_abilities = [
		"Burrow", "Phase Shift", "Blink", "Pocket Garden", "Banana Bounty", 
 		"Meditate", "Zenith", "Autotomy", "Tenderizer", "Juice Press", "Lasso Larry"
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

func get_length_for_level(target_level: int) -> int:
	if target_level <= 1:
		return 1
	var ci_data = meta_upgrades.get("Compound Interest") as MetaUpgradeData
	var discount = int(ci_data.get_value_at_level(compound_interest_level, 0.0)) if ci_data else 0
	return max(2, (target_level * target_level) - discount)

func is_tier_active(tier_num: int) -> bool:
	return current_difficulty_tier >= tier_num

func get_effective_par_time() -> float:
	var base_time: float = garden_bonus_data["par_time"]["time_limit"]
	if is_tier_active(6):
		return base_time * 0.5 # 30s
	return base_time

func get_effective_garden_goal(garden_id: int) -> int:
	var base_goal: int = garden_data[garden_id]["score_goal"]
	if is_tier_active(7):
		return ceili(base_goal * 1.5)
	return base_goal

func reset_pulp_stand_run_state() -> void:
	claimed_pulp_bundles.clear()
	pulp_bundle_history.clear()
	controls_reversed = false
	market_in_recession = false
	chroma_scales_enabled = true

func is_larry_class() -> bool:
	return chosen_class == "Larry"

func is_upgrade_unlocked(upgrade_key: String) -> bool:
	return get_upgrade_level_from_key(upgrade_key) > 0

func get_upgrade_max_level(upgrade_key: String) -> int:
	var upg: UpgradeData = upgrades.get(upgrade_key)
	if upg == null:
		return 0
	if upgrade_key == "Elephant Sized Portions":
		return mini(upg.max_level, max_esp_level)
	return upg.max_level

func can_receive_active_ability(ability_key: String) -> bool:
	if ability_key in ability_charges:
		return ability_charges[ability_key].total < get_upgrade_max_level(ability_key)
	return equipped_abilities.size() < max_ability_slots

func spend_pulp(amount: int) -> bool:
	if pulp < amount:
		return false
	pulp -= amount
	pulp_changed.emit(pulp)
	return true

func record_pulp_bundle_for_stats_tab(bundle: PulpBundleData) -> void:
	claimed_pulp_bundles[bundle.id] = claimed_pulp_bundles.get(bundle.id, 0) + 1
	pulp_bundle_history.append(bundle)
	pulp_bundle_recorded.emit(bundle)

func add_upgrade_level(upgrade_key: String, delta: int) -> void:
	if delta == 0:
		return
	var max_lvl := get_upgrade_max_level(upgrade_key)

	if upgrade_key in ACTIVE_ABILITIES:
		if delta > 0:
			var current := get_upgrade_level_from_key(upgrade_key)
			var steps := mini(delta, max_lvl - current)
			for i in range(steps):
				purchase_or_upgrade_ability(upgrade_key)
		elif upgrade_key in ability_charges:
			var new_total := maxi(0, ability_charges[upgrade_key].total + delta)
			ability_charges[upgrade_key].total = new_total
			ability_charges[upgrade_key].current = mini(ability_charges[upgrade_key].current, new_total)
		return

	match upgrade_key:
		"Elephant Sized Portions":
			es_portions_level = clampi(es_portions_level + delta, 0, max_lvl)
			return
		"Mulligan Munchie":
			if delta > 0 and extra_lives_are_capped:
				return
			extra_lives = maxi(0, extra_lives + delta)
			return
		"More Mice":
			var old_lvl := more_mice_level
			more_mice_level = clampi(more_mice_level + delta, 0, max_lvl)
			max_fruits_on_screen = maxi(1, max_fruits_on_screen + (more_mice_level - old_lvl))
			return
		"3 Card Monty":
			three_card_monty_unlocked = delta > 0
			return
		"Juke N Jive":
			juke_and_jive_unlocked = delta > 0
			return

	var clean_name = upgrade_key.to_snake_case().replace("'", "").replace("-", "_")
	var var_name_level = clean_name + "_level"
	var var_name_unlocked = clean_name + "_unlocked"

	if var_name_level in self:
		set(var_name_level, clampi(get(var_name_level) + delta, 0, max_lvl))
	elif var_name_unlocked in self:
		set(var_name_unlocked, delta > 0)
	else:
		push_warning("GameManager: Unknown upgrade key '%s'" % upgrade_key)

func unlock_upgrade(upgrade_key: String) -> void:
	if not is_upgrade_unlocked(upgrade_key):
		add_upgrade_level(upgrade_key, 1)

func max_out_upgrade(upgrade_key: String) -> void:
	var max_lvl := get_upgrade_max_level(upgrade_key)
	var current := get_upgrade_level_from_key(upgrade_key)
	if max_lvl > current:
		add_upgrade_level(upgrade_key, max_lvl - current)

func modify_ability_slots(delta: int) -> void:
	max_ability_slots = maxi(0, max_ability_slots + delta)
	ability_slots_changed.emit(max_ability_slots)

func add_juice(amount: int) -> void:
	juice += amount
	if amount > 0:
		total_juice_earned_this_run += amount

func travel_back_one_garden_immediately() -> void:
	go_back_garden_requested.emit()

func apply_reverse_controls() -> void:
	controls_reversed = true

func trigger_market_recession() -> void:
	market_in_recession = true
	market_recession_changed.emit(true)
