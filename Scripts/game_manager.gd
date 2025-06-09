extends Node

var current_difficulty = "normal"

func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func start_game():
	get_tree().paused = false
	go_to_scene("res://Scenes/main.tscn")
