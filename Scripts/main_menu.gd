extends CanvasLayer


func _on_play_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/difficulty_select.tscn")


func _on_options_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/options_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
