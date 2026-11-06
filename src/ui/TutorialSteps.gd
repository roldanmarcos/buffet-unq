class_name TutorialSteps


static func basics(main: Node) -> Array:
	var player: Player = main.get_node("Player")
	var fridge: Node2D = main.get_node("Fridge")
	var coffee: Node2D = main.get_node("CoffeeMachine")
	var register: Node2D = main.get_node("CashRegister")
	var trash: Node2D = main.get_node("TrashCan")
	var start_pos := player.global_position
	var spawned := {}

	return [
		{
			"text": "¡Bienvenido/a al buffet! Movete con WASD o con las flechas.",
			"target": func(): return player.global_position,
			"radius": 70.0,
			"done": func(): return player.global_position.distance_to(start_pos) > 120.0,
		},
		{
			"text": "Con la tecla E agarrás, dejás y entregás cosas. Llegó un cliente: andá a la heladera y agarrá una gaseosa.",
			"on_start": func(): spawned.soda = main.spawn_tutorial_customer(main.get_node("Lugar3"), "gaseosa"),
			"target": func(): return fridge.global_position,
			"radius": 75.0,
			"done": func(): return player.held_item == "gaseosa",
		},
		{
			"text": "Llevale la gaseosa al cliente.",
			"target": func(): return _customer_position(spawned.soda),
			"done": func(): return _was_served(spawned.soda),
		},
		{
			"text": "¡Te pagó! Agarrá la plata del mostrador.",
			"target": func(): return _money_position(main),
			"radius": 60.0,
			"done": func(): return player.held_item == "plata",
		},
		{
			"text": "Llevá la plata a la caja.",
			"target": func(): return register.global_position,
			"radius": 65.0,
			"done": func(): return main.money > 0,
		},
		{
			"text": "Este cliente quiere café. Usá la cafetera para que empiece a prepararlo.",
			"on_start": func(): spawned.coffee = main.spawn_tutorial_customer(main.get_node("Lugar1"), "cafe"),
			"target": func(): return coffee.global_position,
			"radius": 70.0,
			"done": func(): return coffee.state != coffee.State.IDLE,
		},
		{
			"text": "El café tarda unos segundos. Cuando esté listo, agarralo.",
			"target": func(): return coffee.global_position,
			"radius": 70.0,
			"done": func(): return player.held_item == "cafe",
		},
		{
			"text": "Llevale el café al cliente.",
			"target": func(): return _customer_position(spawned.coffee),
			"done": func(): return _was_served(spawned.coffee),
		},
		{
			"text": "Juntá la plata y llevala a la caja.",
			"target": func(): return register.global_position if player.held_item == "plata" else _money_position(main),
			"radius": 65.0,
			"done": func(): return main.pending_money == 0 and not player.has_item() and main.money > Items.price("gaseosa"),
		},
		{
			"text": "Estos son tus 3 corazones. Si un cliente se cansa de esperar y se va enojado, perdés un corazón entero.",
			"target": func(): return _lives_position(main),
			"radius": 80.0,
		},
		{
			"text": "Si tirás comida a la basura perdés medio corazón. Probá: agarrá una gaseosa y tirala en el tacho.",
			"target": func(): return trash.global_position if player.has_item() and player.held_item != "plata" else fridge.global_position,
			"radius": 70.0,
			"done": func(): return main.health_units < 6,
		},
		{
			"text": "¿Viste? Perdiste medio corazón. Si te quedás sin corazones, perdés el nivel.",
			"target": func(): return _lives_position(main),
			"radius": 80.0,
		},
		{
			"text": "Ojo: algunos clientes piden dos cosas y te pagan cuando les diste todo. Cuando les das la primera, recuperan un poco de paciencia.",
		},
		{
			"text": "En el juego tenés 90 segundos para atender a todos. ¡Listo, ya sabés atender el buffet!",
		},
	]


static func hot_dogs(main: Node) -> Array:
	var player: Player = main.get_node("Player")
	var basket: Node2D = main.get_node("BreadBasket")
	var hot_dogs_machine: Node2D = main.get_node("HotDogs")

	return [
		{
			"text": "¡Nuevo en este nivel: los panchos! Agarrá un pan de la panera.",
			"target": func(): return basket.global_position,
			"radius": 60.0,
			"done": func(): return player.held_item == "pan",
		},
		{
			"text": "Dejá el pan en la máquina de panchos.",
			"target": func(): return hot_dogs_machine.global_position,
			"radius": 70.0,
			"done": func(): return hot_dogs_machine.slot_states.any(func(s): return s != hot_dogs_machine.SlotState.EMPTY),
		},
		{
			"text": "La máquina tarda unos segundos y puede hacer dos panchos a la vez. Cuando esté listo, agarralo.",
			"target": func(): return hot_dogs_machine.global_position,
			"radius": 70.0,
			"done": func(): return player.held_item == "pancho",
		},
		{
			"text": "¡Perfecto! Así se hacen los panchos para los clientes que los pidan. ¡Arranca el nivel 2!",
		},
	]


static func _customer_position(customer: Variant) -> Variant:
	if customer == null or not is_instance_valid(customer):
		return null
	return customer.global_position + Vector2(0, -30)


static func _was_served(customer: Variant) -> bool:
	return customer == null or not is_instance_valid(customer) or customer.state == Customer.State.LEAVING


static func _money_position(main: Node) -> Variant:
	for child in main.get_children():
		if child is Money:
			return child.global_position
	return null


static func _lives_position(main: Node) -> Vector2:
	var lives: Control = main.game_hud.get_node("UI/LivesPanel")
	return lives.get_global_rect().get_center()
