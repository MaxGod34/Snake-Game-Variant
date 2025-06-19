extends Area2D
class_name Fruit

# A variable to track the state of this specific fruit
var is_ripe = false
var time_left_to_ripen: float = -1.0 # -1 means the timer is not active
var is_bounty_target = false
var active_tween: Tween = null

@export var fill_color: Color = Color.RED

@onready var fill_sprite = $FillSprite

func _ready():
	# When this fruit is created, check if the player has the upgrade
	fill_sprite.modulate = fill_color
	var gardener_level = GameManager.patient_gardener_level
	if gardener_level > 0:
		# If yes, set the time left based on our data.
		time_left_to_ripen = GameManager.patient_gardener_data[gardener_level]["time"]
	if GameManager.masters_blueprint_unlocked:
		fill_sprite.modulate = Color("AFEEEE")

# This new function can be called by main.gd when the time is up
func ripen():
	# If this fruit is already the bounty target, do nothing.
	# The bounty animation is more important.
	if is_bounty_target:
		return

	if is_ripe:
		return
		
	is_ripe = true
	print("A fruit has ripened!")
	
	# Before creating a new tween, kill any old one that might exist.
	if is_instance_valid(active_tween):
		active_tween.kill()

	# Create the new tween animation
	var tween = create_tween().set_loops()
	tween.tween_property($FillSprite, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property($FillSprite, "scale", Vector2(1.0, 1.0), 0.5)
	
	# Store a reference to the new tween
	active_tween = tween
