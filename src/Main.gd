extends Node

@export var customer_scene: PackedScene
@export var money_scene: PackedScene
@export var level_seconds: float = 90.0
@export var spawn_delay_min: float = 2.0
@export var spawn_delay_max: float = 4.0

var level_over := false
var time_up := false 
var money := 0
var lost_customers := 0
var active_customers := 0
var pending_money := 0

@onready var level_timer: Timer = $LevelTimer
@onready var game_hud: CanvasLayer = $GameHUD


func _ready() -> void:
	$CashRegister.cash_deposited.connect(_on_cash_deposited)
	game_hud.main_menu_requested.connect(_on_main_menu_requested)
	game_hud.restart_requested.connect(_on_restart_requested)
	level_timer.one_shot = true
	level_timer.wait_time = level_seconds
	level_timer.timeout.connect(_on_level_timer_timeout)
	level_timer.start()
	_schedule_spawn($Lugar1, 0.0)
	_schedule_spawn($Lugar2, 5.0)

func _schedule_spawn(slot: Marker2D, delay: float) -> void:
	get_tree().create_timer(delay, false).timeout.connect(_spawn_customer.bind(slot))

func _spawn_customer(slot: Marker2D) -> void:
	if level_over or time_up:
		return
	active_customers += 1
	var c: Customer = customer_scene.instantiate()
	c.order = Items.random_order()
	c.set_meta("money_pos", slot.get_node("MoneyPos").global_position)
	add_child(c)
	c.setup($Entrada.global_position, slot.global_position)
	c.served.connect(_on_customer_served)
	c.left_unserved.connect(_on_customer_left)
	c.departed.connect(_on_customer_departed.bind(slot))

func _on_customer_departed(_customer: Customer, slot: Marker2D) -> void:
	_schedule_spawn(slot, randf_range(spawn_delay_min, spawn_delay_max))
	
func _on_customer_served(customer: Customer) -> void:
	active_customers -= 1
	pending_money += 1
	var m: Money = money_scene.instantiate()
	m.value = Items.price(customer.order)
	add_child(m)
	m.global_position = customer.get_meta("money_pos")


func _on_customer_left(_customer: Customer) -> void:
	active_customers -= 1
	lost_customers += 1
	if lost_customers >= 3:
		_end_level(false)
	else:
		_check_level_complete()

func _on_cash_deposited(amount: int) -> void:
	pending_money -= 1
	money += amount
	game_hud.set_money(money)
	_check_level_complete()

func _on_main_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/Start.tscn")

func _on_restart_requested() -> void:
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
	game_hud.show_level_result(won, money)
