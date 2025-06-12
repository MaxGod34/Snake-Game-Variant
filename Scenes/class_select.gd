extends CanvasLayer

#------On button press--------#
func _on_speedster_button_pressed() -> void:
	GameManager.chosen_class = "speedster"
	GameManager.go_to_scene("res://Scenes/difficulty_select.tscn")
func _on_warlock_button_pressed() -> void:
	GameManager.chosen_class = "warlock"
	GameManager.go_to_scene("res://Scenes/difficulty_select.tscn")
func _on_inchworm_button_pressed() -> void:
	GameManager.chosen_class = "inchworm"
	GameManager.go_to_scene("res://Scenes/difficulty_select.tscn")
func _on_back_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/main_menu.tscn")

#---------Description Pop-up Text-----#
func _on_speedster_button_mouse_entered() -> void:
	var speedster_data = GameManager.class_data["speedster"]
	var description = "%s Modifiers:\nStart Length: %s\nStart Speed: %s\nStart Fruit Reward: %s\nStart Max Fruits: %s\nSpeed Upgrade Mod: %sx\nReward Upgrade Mod: %sx" % \
	[speedster_data["name"], speedster_data["start_length"], speedster_data["start_speed"], speedster_data["start_fruit_reward"], speedster_data["start_max_fruits"], speedster_data["speed_upgrade_mod"], speedster_data["reward_upgrade_mod"]]
	$DescriptionLabel.text = description
func _on_speedster_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_warlock_button_mouse_entered() -> void:
	var warlock_data = GameManager.class_data["warlock"]
	var description = "%s Modifiers:\nStart Length: %s\nStart Speed: %s\nStart Fruit Reward: %s\nStart Max Fruits: %s\nSpeed Upgrade Mod: %sx\nReward Upgrade Mod: %sx" % \
	[warlock_data["name"], warlock_data["start_length"], warlock_data["start_speed"], warlock_data["start_fruit_reward"], warlock_data["start_max_fruits"], warlock_data["speed_upgrade_mod"], warlock_data["reward_upgrade_mod"]]
	$DescriptionLabel.text = description
func _on_warlock_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_inchworm_button_mouse_entered() -> void:
	var inchworm_data = GameManager.class_data["inchworm"]
	var description = "%s Modifiers:\nStart Length: %s\nStart Speed: %s\nStart Fruit Reward: %s\nStart Max Fruits: %s\nSpeed Upgrade Mod: %sx\nReward Upgrade Mod: %sx" % \
	[inchworm_data["name"], inchworm_data["start_length"], inchworm_data["start_speed"], inchworm_data["start_fruit_reward"], inchworm_data["start_max_fruits"], inchworm_data["speed_upgrade_mod"], inchworm_data["reward_upgrade_mod"]]
	$DescriptionLabel.text = description
func _on_inchworm_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
