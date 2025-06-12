extends CanvasLayer

func _on_easy_button_pressed() -> void:
	GameManager.chosen_difficulty = "easy"
	GameManager.go_to_scene("res://Scenes/class_select.tscn")

func _on_normal_button_pressed() -> void:
	GameManager.chosen_difficulty = "normal"
	GameManager.go_to_scene("res://Scenes/class_select.tscn")


func _on_hard_button_pressed() -> void:
	GameManager.chosen_difficulty = "hard"
	GameManager.go_to_scene("res://Scenes/class_select.tscn")


func _on_back_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/main_menu.tscn")
