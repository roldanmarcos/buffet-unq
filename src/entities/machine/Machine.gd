extends StaticBody2D
class_name Machine

var player_near: bool = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_interact_area_body_entered)
	$InteractionArea.body_exited.connect(_on_interact_area_body_exited)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_near = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_near = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_near:
		interact()

func interact() -> void:
	pass
