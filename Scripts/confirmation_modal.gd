extends PanelContainer

signal confirmed
signal cancelled

@onready var message_label = $VBoxContainer/MessageLabel

func _ready():
	$VBoxContainer/ConfirmButton.pressed.connect(func(): emit_signal("confirmed"))
	$VBoxContainer/CancelButton.pressed.connect(func(): emit_signal("cancelled"))
	self.visible = false # Start hidden

func show_confirmation(message: String):
	message_label.text = message
	self.visible = true
