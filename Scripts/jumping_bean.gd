extends Area2D

class_name JumpingBean
var fruit_type = "JumpingBean"

@onready var timer = Timer.new()
var is_ripe = false
var time_left_to_ripen: float = -1.0 # -1 means the timer is not active
var is_bounty_target = false
var active_tween: Tween = null

func _ready():
	add_child(timer)
	timer.wait_time = 3.0
	timer.timeout.connect(_on_jump_timer_timeout)
	timer.start()
	
	
func _on_jump_timer_timeout():
	var main_game = get_tree().current_scene
	if is_instance_valid(main_game):
		self.position = main_game.calculate_safe_spawn_position()
