extends CanvasLayer

func _on_easy_button_pressed() -> void:
	GameManager.chosen_difficulty = "easy"
	GameManager.start_game()
func _on_normal_button_pressed() -> void:
	GameManager.chosen_difficulty = "normal"
	GameManager.start_game()
func _on_hard_button_pressed() -> void:
	GameManager.chosen_difficulty = "hard"
	GameManager.start_game()
func _on_back_button_pressed() -> void:
	GameManager.go_to_scene("res://Scenes/class_select.tscn")

func _ready() -> void:
	$ClassInfoLabel.text = "Class: " + GameManager.chosen_class.capitalize()

func _on_hard_button_mouse_entered() -> void:
	var hard_data = GameManager.difficulty_data["hard"]
	
	# Build a descriptive, multi-line string. The '\n' creates a new line.
	var description = "Speed: %sx\nScore Goals: %sx" % [hard_data["speed_multiplier"], hard_data["goal_multiplier"]]
	
	# Set the label's text
	$DescriptionLabel.text = description
func _on_hard_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''


func _on_normal_button_mouse_entered() -> void:
	var normal_data = GameManager.difficulty_data["normal"]
	var description = "Speed: %sx\nScore Goals: %sx" % [normal_data["speed_multiplier"], normal_data["goal_multiplier"]]
	$DescriptionLabel.text = description

func _on_normal_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''


func _on_easy_button_mouse_entered() -> void:
	var easy_data = GameManager.difficulty_data["easy"]
	var description = "Speed: %sx\nScore Goals: %sx" % [easy_data["speed_multiplier"],easy_data["goal_multiplier"]]
	$DescriptionLabel.text = description

func _on_easy_button_mouse_exited() -> void:
	$DescriptionLabel.text = ''
