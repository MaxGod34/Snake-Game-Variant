extends CanvasLayer

signal upgrade_selected(upgrade_name)
signal resume_game_pressed



func _on_resume_button_pressed() -> void:
	emit_signal("resume_game_pressed")


func _on_speed_upgrade_button_pressed() -> void:
	if GameManager.skill_points > 0:
		GameManager.skill_points -= 1
		emit_signal("upgrade_selected", "increase_speed")

func _on_fruit_reward_upgrade_button_pressed() -> void:
	if GameManager.skill_points > 0 and GameManager.fruit_reward < 11:
		GameManager.skill_points -= 1	#subtract skill point cost
		emit_signal("upgrade_selected", "increase_fruit_reward")

func update_all_displays():
	# main refresh function
	update_skill_points()
	update_speed_indicator()
	update_fruit_reward_indicator()
	update_max_fruits_indicator()
func update_skill_points():
	var current_sp = GameManager.skill_points
	$CenterContainer/PanelContainer/VBoxContainer/HBoxContainerTopRow/SkillPointLabel\
	.text = "Skill Points Available: " + str(current_sp)
func update_speed_indicator():
	var current_level = GameManager.speed_upgrade_level
	var filled_color = Color.LIME_GREEN
	var empty_color = Color.DIM_GRAY
	
	for i in range(1, 11):
		var block = get_node("CenterContainer/PanelContainer/VBoxContainer/SpeedUpgradeRow/SpeedIndicatorContainer/Block" + str(i))
		
		if i <= current_level:
			block.color = filled_color
		else:
			block.color = empty_color
	# Disable the button after it is maxed out
	var button = get_node("CenterContainer/PanelContainer/VBoxContainer/SpeedUpgradeRow/SpeedUpgradeButton")
	button.disabled = (current_level >= 10)
func update_fruit_reward_indicator():
	var visual_level = GameManager.fruit_reward - 1
	var container = get_node("CenterContainer/PanelContainer/VBoxContainer/FruitUpgradeRow/FruitIndicatorContainer")
	# iterate through and set each color
	for i in range(1, 11):
		var block = container.get_node("Block" + str(i))
		if i <= visual_level:
			block.color = Color.RED
		else:
			block.color = Color.DIM_GRAY
	# Disable the button after it is maxed out
	var button = get_node("CenterContainer/PanelContainer/VBoxContainer/FruitUpgradeRow/FruitRewardUpgradeButton")
	button.disabled = (GameManager.fruit_reward >= 11)
func update_max_fruits_indicator():
	var visual_level = GameManager.max_fruits_on_screen - 1
	var container = get_node("CenterContainer/PanelContainer/VBoxContainer/MaxFruitsUpgradeRow/MaxFruitsIndicatorContainer")
	for i in range(1, 11):
		var block = container.get_node("Block" + str(i))
		if i <= visual_level:
			block.color = Color.hex(0xfcc4b0) #fcc4b0 color hex
		else:
			block.color = Color.DIM_GRAY
	var button = get_node("CenterContainer/PanelContainer/VBoxContainer/MaxFruitsUpgradeRow/MaxFruitsButton")
	button.disabled = GameManager.max_fruits_on_screen >= 10


func _on_max_fruits_button_pressed() -> void:
	if GameManager.skill_points >= 2:
		GameManager.skill_points -= 2
		emit_signal("upgrade_selected", "increase_max_fruits")
