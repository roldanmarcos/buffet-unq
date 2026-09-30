extends StaticBody2D
class_name Machine

var player: Player = null

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_interact_area_body_entered)
	$InteractionArea.body_exited.connect(_on_interact_area_body_exited)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null:
		interact(player)

func interact(_player : Player) -> void:
	pass
