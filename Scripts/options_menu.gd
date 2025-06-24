extends CanvasLayer

@export var is_sub_panel: bool = false
signal back_pressed


func _on_fullscreen_check_box_toggled(button_pressed) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_button_pressed() -> void:
	if is_sub_panel:
		emit_signal("back_pressed")
	else:
		SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn")

func _ready():
	var current_mode = DisplayServer.window_get_mode()
	$CenterContainer/VBoxContainer/FullscreenCheckBox.button_pressed = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN)
