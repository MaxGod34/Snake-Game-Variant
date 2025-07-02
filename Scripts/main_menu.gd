extends CanvasLayer




func _on_play_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/selection_screen.tscn")


func _on_options_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/options_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_the_pit_button_pressed() -> void:
	pass # for now
