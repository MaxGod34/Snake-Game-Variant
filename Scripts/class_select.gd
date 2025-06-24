extends CanvasLayer

#------On button press--------#
func _on_speedster_button_pressed() -> void:
	GameManager.chosen_class = "speedster"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_warlock_button_pressed() -> void:
	GameManager.chosen_class = "warlock"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_inchworm_button_pressed() -> void:
	GameManager.chosen_class = "inchworm"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_phoenix_coil_button_pressed() -> void:
	GameManager.chosen_class = "phoenix_coil"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_sidewinder_button_pressed() -> void:
	GameManager.chosen_class = "sidewinder"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_zealot_button_pressed() -> void:
	GameManager.chosen_class = "the_zealot"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_alchemist_button_pressed() -> void:
	GameManager.chosen_class = "the_alchemist"
	SceneTransition.transition_to("res://Scenes/Menus/difficulty_select.tscn")
func _on_back_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn")

#----------____________----------------_____________--------------______________----------------#

#---------Description Pop-up Text-----#
func _on_speedster_button_mouse_entered() -> void:
	var speedster_data = GameManager.class_data["speedster"]
	var description = speedster_data["description"]
	$DescriptionLabel.text = description
func _on_speedster_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_warlock_button_mouse_entered() -> void:
	var warlock_data = GameManager.class_data["warlock"]
	var description = warlock_data["description"]
	$DescriptionLabel.text = description
func _on_warlock_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_inchworm_button_mouse_entered() -> void:
	var inchworm_data = GameManager.class_data["inchworm"]
	var description = inchworm_data["description"]
	$DescriptionLabel.text = description
func _on_inchworm_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_phoenix_coil_button_mouse_entered() -> void:
	var coil_data = GameManager.class_data["phoenix_coil"]
	var description = coil_data["description"]
	$DescriptionLabel.text = description
func _on_phoenix_coil_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_sidewinder_button_mouse_entered() -> void:
	var sidewinder_data = GameManager.class_data["sidewinder"]
	var description = sidewinder_data["description"]
	$DescriptionLabel.text = description
func _on_sidewinder_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_zealot_button_mouse_entered() -> void:
	var zealot_data = GameManager.class_data["the_zealot"]
	var description = zealot_data["description"]
	$DescriptionLabel.text = description
func _on_zealot_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_alchemist_button_mouse_entered() -> void:
	var alc_data = GameManager.class_data["the_alchemist"]
	var description = alc_data["description"]
	$DescriptionLabel.text = description
func _on_alchemist_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
func _on_back_button_mouse_entered() -> void:
	$DescriptionLabel.text = "Slither away back to the Main Menu...\n\nWhile you can!"
func _on_back_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
