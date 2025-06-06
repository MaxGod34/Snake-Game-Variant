extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Snake_CharacterBody2D.position = Vector2(640, 480);
	$CharacterBody2D2.position = Vector2(1250, 650);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
