extends Node2D
class_name Customer

signal served(customer: Customer)
signal left_unserved(customer: Customer)

const WALK_SPEED := 120.0

@export var order: String = "gaseosa"
@export var order_icon: Texture2D
@export var max_patience: float = 15.0

enum State { ARRIVING, WAITING, LEAVING }
var state := State.ARRIVING

var patience: float
var player: Player = null
var slot_pos: Vector2
var exit_pos: Vector2

@onready var bar: ProgressBar = $PatienceBar
@onready var bubble: Node2D = $Bubble
@onready var bubble_icon: Sprite2D = $Bubble/Icon


# Lo llama quien crea al cliente, justo después de agregarlo a la escena
func setup(entrance: Vector2, slot: Vector2) -> void:
	global_position = entrance
	exit_pos = entrance
	slot_pos = slot


func _ready() -> void:
	patience = max_patience
	bar.max_value = max_patience
	bar.value = max_patience
	bar.visible = false

	bubble_icon.texture = order_icon
	bubble.visible = false

	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	match state:
		State.ARRIVING:
			if _walk_to(slot_pos, delta):
				state = State.WAITING
				bar.visible = true
				_show_bubble()
		State.WAITING:
			patience -= delta
			bar.value = patience
			if patience <= 0.0:
				_start_leaving(true)
		State.LEAVING:
			if _walk_to(exit_pos, delta):
				queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or player == null:
		return
	if state == State.WAITING and player.held_item == order:
		player.drop_item()
		served.emit(self)
		_start_leaving(false)


# Devuelve true cuando llegó al destino
func _walk_to(target: Vector2, delta: float) -> bool:
	global_position = global_position.move_toward(target, WALK_SPEED * delta)
	return global_position.is_equal_approx(target)


func _start_leaving(angry: bool) -> void:
	state = State.LEAVING
	bar.visible = false
	bubble.visible = false
	if angry:
		left_unserved.emit(self)


func _show_bubble() -> void:
	bubble.visible = true
	bubble.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(bubble, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
