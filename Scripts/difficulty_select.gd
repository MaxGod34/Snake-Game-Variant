extends CanvasLayer



func _on_normal_button_pressed() -> void:
	GameManager.current_difficulty = "normal"
	GameManager.start_game()


func _on_hard_button_pressed() -> void:
	GameManager.current_difficulty = "hard"
	GameManager.start_game()


func _on_back_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/main_menu.tscn")
