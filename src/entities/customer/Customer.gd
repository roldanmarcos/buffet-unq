extends CharacterBody2D
class_name Customer

var fill_style: StyleBoxFlat
signal served(customer: Customer)
signal left_unserved(customer: Customer)

const WALK_SPEED := 200.0

@export var order: String = ""
@export var max_patience: float = 15.0

enum State { ARRIVING, WAITING, LEAVING }
var state := State.ARRIVING

var patience: float
var player: Player = null
var slot_pos: Vector2
var exit_pos: Vector2
var path: Array[Vector2] = []
var entry_path: Array[Vector2] = []
var exit_path: Array[Vector2] = []

@onready var bar: ProgressBar = $PatienceBar
@onready var bubble: Node2D = $Bubble
@onready var bubble_icon: Sprite2D = $Bubble/Icon

signal departed(customer: Customer)

func setup(entrance: Vector2, slot: Vector2) -> void:
	global_position = entrance
	var corner := Vector2(slot.x, entrance.y)
	entry_path = [corner, slot]
	exit_path = [corner, entrance]
	path = entry_path.duplicate()


func _ready() -> void:
	patience = max_patience
	
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(65, 10)
	bar.size = Vector2(65, 10)
	bar.max_value = max_patience
	bar.visible = false

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)

	fill_style = StyleBoxFlat.new()
	fill_style.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill_style)
	_update_bar()

	bubble_icon.texture = Items.icon(order)
	bubble.visible = false

	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	match state:
		State.ARRIVING:
			if _follow_path(delta):
				state = State.WAITING
				bar.visible = true
				_show_bubble()
		State.WAITING:
			patience -= delta
			_update_bar()
			if patience <= 0.0:
				_start_leaving(true)
		State.LEAVING:
			if _follow_path(delta):
				departed.emit(self)
				queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or player == null:
		return
	if state == State.WAITING and player.held_item == order:
		player.drop_item()
		served.emit(self)
		_start_leaving(false)


func _follow_path(delta: float) -> bool:
	if path.is_empty():
		return true
	global_position = global_position.move_toward(path[0], WALK_SPEED * delta)
	if global_position.is_equal_approx(path[0]):
		path.pop_front()
	return path.is_empty()


func _start_leaving(angry: bool) -> void:
	state = State.LEAVING
	path = exit_path.duplicate()
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

func _update_bar() -> void:
	bar.value = patience
	var ratio := patience / max_patience
	if ratio > 0.5:
		fill_style.bg_color = Color.YELLOW.lerp(Color.GREEN, (ratio - 0.5) * 2.0)
	else:
		fill_style.bg_color = Color.RED.lerp(Color.YELLOW, ratio * 2.0)
