extends PanelContainer

# --- NODE REFERENCES ---
# Make sure these paths are correct for your scene!
@onready var name_label = $MarginC/VBox/UpgradeNameLabel
@onready var description_label = $MarginC/VBox/DescriptionLabel
@onready var cost_label = $MarginC/VBox/CostLabel

# This is the master function that main.gd will call.
func show_info(p_name: String, p_description: String, p_cost: int):
	name_label.text = p_name
	description_label.text = p_description
	
	# If the cost is 999, it means the upgrade is maxed out.
	if p_cost >= 999:
		cost_label.text = "(MAX LEVEL)"
	else:
		cost_label.text = "Cost: %s Juice" % p_cost
		
	self.visible = true
