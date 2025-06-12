extends CanvasLayer


signal continue_pressed

func setup(garden_name, score, is_final_garden, is_final_win):
	$CenterContainer/PanelContainer/VBoxContainer/StatsLabel\
	.text = "You cleared the %s with a score of %s!" % [garden_name, score]
	if is_final_win:
		$CenterContainer/PanelContainer/VBoxContainer/TitleLabel\
		.text = "YOU ARE A SNAKE GOD!"
		$CenterContainer/PanelContainer/VBoxContainer/ContinueButton\
		.text = "Return to Menu"
	elif is_final_garden:
		$CenterContainer/PanelContainer/VBoxContainer/TitleLabel\
		.text = "Final Garden Complete!"
		$CenterContainer/PanelContainer/VBoxContainer/ContinueButton\
		.text = "Finish"

	


func _on_continue_button_pressed() -> void:
	emit_signal("continue_pressed")
