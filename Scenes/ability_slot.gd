extends Panel

# --- NODE REFERENCES ---
@onready var hotkey_label = $HotkeyLabel
@onready var icon = $Icon
@onready var charge_count_label = $ChargeCountLabel
@onready var click_button = $ClickButton

# This is the master function that main.gd will call.
# It takes the ability's data and updates the slot's appearance.
func update_display(ability_key: String, charges: int):
	# If the ability_key is empty, it means the slot is empty.
	if ability_key == "":
		icon.visible = false
		charge_count_label.visible = false
		self.modulate = Color(1, 1, 1, 0.5) # Make it translucent
		return

	# If we have an ability, make everything visible and update it.
	self.modulate = Color.WHITE # Fully opaque
	icon.visible = true
	charge_count_label.visible = true
	
	# This is where we would set the icon's texture based on the ability key.
	# need to create icons for each ability!
	# icon.texture = preload("res://path/to/" + ability_key + "_icon.png")
	
	charge_count_label.text = str(charges)
