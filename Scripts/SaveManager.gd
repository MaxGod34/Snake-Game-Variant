extends Node

# This is the master dictionary that will hold all our persistent data.
var save_data = {}

# This is the path to our save file.
const SAVE_PATH = "user://savegame.json"

func _ready():
	# When the game first boots up, we immediately try to load any existing save data.
	save_data = _get_default_save_data()
	load_game()

func _get_default_save_data() -> Dictionary:
	return {
		# --- Player Career Progression --- #
		"player_xp": 0,
		"player_level": 1,
		"garden_master_rank": 0,
		# --- Currencies & Unlocks --- #
		"serpent_fangs": 0,
		"unlocked_classes": ["Mulligan", "Ghost", "Tycoon", "Doubles", "Gobble"],
		"unlocked_cosmetics": {
			"colors": ["Default White", "Default Purple", "Default Lime"],
			"patterns": ["Default"],
			"backgrounds": ["Default"],
			"avatars": ["Default"],
			"frames": ["Default"],
			"banners": ["Default"]
		},
		"equipped_cosmetics": {
			"head_color": "Default Lime",
			"body_colors": ["Default Purple", null, null, null, null],
			"pattern": "Default",
			"background": "Default",
			"avatar": "Default",
			"frame": "Default",
			"banner": "Default"
		},
		# --- {er-Class Difficulty Progression ---
		"class_progression": {},
		# --- Career Statistics & Milestones ---
		"high_score": 0,
		"total_pulp_earned": 0,
		"total_juice_earned": 0,
		"milestone_progress": {
			"total_deaths": 0,
			"upgrades_purchased": 0,
			"highest_garden_reached": 0,
			"prestiges_completed": 0,
			"rocks_destroyed": 0,
			"combos_achieved": 0
		},
		"unlocked_milestones": []
	}

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
	save_data = _get_default_save_data()
	save_game()
	print("Save data has been reset to default.")

func get_progress_for_class(class_key: String) -> Dictionary:
	if not save_data.class_progression.has(class_key):
		save_data.class_progression[class_key] = {
			"cleared_tiers": []
		}
	elif not save_data.class_progression[class_key].has("cleared_tiers"):
		save_data.class_progression[class_key]["cleared_tiers"] = []
	return save_data.class_progression[class_key]

func record_end_of_run(did_win: bool, final_score: int, total_pulp: int, upgrades_bought: int) -> Dictionary:
	var class_key = GameManager.chosen_class
	var diff_key = GameManager.chosen_difficulty
	var fangs_earned: int = 0
	var is_new_high_score: bool = final_score > save_data.high_score

	if is_new_high_score:
		save_data.high_score = final_score

	if did_win:
		var progress = get_progress_for_class(class_key)
		var tier: int = GameManager.current_difficulty_tier
		var cleared_tiers: Array = progress["cleared_tiers"]

		if not (tier in cleared_tiers):
			cleared_tiers.append(tier)
			fangs_earned = get_first_clear_fang_reward(tier)
			save_data.serpent_fangs += fangs_earned

		if GameManager.new_game_s_plus_active:
			save_data.milestone_progress.prestiges_completed += 1
	else:
		save_data.milestone_progress.total_deaths += 1

	# Quietly keep career stats updated for The Shed
	save_data.total_pulp_earned += total_pulp
	save_data.total_juice_earned += GameManager.total_juice_earned_this_run
	save_data.milestone_progress.upgrades_purchased += upgrades_bought
	save_data.milestone_progress.rocks_destroyed += GameManager.rocks_destroyed_this_run
	if GameManager.current_garden > save_data.milestone_progress.highest_garden_reached:
		save_data.milestone_progress.highest_garden_reached = GameManager.current_garden

	save_game()

	return {
		"did_win": did_win,
		"class_key": class_key,
		"difficulty_key": diff_key,
		"garden_reached": GameManager.current_garden,
		"garden_name": GameManager.garden_data[GameManager.current_garden]["name"],
		"final_score": final_score,
		"run_time": GameManager.run_time,
		"fangs_earned": fangs_earned,
		"is_new_high_score": is_new_high_score
	}



func _check_for_new_milestones() -> Array:
	var newly_unlocked = []
	
	# Loop through every type of milestone defined in our rulebook.
	for stat_key in GameManager.milestone_data:
		var milestone = GameManager.milestone_data[stat_key]
		var player_progress = save_data.milestone_progress.get(stat_key, 0)
		
		# Loop through each tier of that milestone.
		for tier in milestone.tiers:
			var tier_key = tier.key
			
			# Check two things:
			# 1. Has the player met the goal?
			# 2. Have they NOT already unlocked this specific tier?
			if player_progress >= tier.goal and not tier_key in save_data.unlocked_milestones:
				# UNLOCK!
				print("MILESTONE UNLOCKED: ", tier_key)
				save_data.serpent_fangs += tier.reward
				save_data.unlocked_milestones.append(tier_key)
				
				# Add it to the list to be displayed on the UI
				newly_unlocked.append({
					"name": milestone.display_name,
					"tier": tier.key, # e.g. "deaths_1"
					"reward": tier.reward,
					"icon_path": milestone.get("icon_path", "")
				})
				
	return newly_unlocked



func _get_garden_completion_bonus() -> int:
	var garden_reached = GameManager.current_garden
	if garden_reached >= 10:
		return 200 * garden_reached
	elif garden_reached >= 7:
		return 150 * garden_reached
	elif garden_reached >= 4:
		return 100 * garden_reached
	elif garden_reached >= 1:
		return 50 * (garden_reached - 1)
	
	return 0 # Default case



func get_xp_for_level(p_level: int) -> int:
	# This is the same elegant formula from our previous design.
	if p_level <= 100:
		return 100 + ((p_level - 1) * 25)
	else:
		# After level 100, the cost gets much higher for prestige "Garden Master" ranks.
		return 2600 + ((p_level - 100) * 100)


func get_difficulty_xp_multiplier(difficulty_key: String) -> float:
	var diff_data = GameManager.difficulty_data.get(difficulty_key)
	return diff_data.xp_multiplier if diff_data else 1.0


func get_first_clear_fang_reward(tier: int) -> int:
	return clampi(50 + (tier * 50), 50, 500)
