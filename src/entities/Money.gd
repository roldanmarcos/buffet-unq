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
	if not event.is_action_pressed("interact") or player == null:
		return
	if not player.has_item() or player.held_item == "plata":
		# Si ya tiene plata en la mano, la suma: así lleva todo junto a la caja.
		# Se marca el input como usado para levantar un solo billete por vez.
		player.hold("plata", player.held_value + value)
		get_viewport().set_input_as_handled()
		queue_free()
