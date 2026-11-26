extends Control

# --- NODE REFERENCES ---
# We get direct references to our main containers and buttons.
# Double-check that these paths are a perfect match for the scene tree.
@onready var category_list_vbox = $MarginContainer/VBoxContainer/ShedTabs/Customization/CategoryListPanel/VBoxContainer
@onready var back_button = $MarginContainer/VBoxContainer/BottomHUDRow/BackButton
# --- Page Containers ---
# We get references to each of our "page" containers.
@onready var chroma_palette_page = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ChromaPalettePage
@onready var backgrounds_page = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/BackgroundsPage
@onready var avatars_page = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/AvatarsPage
@onready var frames_page = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/FramesPage
@onready var banners_page = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/BannersPage

# --- Stats Labels --- 
@onready var high_score_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/HighScoreLabel"
@onready var total_deaths_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/TotalDeathsLabel"
@onready var player_rank_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/PlayerRankLabel"
@onready var total_juice_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/TotalJuiceLabel"
@onready var total_pulp_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/TotalPulpLabel"
@onready var rocks_destroyed_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/RocksDestroyedLabel"
@onready var prestiges_completed_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/PrestigesCompletedLabel"
@onready var total_upgrades_purchased_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/TotalUpgradesPurchasedLabel"
@onready var total_cosmetics_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/TotalCosmeticsLabel"
@onready var total_combos_label = $"MarginContainer/VBoxContainer/ShedTabs/Career Stats/HBoxContainer/VBoxContainer/TotalCombosLabel"
# --- Milestones Stuff ---
@onready var milestones_list_container = $MarginContainer/VBoxContainer/ShedTabs/Milestones/MilestoneList
# This variable will store which category is currently being displayed.
var current_category: String = "Chroma Palette" # Default to the first category

var active_color_slot_index: int = -1 # -1 for head, 0-4 for body

func _ready():
	# When the screen is ready, we connect all the signals.
	_connect_all_signals()
	update_career_stats_tab()
	update_milestones_tab()
	_on_category_button_pressed("ChromaPalette")

func _enter_tree() -> void:
	call_deferred("update_all_displays")

