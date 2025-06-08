extends Area2D
class_name Fruit

@export var fruit_color: Color = Color.RED

func _ready():
	get_node("FillSprite").modulate = fruit_color
