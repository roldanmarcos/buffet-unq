extends CharacterBody2D
class_name Customer

var fill_style: StyleBoxFlat
signal served(customer: Customer)
signal left_unserved(customer: Customer)

const WALK_SPEED := 200.0
const BLINK_BELOW := 0.3

@export var order: String = ""
var orders: Array[String] = []
var delivered_orders: Array[bool] = []
var character_variant := 0
@export var max_patience: float = 15.0

enum State { ARRIVING, WAITING, LEAVING }
var state := State.ARRIVING

var patience: float
var blink_time := 0.0
var player: Player = null
var slot_pos: Vector2
var exit_pos: Vector2
var path: Array[Vector2] = []
var entry_path: Array[Vector2] = []
var exit_path: Array[Vector2] = []

@onready var bar: ProgressBar = $PatienceBar
@onready var bubble: Node2D = $Bubble
@onready var bubble_icon: Sprite2D = $Bubble/Icon
@onready var character_sprite_1: AnimatedSprite2D = $AnimatedSprite2D
@onready var character_sprite_2: AnimatedSprite2D = $AnimatedSprite2D2
var character_sprite: AnimatedSprite2D

var facing := "down"

signal departed(customer: Customer)

func setup(entrance: Vector2, slot: Vector2) -> void:
	global_position = entrance
	var corner := Vector2(slot.x, entrance.y)
	entry_path = [corner, slot]
	exit_path = [corner, entrance]
	path = entry_path.duplicate()


func _ready() -> void:
	character_sprite = character_sprite_1 if character_variant == 0 else character_sprite_2
	character_sprite_1.visible = character_variant == 0
	character_sprite_2.visible = character_variant == 1
	character_sprite.play("idle_down")
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

	if orders.is_empty():
		orders.append(order)
		delivered_orders.append(false)
	_update_bubble_orders()
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
			_update_blink(delta)
			if patience <= 0.0:
				_start_leaving(true)
		State.LEAVING:
			if _follow_path(delta):
				departed.emit(self)
				queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or player == null:
		return
	if state != State.WAITING:
		return
	var order_index := orders.find(player.held_item)
	if order_index == -1 or delivered_orders[order_index]:
		return
	player.drop_item()
	delivered_orders[order_index] = true
	_update_bubble_orders()
	if _all_orders_delivered():
		served.emit(self)
		_start_leaving(false)


func _all_orders_delivered() -> bool:
	for delivered in delivered_orders:
		if not delivered:
			return false
	return true


func _update_bubble_orders() -> void:
	if not is_node_ready():
		return
	if orders.size() <= 1:
		bubble_icon.position = Vector2(0, -113)
		bubble_icon.rotation_degrees = 90.0 if orders[0] == "pancho" else 0.0
		Items.apply_icon(bubble_icon, orders[0], _bubble_icon_size(orders[0], false))
		_set_check(bubble_icon, delivered_orders[0], 0)
		return
	var positions := [Vector2(-24, -113), Vector2(24, -113)]
	for i in orders.size():
		var icon: Sprite2D
		if i == 0:
			icon = bubble_icon
		else:
			icon = $Bubble.get_node_or_null("OrderIcon%d" % i) as Sprite2D
			if icon == null:
				icon = Sprite2D.new()
				icon.name = "OrderIcon%d" % i
				$Bubble.add_child(icon)
		icon.position = positions[i]
		icon.rotation_degrees = 90.0 if orders[i] == "pancho" else 0.0
		Items.apply_icon(icon, orders[i], _bubble_icon_size(orders[i], true))
		_set_check(icon, delivered_orders[i], i)


func _bubble_icon_size(item: String, multiple_orders: bool) -> float:
	if item == "pancho":
		return Items.BUBBLE_SIZE * (0.85 if multiple_orders else 1.25)
	if multiple_orders:
		return Items.BUBBLE_SIZE
	if item == "gaseosa":
		return Items.BUBBLE_SIZE * 1.1
	if item == "cafe":
		return Items.BUBBLE_SIZE * 0.9
	return Items.BUBBLE_SIZE


func _set_check(icon: Sprite2D, visible_check: bool, index: int) -> void:
	var check := $Bubble.get_node("Check%d" % index) as Sprite2D
	check.position = icon.position + Vector2(12, -12)
	check.visible = visible_check


func _follow_path(delta: float) -> bool:
	if path.is_empty():
		_play_direction_animation(false, Vector2.ZERO)
		return true
	_play_direction_animation(true, path[0] - global_position)
	global_position = global_position.move_toward(path[0], WALK_SPEED * delta)
	if global_position.is_equal_approx(path[0]):
		path.pop_front()
		if path.is_empty():
			_play_direction_animation(false, Vector2.ZERO)
	return path.is_empty()


func _play_direction_animation(walking: bool, direction: Vector2) -> void:
	if walking and direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "right" if direction.x > 0.0 else "left"
		else:
			facing = "down" if direction.y > 0.0 else "up"
	var animation := ("walk_" if walking else "idle_") + facing
	if character_sprite.animation != animation:
		character_sprite.play(animation)


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

func _update_blink(delta: float) -> void:
	var ratio := patience / max_patience
	if ratio > BLINK_BELOW:
		bar.modulate.a = 1.0
		return
	blink_time += delta
	var speed := lerpf(5.0, 12.0, 1.0 - ratio / BLINK_BELOW)
	bar.modulate.a = 0.3 + 0.7 * absf(cos(blink_time * speed))

func _update_bar() -> void:
	bar.value = patience
	var ratio := patience / max_patience
	if ratio > 0.5:
		fill_style.bg_color = Color.YELLOW.lerp(Color.GREEN, (ratio - 0.5) * 2.0)
	else:
		fill_style.bg_color = Color.RED.lerp(Color.YELLOW, ratio * 2.0)