func _connect_all_signals():
	# Connect the back button to go back to the main menu.
	back_button.pressed.connect(func(): SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn"))
	
	# Loop through all the category buttons and connect them.
	for button in category_list_vbox.get_children():
		if button is Button:
			var category_name = button.name.trim_suffix("Button")
			button.pressed.connect(_on_category_button_pressed.bind(category_name))
			
	_connect_equipped_nodes(chroma_palette_page)
	_connect_equipped_nodes(backgrounds_page)
	_connect_equipped_nodes(avatars_page)
	_connect_equipped_nodes(frames_page)
	_connect_equipped_nodes(banners_page)

func _connect_equipped_nodes(page_node: Control):
	var row1 = page_node.find_child("EquippedCosmeticsRow")
	var row2 = page_node.find_child("EquippedCosmeticsRow2")
	if not is_instance_valid(row1) or not is_instance_valid(row2): return
	
	# Connect the color swatches
	row2.get_node("EquippedHeadColorNode").pressed.connect(_on_color_slot_selected.bind(-1))
	row2.get_node("EquippedHeadColorNode").get_child(0).visible = false
	for i in range(5):
		var node = row2.get_node("EquippedBodyColor" + str(i + 1) + "Node")
		node.pressed.connect(_on_color_slot_selected.bind(i))
		node.get_node("IndicatorContainer").visible = false

func _on_category_button_pressed(category_name: String):
	current_category = category_name
	
	chroma_palette_page.visible = (category_name == "ChromaPalette")
	backgrounds_page.visible = (category_name == "Backgrounds")
	avatars_page.visible = (category_name == "Avatars")
	frames_page.visible = (category_name == "Frames")
	banners_page.visible = (category_name == "Banners")
			
	update_all_displays()

func update_all_displays():
	update_career_stats_tab()
	update_milestones_tab()
	match current_category:
		"ChromaPalette": update_chroma_palette_page()
		"Backgrounds": update_simple_grid("Backgrounds", backgrounds_page.find_child("BackgroundGrid"))
		"Avatars": update_simple_grid("Avatars", avatars_page.find_child("AvatarGrid"))
		"Frames": update_simple_grid("Frames", frames_page.find_child("FrameGrid"))
		"Banners": update_simple_grid("Banners", banners_page.find_child("BannerGrid"))


func update_chroma_palette_page():
	# 1. Update the "Equipped" display for THIS page.
	var equipped_row_1 = chroma_palette_page.find_child("EquippedCosmeticsRow")
	var equipped_row_2 = chroma_palette_page.find_child("EquippedCosmeticsRow2")
	update_equipped_display(equipped_row_1, equipped_row_2)
	
	_populate_grid_from_data("Patterns", chroma_palette_page.find_child("PatternGrid"))
	_populate_grid_from_data("Colors", chroma_palette_page.find_child("ColorGrid"))

func update_simple_grid(category_key: String, grid_node: GridContainer):
	var page_node = grid_node.get_parent().get_parent()
	var equipped_row_1 = page_node.find_child("EquippedCosmeticsRow")
	var equipped_row_2 = page_node.find_child("EquippedCosmeticsRow2")
	update_equipped_display(equipped_row_1, equipped_row_2)
	
	_populate_grid_from_data(category_key, grid_node)


func _populate_grid_from_data(category_key: String, grid_node: GridContainer):
	for child in grid_node.get_children():
		child.queue_free()
		
	var unlocked_items = SaveManager.save_data.unlocked_cosmetics.get(category_key.to_lower(), [])
	var all_item_data = GameManager.cosmetic_data.get(category_key, {})
	
	for item_key in all_item_data:
		var node = preload("res://Scenes/UI/upgrade_node.tscn").instantiate()
		var rules = all_item_data[item_key]
		
		var is_unlocked = item_key in unlocked_items
		var is_equipped = (SaveManager.save_data.equipped_cosmetics.get(category_key.to_lower()) == item_key)
		
		# --- Set the Icon and Color ---
		if rules.has("hex_code"):
			node.icon = preload("res://Assets/Icons/white_swatch.png")
			node.modulate = Color(rules.hex_code)
		else:
			var icon_path = rules.get("icon_path", "")
			if ResourceLoader.exists(icon_path):
				node.icon = load(icon_path)
			node.modulate = Color.WHITE

		# --- Set the Border Style ---
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.bg_color = Color(0,0,0,0.3)
		stylebox.border_color = Color.GOLD if is_equipped else Color.TRANSPARENT
		node.add_theme_stylebox_override("normal", stylebox)
		
		# --- Set the Disabled State ---
		node.disabled = not is_unlocked
		if not is_unlocked:
			node.modulate = Color(node.modulate.r, node.modulate.g, node.modulate.b, 0.2)
		
		# Connect the correct signal based on the category
		if category_key == "Colors":
			node.pressed.connect(_on_equip_color_pressed.bind(item_key))
		else:
			node.pressed.connect(_on_equip_item_pressed.bind(category_key, item_key))
		
		grid_node.add_child(node)
		grid_node.update_minimum_size()

		

func _on_equip_item_pressed(category: String, item_key: String):
	print("Equipping %s for category %s" % [item_key, category])
	
	# use a match statement to get the correct, SINGULAR key for our save data.
	var category_save_key = ""
	match category:
		"Patterns": category_save_key = "pattern"
		"Backgrounds": category_save_key = "background"
		"Avatars": category_save_key = "avatar"
		"Frames": category_save_key = "frame"
		"Banners": category_save_key = "banner"
		
	if category_save_key == "":
		print_debug("ERROR: Invalid category key in _on_equip_item_pressed: ", category)
		return

	# Update the equipped item in our save data using the correct key.
	SaveManager.save_data.equipped_cosmetics[category_save_key] = item_key
	SaveManager.save_game()
	
	# After equipping, we now call the master update function for the current page.
	update_all_displays()
	

	
func update_equipped_display(row1: HBoxContainer, row2: HBoxContainer):
	if not is_instance_valid(row1) or not is_instance_valid(row2): return

	var loadout = SaveManager.save_data.equipped_cosmetics
	
	# Update the color nodes in the first row
	_update_equipped_color_node(row2.get_node("EquippedHeadColorNode"), loadout.head_color, -1)
	for i in range(5):
		var body_color_node = row2.get_node("EquippedBodyColor" + str(i + 1) + "Node")
		# We now check if the index is valid before accessing it.
		if i < loadout.body_colors.size():
			_update_equipped_color_node(body_color_node, loadout.body_colors[i], i)
		
	# Update the other cosmetic nodes in the second row
	_update_equipped_item_node(row1.get_node("EquippedPatternNode"), "Patterns", loadout.pattern)
	_update_equipped_item_node(row1.get_node("EquippedBackgroundNode"), "Backgrounds", loadout.background)
	_update_equipped_item_node(row1.get_node("EquippedAvatarNode"), "Avatars", loadout.avatar)
	_update_equipped_item_node(row1.get_node("EquippedFrameNode"), "Frames", loadout.frame)
	_update_equipped_item_node(row1.get_node("EquippedBannerNode"), "Banners", loadout.banner)
	print("Current Loadout: ", loadout)
	
func _update_equipped_color_node(node: Button, color_key, slot_index: int):
	if not is_instance_valid(node): return
	if color_key == null:
		node.icon = preload("res://Assets/Icons/white_swatch.png") # Hide unused body color slots
		node.disabled = true
		return
		
	node.visible = true
	
	var color_data = GameManager.cosmetic_data.Colors.get(color_key)
	if color_data and color_data.has("hex_code"):
		node.icon = preload("res://Assets/Icons/white_swatch.png")
		node.modulate = Color(color_data.hex_code)
	else:
		node.icon = null
	
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(4)
	stylebox.bg_color = Color(0,0,0,0)
	stylebox.border_color = Color.CYAN if slot_index == active_color_slot_index else Color.TRANSPARENT
	node.add_theme_stylebox_override("normal", stylebox)
	node.update_minimum_size()

	
func _update_equipped_item_node(node: Button, category_key: String, item_key: String):
	if not is_instance_valid(node): return
	var rules = GameManager.cosmetic_data[category_key].get(item_key)
	if not rules:
		node.icon = null
		return
	var icon_path = rules.get("icon_path", "")
	if ResourceLoader.exists(icon_path):
		node.icon = load(icon_path)
		print("icon path loaded: ", icon_path)
	node.modulate = Color.WHITE
	node.get_child(0).visible = false
	node.update_minimum_size()

func _on_color_slot_selected(slot_index: int):
	# This function runs when you click one of the "Equipped" color swatches.
	active_color_slot_index = slot_index
	# Refresh the display to show the new active slot border.
	update_chroma_palette_page()
	
func _on_equip_color_pressed(color_key: String):
	if active_color_slot_index == -1: # -1 is the head
		SaveManager.save_data.equipped_cosmetics.head_color = color_key
	else:
		SaveManager.save_data.equipped_cosmetics.body_colors[active_color_slot_index] = color_key
		
	SaveManager.save_game()
	update_chroma_palette_page()

func update_career_stats_tab():
	var stats = SaveManager.save_data.milestone_progress
	var career_stats = SaveManager.save_data
	
	player_rank_label.text = "Snake Rank: %s" % career_stats.player_level
	high_score_label.text = "High Score: %s" % career_stats.high_score
	total_deaths_label.text = "Total Deaths Accrued: %s" % stats.total_deaths
	total_juice_label.text = "Total Juice (mL): %s" % career_stats.total_juice_earned
	total_pulp_label.text = "Total Pulp (mg): %s" % career_stats.total_pulp_earned
	rocks_destroyed_label.text = "Total Rocks Destroyed: %s" % stats.rocks_destroyed
	#prestiges_completed_label.text = "Prestiges Attempted: %s" %
	total_upgrades_purchased_label.text = "Total Upgrades Purchased: %s" % stats.upgrades_purchased
	#total_cosmetics_label.text = "Total Cosmetics Purchased: %s" % 
	total_combos_label.text = "Total Combos: %s" % stats.combos_achieved 
	
func update_milestones_tab():
	# 1. Clear out any old milestone nodes.
	for child in milestones_list_container.get_children():
		child.queue_free()
		
	# 2. Loop through every milestone defined in our GameManager rulebook.
	for stat_key in GameManager.milestone_data:
		var milestone_rules = GameManager.milestone_data[stat_key]
		var player_progress = SaveManager.save_data.milestone_progress.get(stat_key, 0)
		
		# 3. Find the next uncompleted tier for this milestone.
		var next_tier = null
		for tier in milestone_rules.tiers:
			if not tier.key in SaveManager.save_data.unlocked_milestones:
				next_tier = tier
				break # We found the next goal, so we can stop looking.
		
		# --- THIS IS THE NEW LOGIC ---
		# 4. Create a new, more complex UI element for the milestone.
		var milestone_node = HBoxContainer.new()
		milestone_node.alignment = HBoxContainer.ALIGNMENT_CENTER
		
		# 4a. Create the Icon
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(64, 64)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var icon_path = milestone_rules.get("icon_path", "")
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
			
		# 4b. Create a VBoxContainer to hold the text and progress bar
		var text_container = VBoxContainer.new()
		text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var title_label = Label.new()
		title_label.text = milestone_rules.display_name
		
		var progress_label = Label.new()
		var progress_bar = ProgressBar.new() # Using a progress bar for a cleaner look
		progress_bar.custom_minimum_size = Vector2(0, 16)
		
		if next_tier:
			# If there's still a goal to reach, show the progress.
			progress_label.text = "%s / %s" % [int(player_progress), next_tier.goal]
			progress_bar.max_value = next_tier.goal
			progress_bar.value = player_progress
		else:
			# If all tiers are complete, show a "MAX" message.
			title_label.text += " (COMPLETE!)"
			progress_label.visible = false
			progress_bar.value = progress_bar.max_value # Fill the bar
			
		# 5. Assemble the final node.
		text_container.add_child(title_label)
		text_container.add_child(progress_label)
		text_container.add_child(progress_bar)
		
		milestone_node.add_child(icon)
		milestone_node.add_child(text_container)
		
		milestones_list_container.add_child(milestone_node)
		print(SaveManager.save_data.milestone_progress)

func _on_tab_container_tab_changed(tab_index: int):
	var tab_name = $MarginContainer/VBoxContainer/ShedTabs.get_tab_title(tab_index)
	
	match tab_name:
		"Customization":
			update_all_displays()
		"Career Stats":
			update_career_stats_tab()
		"Milestones":
			update_milestones_tab()
