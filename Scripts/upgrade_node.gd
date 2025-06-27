extends Button

# This signal tells the parent tab when this node is clicked or hovered.
signal node_pressed(upgrade_key)
signal node_mouse_entered(upgrade_key)
signal node_mouse_exited(upgrade_key)

var upgrade_key: String = ""

func _ready():
	# Connect our own internal signals.
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# This is the master function that the tab controller will call.
func update_display(p_upgrade_key: String, current_level: int, max_level: int, is_unlocked: bool, theme_color: Color):
	self.upgrade_key = p_upgrade_key
	
	# Set the button's icon texture.
	# self.icon = preload(...)

	# --- THIS IS THE FIX ---
	# We now create a unique StyleBox for each of the button's states.

	# -- The "Normal" Style (when the button is active and clickable) --
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0.4)
	style_normal.border_width_top = 4
	style_normal.border_width_bottom = 4
	style_normal.border_width_left = 4
	style_normal.border_width_right = 4
	style_normal.border_color = theme_color
	
	# -- The "Disabled" Style --
	var style_disabled = style_normal.duplicate() # Start with the same settings
	style_disabled.border_color = Color(0.3, 0.3, 0.3, 0.5) # A dull gray for the border

	# Now, apply these new styles to the button's theme.
	self.add_theme_stylebox_override("normal", style_normal)
	self.add_theme_stylebox_override("disabled", style_disabled)
	
	# --- Update Level Indicators ---
	var indicator_container = $IndicatorContainer
	for child in indicator_container.get_children():
		child.queue_free()
		
	for i in range(1, max_level + 1):
		var block = ColorRect.new()
		block.custom_minimum_size = Vector2(12, 12)
		# We now use the theme color for the "empty" blocks.
		block.color = Color.GOLD if i <= current_level else theme_color.darkened(0.5)
		block.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		block.anchor_left = 0.0
		block.anchor_top = 1.0
		block.anchor_right = 1.0
		block.anchor_bottom = 1.0
		indicator_container.add_child(block)
			
	# Dim the entire node if the prerequisites aren't met
	if not is_unlocked:
		modulate = Color(0.5, 0.5, 0.5)
		disabled = true
	else:
		modulate = Color.WHITE
		disabled = (current_level >= max_level)

# --- Signal Forwarders ---
func _on_pressed():
	emit_signal("node_pressed", upgrade_key)

func _on_mouse_entered():
	emit_signal("node_mouse_entered", upgrade_key)

func _on_mouse_exited():
	emit_signal("node_mouse_exited")
