extends CharacterBody2D
class_name Player

const SPEED = 300.0
@export var MARGIN: Vector2 = Vector2(36, 57)

var held_item: String = ""
@onready var held_item_visual: Sprite2D = $HeldItem


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

func hold(item: String) -> void:
	held_item = item
	held_item_visual.texture = Items.icon(item)
	held_item_visual.visible = true

func has_item() -> bool:
	return held_item != ""

func drop_item() -> void:
	held_item = ""
	held_item_visual.visible = false
