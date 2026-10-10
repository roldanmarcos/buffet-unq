extends Area2D
class_name Money

@export var value: int = 10

var player: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null and not player.has_item():
		player.hold("plata", value)
		queue_free()
