extends CharacterBody2D

class_name Player

@export var MARGIN: Vector2 = Vector2(36, 57)

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * SPEED

	move_and_slide()
	
	var screen: Rect2 = get_viewport_rect()
	
	global_position = global_position.clamp(screen.position + MARGIN, screen.end - MARGIN)
