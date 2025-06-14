extends CanvasLayer

signal upgrade_selected(upgrade_name)
signal resume_game_pressed

func _ready():
	# Connect all buttons to the SAME function, but pass a unique argument
	$CenterContainer/PanelContainer/VBoxContainer/SpeedUpgradeRow/SpeedUpgradeButton.pressed.connect(_on_upgrade_button_pressed.bind("increase_speed", $CenterContainer/PanelContainer/VBoxContainer/SpeedUpgradeRow/SpeedUpgradeButton))
	$CenterContainer/PanelContainer/VBoxContainer/FruitUpgradeRow/FruitRewardUpgradeButton.pressed.connect(_on_upgrade_button_pressed.bind("increase_fruit_reward", $CenterContainer/PanelContainer/VBoxContainer/FruitUpgradeRow/FruitRewardUpgradeButton))
	$CenterContainer/PanelContainer/VBoxContainer/MaxFruitsUpgradeRow/MaxFruitsButton.pressed.connect(_on_upgrade_button_pressed.bind("increase_max_fruits", $CenterContainer/PanelContainer/VBoxContainer/MaxFruitsUpgradeRow/MaxFruitsButton))
	$CenterContainer/PanelContainer/VBoxContainer/PerimeterUpgradeRow/PerimeterUpgradeButton.pressed.connect(_on_upgrade_button_pressed.bind("increase_grid_size", $CenterContainer/PanelContainer/VBoxContainer/PerimeterUpgradeRow/PerimeterUpgradeButton))
	$CenterContainer/PanelContainer/VBoxContainer/AbilityRow1/H/BurrowAbilityRow/BurrowButton.pressed.connect(_on_upgrade_button_pressed.bind("increase_burrow_charges", $CenterContainer/PanelContainer/VBoxContainer/AbilityRow1/H/BurrowAbilityRow/BurrowButton))
	$CenterContainer/PanelContainer/VBoxContainer/AbilityRow1/H/PhaseShiftAbilityRow/PhaseShiftButton.pressed.connect(_on_upgrade_button_pressed.bind("increase_phase_charges", $CenterContainer/PanelContainer/VBoxContainer/AbilityRow1/H/PhaseShiftAbilityRow/PhaseShiftButton))
	$CenterContainer/PanelContainer/VBoxContainer/AbilityRow1/H2/ExtraLifeRow/ExtraLifeButton.pressed.connect(_on_upgrade_button_pressed.bind("buy_extra_life", $CenterContainer/PanelContainer/VBoxContainer/AbilityRow1/H2/ExtraLifeRow/ExtraLifeButton))
	$CenterContainer/PanelContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)

func update_all_displays():
	update_skill_points_label()
	# We now use full, correct node paths to find each button.
	# Replace these paths with the actual paths from your scene tree!
	var vbox = $CenterContainer/PanelContainer/VBoxContainer
	update_button_display("increase_speed", vbox.get_node("SpeedUpgradeRow/SpeedUpgradeButton"), GameManager.speed_upgrade_level)
	update_button_display("increase_fruit_reward", vbox.get_node("FruitUpgradeRow/FruitRewardUpgradeButton"), GameManager.fruit_reward - 1)
	update_button_display("increase_max_fruits", vbox.get_node("MaxFruitsUpgradeRow/MaxFruitsButton"), GameManager.max_fruits_on_screen - 1)
	update_button_display("increase_grid_size", vbox.get_node("PerimeterUpgradeRow/PerimeterUpgradeButton"), GameManager.grid_size_level)
	update_button_display("increase_burrow_charges", vbox.get_node("AbilityRow1/H/BurrowAbilityRow/BurrowButton"), GameManager.burrow_level)
	update_button_display("increase_phase_charges", vbox.get_node("AbilityRow1/H/PhaseShiftAbilityRow/PhaseShiftButton"), GameManager.phase_shift_level)
	update_button_display("buy_extra_life", vbox.get_node("AbilityRow1/H2/ExtraLifeRow/ExtraLifeButton"), GameManager.extra_lives)

# A single, powerful function to update any upgrade row
func update_button_display(upgrade_key, button_node, current_level):
	var rules = GameManager.upgrade_data[upgrade_key]
	var display_name = rules["display_name"]
	# You will need an indicator container for each row.
	var indicator_container = button_node.get_parent().get_node("IndicatorContainer")

	if current_level >= rules["max_level"]:
		button_node.text = display_name + " (MAX)"
		button_node.disabled = true
	else:
		var base_cost = rules["costs"][current_level]
		var cost_modifier = GameManager.difficulty_data[GameManager.chosen_difficulty]["sp_cost_modifier"]
		var cost = base_cost + cost_modifier
		button_node.text = display_name + " (" + str(cost) + " SP)"
		button_node.disabled = false

	# Update indicator blocks
	# Ensure your max_level in the data dictionary matches the number of blocks you have.
	var max_indicator_blocks = indicator_container.get_child_count()
	for i in range(1, max_indicator_blocks + 1):
		var block = indicator_container.get_node("Block" + str(i))
		block.visible = (i <= rules["max_level"])
		if block.visible:
			block.color = Color.GOLD if i <= current_level else Color.GRAY


func update_skill_points_label():
	# Make sure this path is correct for your scene!
	$CenterContainer/PanelContainer/VBoxContainer/HBoxContainerTopRow/SkillPointLabel.text = "Skill Points Available: " + str(GameManager.skill_points)

func _on_resume_button_pressed():
	emit_signal("resume_game_pressed")

# A single, powerful function to handle any button press
func _on_upgrade_button_pressed(upgrade_key, button_node):
	var current_level # Get the correct level to check against
	if upgrade_key == "increase_fruit_reward": current_level = GameManager.fruit_reward - 1
	elif upgrade_key == "increase_max_fruits": current_level = GameManager.max_fruits_on_screen - 1
	elif upgrade_key == "increase_grid_size": current_level = GameManager.grid_size_level
	elif upgrade_key == "increase_burrow_charges": current_level = GameManager.burrow_level
	elif upgrade_key == "increase_phase_charges": current_level = GameManager.phase_shift_level
	elif upgrade_key == "buy_extra_life": current_level = GameManager.extra_lives
	else: current_level = GameManager.speed_upgrade_level

	var rules = GameManager.upgrade_data[upgrade_key]
	if current_level < rules["max_level"]:
		var base_cost = rules["costs"][current_level]
		var cost_modifier = GameManager.difficulty_data[GameManager.chosen_difficulty]["sp_cost_modifier"]
		var cost = base_cost + cost_modifier
		if GameManager.skill_points >= cost:
			GameManager.skill_points -= cost
			emit_signal("upgrade_selected", upgrade_key)
			if is_instance_valid(button_node):
				button_node.release_focus()
			update_all_displays() # Refresh UI immediately after purchase
