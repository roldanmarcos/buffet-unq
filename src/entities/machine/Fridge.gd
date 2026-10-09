extends Machine

func interact(p: Player) -> void:
	if p.has_item():
		return
	p.hold("gaseosa")
