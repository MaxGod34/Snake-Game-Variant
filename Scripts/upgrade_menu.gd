extends CanvasLayer

signal upgrade_selected(upgrade_name)
signal resume_game_pressed



func _on_resume_button_pressed() -> void:
	emit_signal("resume_game_pressed")


func _on_speed_upgrade_button_pressed() -> void:
	if GameManager.skill_points > 0:
		GameManager.skill_points -= 1
		emit_signal("upgrade_selected", "increase_speed")

func update_skill_points():
	var current_sp = GameManager.skill_points
	$CenterContainer/PanelContainer/VBoxContainer/HBoxContainerTopRow/SkillPointLabel\
	.text = "Skill Points Available: " + str(current_sp)
