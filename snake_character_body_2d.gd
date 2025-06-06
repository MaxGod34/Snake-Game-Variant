extends CharacterBody2D


@export var SPEED = 300.0
var can_change_direction = true
var current_direction: Vector2 = Vector2.RIGHT

func _unhandled_input(event: InputEvent) -> void:
	if (can_change_direction):
		if (event.is_action_pressed("up")):
			if (current_direction != Vector2.DOWN):
				current_direction = Vector2.UP
				can_change_direction = false
		elif (event.is_action_pressed("down")):
			if (current_direction != Vector2.UP):
				current_direction = Vector2.DOWN
				can_change_direction = false
		elif (event.is_action_pressed("left")):
			if (current_direction != Vector2.RIGHT):
				current_direction = Vector2.LEFT
				can_change_direction = false
		elif (event.is_action_pressed("right")):
			if (current_direction != Vector2.LEFT):
				current_direction = Vector2.RIGHT
				can_change_direction = false
	velocity = SPEED * current_direction
	can_change_direction = true

		

func ready():
	velocity = current_direction * SPEED
	pass

func _physics_process(delta) -> void:

	move_and_slide()
