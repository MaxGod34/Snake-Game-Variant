extends Node

var current_difficulty = "normal"
var player_level = 1
var skill_points = 0
var score_needed_for_next_level = 5

func go_to_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func start_game():
	get_tree().paused = false
	go_to_scene("res://Scenes/main.tscn")
