extends Node

@export var customer_scene: PackedScene
@export var money_scene: PackedScene
@export var level_seconds: float = 90.0

var level_over := false

@onready var level_timer: Timer = $LevelTimer
var money := 0

var lost_customers := 0
@onready var game_hud: CanvasLayer = $GameHUD


func _ready() -> void:
	$CashRegister.cash_deposited.connect(_on_cash_deposited)
	game_hud.main_menu_requested.connect(_on_main_menu_requested)
	level_timer.one_shot = true
	level_timer.wait_time = level_seconds
	level_timer.timeout.connect(_on_level_timer_timeout)
	level_timer.start()
	_spawn_customer($Lugar1)
	await get_tree().create_timer(5.0).timeout
	_spawn_customer($Lugar2)


func _spawn_customer(slot: Marker2D) -> void:
	var c: Customer = customer_scene.instantiate()
	c.order = Items.random_order()
	c.set_meta("money_pos", slot.get_node("MoneyPos").global_position)
	add_child(c)
	c.setup($Entrada.global_position, slot.global_position)
	c.served.connect(_on_customer_served)
	c.left_unserved.connect(_on_customer_left)


func _on_customer_served(customer: Customer) -> void:
	print("Cliente atendido")
	var m: Money = money_scene.instantiate()
	m.value = Items.price(customer.order)
	add_child(m)
	m.global_position = customer.get_meta("money_pos")


func _on_customer_left(_customer: Customer) -> void:
	lost_customers += 1
	print("Clientes perdidos: ", lost_customers)
	if lost_customers >= 3:
		_end_level(false)


func _on_cash_deposited(amount: int) -> void:
	money += amount
	game_hud.set_money(money)
	print("Plata: ", money)


func _on_main_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/Start.tscn")

func _process(_delta: float) -> void:
	if not level_over:
		game_hud.set_time(level_timer.time_left)


func _on_level_timer_timeout() -> void:
	game_hud.set_time(0.0)
	_end_level(true)


func _end_level(won: bool) -> void:
	if level_over:
		return
	level_over = true
	level_timer.stop()
	print("Ganaste el nivel" if won else "Perdiste el nivel")
