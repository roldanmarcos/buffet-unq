extends Machine

func interact(p: Player) -> void:
	if p.has_item():
		return # ya tiene algo en la mano
	p.hold("gaseosa")
