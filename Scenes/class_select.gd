extends CanvasLayer




func _on_speedster_button_pressed() -> void:
	GameManager.chosen_class = "speedster"
	GameManager.start_game()


func _on_warlock_button_pressed() -> void:
	GameManager.chosen_class = "warlock"
	GameManager.start_game()


func _on_inchworm_button_pressed() -> void:
	GameManager.chosen_class = "inchworm"
	GameManager.start_game()


func _on_back_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/difficulty_select.tscn")
