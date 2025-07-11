extends Node2D
class_name RipeningFruit

var states = ["Green", "Yellow", "Red", "Rotten"]
var current_state_index = 0
@onready var sprite = $Sprite2D
@onready var timer = $RipenTimer

func _ready():
	timer.timeout.connect(_on_ripen_timer_timeout)
	timer.start(2.0) # Change state every 2 seconds
	_update_color()

func _on_ripen_timer_timeout():
	current_state_index = (current_state_index + 1) % states.size()
	_update_color()
	
	if states[current_state_index] == "Rotten":
		# The fruit disappears after 1 second of being rotten.
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _update_color():
	match states[current_state_index]:
		"Green": sprite.modulate = Color.GREEN
		"Yellow": sprite.modulate = Color.YELLOW
		"Red": sprite.modulate = Color.RED
		"Rotten": sprite.modulate = Color.DARK_GRAY
