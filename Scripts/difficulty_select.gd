extends CanvasLayer
#---------BUTTON PRESS--------#
func _on_hatchling_button_pressed() -> void:
	GameManager.chosen_difficulty = "hatchling"
	GameManager.start_game()
func _on_viper_button_pressed() -> void:
	GameManager.chosen_difficulty = "viper"
	GameManager.start_game()
func _on_basilisk_button_pressed() -> void:
	GameManager.chosen_difficulty = "basilisk"
	GameManager.start_game()
func _on_back_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/class_select.tscn")

func _ready() -> void:
	$ClassInfoLabel.text = "Class: " + GameManager.chosen_class.capitalize()
#-----------BUTTON HOVER DESCRIPTION--------#
func _on_basilisk_button_mouse_entered() -> void:
	var basilisk_data = GameManager.difficulty_data["basilisk"]
	
	# Build a descriptive, multi-line string. The '\n' creates a new line.
	var description = "Speed: %sx\nScore Goals: %sx\nJuice Cost Modifier (+/-): %s\nStarting Juice: %smL" % [basilisk_data["speed_multiplier"], basilisk_data["goal_multiplier"], basilisk_data["juice_cost_modifier"], basilisk_data["starting_juice"]]
	
	# Set the label's text
	$DescriptionLabel.text = description
func _on_basilisk_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_viper_button_mouse_entered() -> void:
	var viper_data = GameManager.difficulty_data["viper"]
	var description = "Speed: %sx\nScore Goals: %sx\nJuice Cost Modifier (+/-): %s\nStarting Juice: %smL" % [viper_data["speed_multiplier"], viper_data["goal_multiplier"], viper_data["juice_cost_modifier"], viper_data["starting_juice"]]
	$DescriptionLabel.text = description
func _on_viper_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_hatchling_button_mouse_entered() -> void:
	var hatchling_data = GameManager.difficulty_data["hatchling"]
	var description = "Speed: %sx\nScore Goals: %sx\nJuice Cost Modifier (+/-): %s\nStarting Juice: %smL" % [hatchling_data["speed_multiplier"],hatchling_data["goal_multiplier"], hatchling_data["juice_cost_modifier"], hatchling_data["starting_juice"]]
	$DescriptionLabel.text = description
func _on_hatchling_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
