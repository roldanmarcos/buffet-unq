extends Node

@export var customer_scene: PackedScene

var lost_customers := 0


func _ready() -> void:
	_spawn_customer()


func _spawn_customer() -> void:
	var c: Customer = customer_scene.instantiate()
	add_child(c)
	c.setup($Entrada.global_position, $Lugar1.global_position)
	c.served.connect(_on_customer_served)
	c.left_unserved.connect(_on_customer_left)


func _on_customer_served(_customer: Customer) -> void:
	print("Cliente atendido")


func _on_customer_left(_customer: Customer) -> void:
	lost_customers += 1
	print("Clientes perdidos: ", lost_customers)
	if lost_customers >= 3:
		print("Perdiste el nivel")
