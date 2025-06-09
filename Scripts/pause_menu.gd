extends CanvasLayer

signal resume_game
signal quit_to_menu

func _on_resume_button_pressed() -> void:
	emit_signal("resume_game")



func display_score(current_score):
	$CenterContainer/PanelContainer/VBoxContainer/ScoreLabel.text = "Score: " + str(current_score)


func _on_quit_button_pressed() -> void:
	emit_signal("quit_to_menu")


func _on_options_button_pressed() -> void:
	$CenterContainer/PanelContainer/VBoxContainer.visible = false
	$OptionsMenuPanel.visible = true


func _on_options_menu_panel_back_pressed() -> void:
	$OptionsMenuPanel.visible = false
	$CenterContainer/PanelContainer/VBoxContainer.visible = true
