extends Area2D

class_name GoldenFruit
var fruit_type = "GoldenFruit"

var is_ripe = false
var time_left_to_ripen: float = -1.0
var is_bounty_target = false
var active_tween: Tween = null

@export var fill_color: Color = Color.GOLD
@onready var fill_sprite = $FillSprite

func _ready():
	fill_sprite.modulate = fill_color
	var gardener_level = GameManager.patient_gardener_level
	if gardener_level > 0:
		time_left_to_ripen = GameManager.patient_gardener_data[gardener_level]["time"]
	if GameManager.masters_blueprint_unlocked:
		fill_sprite.modulate = Color("FFC200")

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
	
func reset_from_bounty():
	is_bounty_target = false
	# Kill any active tween (like the bounty pulse)
	if is_instance_valid(active_tween):
		active_tween.kill()
		active_tween = null
		
	# Reset the scale and color back to normal
	scale = Vector2.ONE
	# Check what type of fruit this is to apply the correct color
	if self is GoldenFruit:
		get_node("FillSprite").modulate = Color.GOLD
	else:
		# This assumes THE normal fruit is red. Change if needed!
		get_node("FillSprite").modulate = Color.RED 
