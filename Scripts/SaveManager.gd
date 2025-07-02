extends Node

# This is the master dictionary that will hold all our persistent data.
var save_data = {

	# --- Statistics ---
	"high_score": 0,
	"total_pulp_earned": 0,
	"total_juice_earned": 0,
	"total_deaths": 0,
	"serpent_skulls": 0,
	
	# --- Unlocks ---
	"unlocked_classes": ["Mulligan", "Tycoon", "Ghost", "Doubles", "Gobble"], # Start with the base classes
	"unlocked_cosmetics": [],
	
	"class_progression": {}
}

# This is the path to our save file.
const SAVE_PATH = "user://savegame.json"

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
	# This function loads the data from our file.
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Using default data.")
		return # If no save file exists, we just use the default values.
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	
	# We parse the text from the file.
	var parse_error = json.parse(file.get_as_text())
	if parse_error != OK:
		print("Error parsing save file: ", json.get_error_message())
		return
		
	# If successful, we overwrite our default data with the loaded data.
	var loaded_data = json.data
	for key in save_data:
		if loaded_data.has(key):
			save_data[key] = loaded_data[key]
			
	print("Save file loaded successfully!")

func reset_save_data():
	# This function simply resets the save_data dictionary back to its original, default state.
	save_data = {
		"high_score": 0,
		"total_pulp_earned": 0,
		"total_juice_earned": 0,
		"total_deaths": 0,
		"unlocked_classes": ["Mulligan", "Tycoon", "Ghost", "Doubles", "Gobble"],
		"unlocked_cosmetics": [],
		"class_progression": {}
	}
	# After resetting, we immediately save the new, empty data to the file.
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
