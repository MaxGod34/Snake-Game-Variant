extends Button

#signal node_pressed(upgrade_key)
#signal node_mouse_entered(upgrade_key)
#signal node_mouse_exited(upgrade_key)

var upgrade_key: String = ""

func _ready():
	pass




# This is the master function that the tab controller will call.
func update_display(p_upgrade_key: String, current_level: int, max_level: int, is_unlocked: bool, theme_color: Color, accent_color: Color, theme_name: String = "Default"):
	self.upgrade_key = p_upgrade_key
	

	# We now create a unique StyleBox for each of the button's states.

	# -- The "Normal" Style (when the button is active and clickable) --
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0.4)
	style_normal.border_width_top = 8
	style_normal.border_width_bottom = 8
	style_normal.border_width_left = 8
	style_normal.border_width_right = 8
	
	
	if theme_name == "Frosty":
		# Create the cool "frosty" look for the Pulp-sicle Stand.
		style_normal.bg_color = Color(0.9, 0.9, 1.0, 0.1) # A faint, icy blue
		style_normal.border_color = theme_color # The rarity color (Gray, Blue, or Gold)
		style_normal.corner_radius_top_left = 16
		style_normal.corner_radius_top_right = 16
		style_normal.corner_radius_bottom_left = 16
		style_normal.corner_radius_bottom_right = 16
		style_normal.bg_color = Color(0, 0, 0, 0.4)
		style_normal.border_width_top = 16
		style_normal.border_width_bottom = 16
		style_normal.border_width_left = 16
		style_normal.border_width_right = 16
	else:
		if current_level >= max_level:
			style_normal.border_color = theme_color # A solid gold/accent border when maxed
		else:
			style_normal.border_color = accent_color # The default border color
	
	
	# -- The "Disabled" Style --
	var style_disabled = style_normal.duplicate() # Start with the same settings
	style_disabled.border_color = Color(0.3, 0.3, 0.3, 0.5) # A dull gray for the border
	#----Hovered
	var style_hovered = style_normal.duplicate()
	style_hovered.border_color = Color(theme_color.r, theme_color.g, theme_color.b, max(theme_color.a - 0.3, 0.0))
	#----Pressed
	var style_pressed = style_normal.duplicate()
	var pressed_color = theme_color.lightened(0.3)
	pressed_color.a = min(theme_color.a + 0.2, 1.0)
	style_pressed.border_color = pressed_color
	# Now, apply these new styles to the button's theme.
	self.add_theme_stylebox_override("normal", style_normal)
	self.add_theme_stylebox_override("disabled", style_disabled)
	self.add_theme_stylebox_override("hover", style_hovered)
	self.add_theme_stylebox_override("focus", style_hovered)
	self.add_theme_stylebox_override("pressed", style_pressed)

	
	# --- Update Level Indicators ---
	var indicator_container = $IndicatorContainer
	for child in indicator_container.get_children():
		child.queue_free()
		
	for i in range(1, max_level + 1):
		var block = ColorRect.new()
		block.custom_minimum_size = Vector2(8, 8)
		# We now use the theme color for the "empty" blocks.
		block.color = Color.GOLD if i <= current_level else accent_color.darkened(0.5)
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

	
