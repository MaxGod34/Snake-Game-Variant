extends CanvasLayer

func _ready() -> void:
	var rank_label = $PlayerProfilePanel/HBoxContainer/XPDisplayRow/CurrentLevelLabel
	var avatar_rect = $PlayerProfilePanel/HBoxContainer/XPDisplayRow/ProfilePicture
	
	var level = SaveManager.save_data.player_level
	var gm_rank = SaveManager.save_data.garden_master_rank
	var avatar_key = SaveManager.save_data.equipped_cosmetics.avatar
	
	rank_label.text = "Rank: %s" % level
	if gm_rank > 0:
		rank_label.text += " (GM %s)" % gm_rank
	
	var avatar_rules = GameManager.cosmetic_data.Avatars.get(avatar_key)
	if avatar_rules and ResourceLoader.exists(avatar_rules.icon_path):
		avatar_rect.texture = load(avatar_rules.icon_path)

func _on_play_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/selection_screen.tscn")


func _on_options_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/options_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()




func _on_the_shed_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/the_shed.tscn")


func _on_fang_fund_button_pressed() -> void:
	SceneTransition.transition_to("res://Scenes/Menus/fang_fund_menu.tscn")
