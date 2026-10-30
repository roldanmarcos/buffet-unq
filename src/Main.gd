extends Node

const DOOR_SOUND := preload("res://assets/sound/door.mp3")
const CLIENT_LOST_SOUND := preload("res://assets/sound/client_lost.mp3")

@export var customer_scene: PackedScene
@export var money_scene: PackedScene

var level_index := 0
var level: Dictionary
var level_over := false
var time_up := false 
var money := 0
var lost_customers := 0
var active_customers := 0
var pending_money := 0

@onready var level_timer: Timer = $LevelTimer
@onready var game_hud: CanvasLayer = $GameHUD
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var transition_rect: ColorRect = $TransitionLayer/Reveal
@onready var transition_material: ShaderMaterial = transition_rect.material
@onready var lost_customer_flash: ColorRect = $LostCustomerFlashLayer/Flash
@onready var door_sound: AudioStreamPlayer = $DoorSound
@onready var client_lost_sound: AudioStreamPlayer = $ClientLostSound

var lost_customer_flash_tween: Tween


func _ready() -> void:
	level_index = Levels.current(get_tree())
	level = Levels.data(level_index)
	if not level.orderable.has("pancho"):
		$HotDogs.queue_free()
		$BreadBasket.queue_free()
	else:
		$HotDogs.visible = true
		$BreadBasket.visible = true
	door_sound.stream = DOOR_SOUND
	client_lost_sound.stream = CLIENT_LOST_SOUND
	get_tree().paused = true
	transition_material.set_shader_parameter("reveal", 0.0)
	var reveal_tween := create_tween()
	reveal_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	reveal_tween.tween_method(_set_reveal, 0.0, 1.0, 1.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reveal_tween.tween_callback(_finish_intro)
	$CashRegister.cash_deposited.connect(_on_cash_deposited)
	game_hud.main_menu_requested.connect(_on_main_menu_requested)
	game_hud.restart_requested.connect(_on_restart_requested)
	game_hud.next_level_requested.connect(_on_next_level_requested)

func _finish_intro() -> void:
	transition_layer.visible = false
	get_tree().paused = false
	level_timer.one_shot = true
	level_timer.wait_time = level.seconds
	level_timer.timeout.connect(_on_level_timer_timeout)
	level_timer.start()
	game_hud.show_level_intro(level_index + 1)
	_schedule_spawn($Lugar1, 0.0)
	_schedule_spawn($Lugar2, 5.0)
	_schedule_spawn($Lugar3, 7.0)

func _set_reveal(value: float) -> void:
	transition_material.set_shader_parameter("reveal", value)

func _schedule_spawn(slot: Marker2D, delay: float) -> void:
	get_tree().create_timer(delay, false).timeout.connect(_spawn_customer.bind(slot))

func _spawn_customer(slot: Marker2D) -> void:
	if level_over or time_up:
		return
	active_customers += 1
	var c: Customer = customer_scene.instantiate()
	c.order = Items.random_order(_available_orders())
	c.max_patience = Items.patience(c.order) * level.patience_multiplier
	c.set_meta("money_pos", slot.get_node("MoneyPos").global_position)
	add_child(c)
	door_sound.play()
	c.setup($Entrada.global_position, slot.global_position)
	c.served.connect(_on_customer_served)
	c.left_unserved.connect(_on_customer_left)
	c.departed.connect(_on_customer_departed.bind(slot))

func _available_orders() -> Array:
	var options: Array = level.orderable.filter(
		func(item: String) -> bool: return Items.can_order(item, _waiting_orders(item))
	)
	return options if not options.is_empty() else level.orderable

func _waiting_orders(item: String) -> int:
	var count := 0
	for child in get_children():
		if child is Customer and child.state != Customer.State.LEAVING and child.order == item:
			count += 1
	return count

func _on_customer_departed(_customer: Customer, slot: Marker2D) -> void:
	_schedule_spawn(slot, randf_range(level.spawn_delay_min, level.spawn_delay_max))
	
func _on_customer_served(customer: Customer) -> void:
	active_customers -= 1
	var m: Money = money_scene.instantiate()
	m.value = Items.price(customer.order)
	pending_money += m.value
	add_child(m)
	m.global_position = customer.get_meta("money_pos")


func _on_customer_left(_customer: Customer) -> void:
	active_customers -= 1
	lost_customers += 1
	client_lost_sound.play()
	_show_lost_customer_flash()
	game_hud.set_lives(3 - lost_customers)
	if lost_customers >= 3:
		_end_level(false)
	else:
		_check_level_complete()

func _show_lost_customer_flash() -> void:
	if lost_customer_flash_tween and lost_customer_flash_tween.is_running():
		lost_customer_flash_tween.kill()
	lost_customer_flash.modulate.a = 0.0
	lost_customer_flash.visible = true
	lost_customer_flash_tween = create_tween()
	lost_customer_flash_tween.tween_property(lost_customer_flash, "modulate:a", 0.32, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	lost_customer_flash_tween.tween_interval(0.3)
	lost_customer_flash_tween.tween_property(lost_customer_flash, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	lost_customer_flash_tween.tween_callback(func(): lost_customer_flash.visible = false)

func _on_cash_deposited(amount: int) -> void:
	pending_money -= amount
	money += amount
	game_hud.set_money(money)
	_check_level_complete()

func _on_main_menu_requested() -> void:
	get_tree().paused = false
	get_tree().set_meta("returning_to_main_menu", true)
	get_tree().change_scene_to_file("res://src/ui/Start.tscn")

func _on_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next_level_requested() -> void:
	Levels.set_current(get_tree(), level_index + 1)
	get_tree().paused = false
	get_tree().reload_current_scene()


func _process(_delta: float) -> void:
	if not level_over:
		game_hud.set_time(level_timer.time_left)

func _on_level_timer_timeout() -> void:
	time_up = true
	game_hud.set_time(0.0)
	_check_level_complete()

func _check_level_complete() -> void:
	if level_over or not time_up:
		return
	if active_customers == 0 and pending_money == 0:
		_end_level(true)

func _end_level(won: bool) -> void:
	if level_over:
		return
	level_over = true
	level_timer.stop()
	if won and Levels.has_next(level_index):
		SaveData.unlock_level(level_index + 1)
	game_hud.show_level_result(won, money, level_index + 1, Levels.has_next(level_index))
