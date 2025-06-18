extends CanvasLayer




func _on_play_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/class_select.tscn")


func _on_options_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/options_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
