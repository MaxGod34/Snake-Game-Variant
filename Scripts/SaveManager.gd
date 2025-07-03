extends Node

# This is the master dictionary that will hold all our persistent data.
var save_data = {
	# --- Player Career Progression ---
	"player_xp": 0,
	"player_level": 1,
	"garden_master_rank": 0, # The "Prestige" level
	
	# --- Currencies & Unlocks ---
	"serpent_fangs": 0,
	"unlocked_classes": ["Mulligan", "Ghost", "Tycoon", "Doubles", "Gobble"],
	"unlocked_cosmetics": {
		"colors": [],"patterns": [],"backgrounds": [],"avatars": [],"frames": []
	},
	"equipped_cosmetics": {
		"color_1": "#FFFFFF",
		"color_2": "#888888",
		"pattern": "None",
		"background": "Default",
		"avatar": "Default",
		"frame": "Default"
	},
	# --- Per-Class Difficulty Progression ---
	"class_progression": {},
	# --- Career Statistics & Milestone ---
	"high_score": 0,
	"total_pulp_earned": 0,
	"total_juice_earned": 0,
	"total_deaths": 0,
	"milestone_progress": {
		"rocks_destroyed": 0,
		"total_upgrades_purchased": 0,
		"combos_achieved": 0,
	}
}

# This is the path to our save file.
const SAVE_PATH = "user://savegame_v2.json"

func _ready():
	# When the game first boots up, we immediately try to load any existing save data.
	load_game()

func save_game():
	# This function saves the current state of our save_data to a file.
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	# We convert our dictionary to a JSON string, which is a clean, human-readable format.
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	print("Game Saved!")

func load_game():
	# This function now safely loads data and handles potential corruption.
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Using default data.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	
	var parse_error = json.parse(file.get_as_text())
	if parse_error != OK:
		print("Error parsing save file: ", json.get_error_message())
		return
		
	var loaded_data = json.data
	

	# Instead of blindly overwriting, we now check each key.
	for key in save_data:
		if loaded_data.has(key):
			# Special check for our nested dictionary to prevent corruption.
			if key == "unlocked_cosmetics" and typeof(loaded_data[key]) == TYPE_DICTIONARY:
				save_data[key] = loaded_data[key]
			elif key != "unlocked_cosmetics":
				save_data[key] = loaded_data[key]
			
	print("Save file loaded successfully!")

func reset_save_data():
	save_data = {
		"player_xp": 0,
		"player_level": 1,
		"garden_master_rank": 0,
		"serpent_fangs": 0,
		"unlocked_classes": ["Mulligan", "Ghost", "Tycoon", "Doubles", "Gobble"],
		"unlocked_cosmetics": {
			"colors": [], "patterns": [], "backgrounds": [], "avatars": [], "frames": []
		},
		"equipped_cosmetics": {
			"color_1": "#FFFFFF",
			"color_2": "#888888",
			"pattern": "None",
			"background": "Default",
			"avatar": "Default",
			"frame": "Default"
		},
		"class_progression": {},
		"high_score": 0,
		"total_pulp_earned": 0,
		"total_juice_earned": 0,
		"total_deaths": 0,
		"milestone_progress": { "rocks_destroyed": 0, "total_upgrades_purchased": 0, "combos_achieved": 0 }
	}
	save_game()
	print("Save data has been reset to default.")

func get_progress_for_class(class_key: String) -> Dictionary:
	# Check if we already have a save entry for this class.
	if not save_data.class_progression.has(class_key):
		# If not, create a new, default entry for it.
		save_data.class_progression[class_key] = {
			"highest_pact_completed": 0,
			"seals_broken": [],
			"highest_cursed_pact_completed": 0
		}
	return save_data.class_progression[class_key]

func process_end_of_run_xp(p_total_score: int, p_total_pulp: int, p_difficulty_key: String):
	# 1. Update all our career stat totals with the data from the completed run.
	save_data.total_juice_earned += GameManager.total_juice_earned_this_run
	save_data.total_pulp_earned += GameManager.total_pulp_earned_this_run
	save_data.milestone_progress.rocks_destroyed += GameManager.rocks_destroyed_this_run
	save_data.milestone_progress.total_upgrades_purchased += GameManager.upgrades_purchased_this_run
	
	# 2. Calculate the XP earned this run using our new formula.
	var base_xp = p_total_score
	var pulp_bonus = p_total_pulp * 0.5
	var capped_pulp_bonus = min(pulp_bonus, p_total_score)
	
	var difficulty_multiplier = get_difficulty_xp_multiplier(p_difficulty_key)
	var final_xp_gained = (base_xp + capped_pulp_bonus) * difficulty_multiplier
	
	# 3. Add the earned XP to our persistent total.
	save_data.player_xp += floori(final_xp_gained)
	print("Player earned %s XP this run!" % floori(final_xp_gained))
	
	# 4. Check if the player has leveled up.
	check_for_level_up()
	
	# 5. Finally, save all the new data.
	save_game()

func get_xp_for_next_level() -> int:
	if save_data.garden_master_rank > 0:
		# Prestige levels require a massive, flat amount of XP.
		return 1000000 # Example high number
	else:
		# Normal levels use a smooth exponential curve.
		return floori(100 * pow(1.15, save_data.player_level))

func check_for_level_up():
	var xp_needed = get_xp_for_next_level()
	
	# We use a while loop in case the player gained enough XP for multiple levels.
	while save_data.player_xp >= xp_needed:
		# Subtract the XP cost for the level.
		save_data.player_xp -= xp_needed
		
		if save_data.player_level < 100:
			save_data.player_level += 1
			save_data.serpent_fangs += 10 # Reward for a normal level
			print("LEVEL UP! Reached Level %s." % save_data.player_level)
		else:
			# We've hit the prestige ranks!
			save_data.garden_master_rank += 1
			save_data.serpent_fangs += 100 # A much bigger reward for a Master rank
			print("GARDEN MASTER! Reached Master Rank %s." % save_data.garden_master_rank)
			
		# Recalculate the XP needed for the *next* level.
		xp_needed = get_xp_for_next_level()

func get_difficulty_xp_multiplier(difficulty_key: String) -> float:
	var diff_data = GameManager.difficulty_data.get(difficulty_key)
	if not diff_data: return 1.0 # Safety default

	# We can add a "multiplier" key to our difficulty data to make this cleaner.
	# For now, we can use a match statement.
	if difficulty_key.begins_with("Pact"):
		var pact_number = int(difficulty_key.split(" ")[1])
		# Linearly scale from 0.5x to 0.9x for Pacts 1-5
		return lerp(0.5, 0.9, float(pact_number - 1) / 4.0)
		
	elif difficulty_key.begins_with("Trial"):
		return 1.5
		
	elif difficulty_key.begins_with("Cursed"):
		var cursed_pact_number = GameManager.roman_to_int(difficulty_key.split(" ")[2])
		match cursed_pact_number:
			1: return 2.0
			2: return 2.5
			3: return 3.0
			4: return 4.0
			5: return 5.0
			
	return 1.0 # Default multiplier
