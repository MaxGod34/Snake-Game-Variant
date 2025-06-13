extends CanvasLayer

signal quit_to_menu_pressed
signal restart_pressed

func _on_button_pressed() -> void:
	emit_signal("restart_pressed")

func on_game_over(final_score):
	self.visible = true
	$ScoreLabel.text = "Score: " + str(final_score)


func _on_quit_button_pressed() -> void:
	emit_signal("quit_to_menu_pressed")
