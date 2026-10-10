extends Machine


func interact(p: Player) -> void:
	if p.has_item() and p.held_item != "plata":
		p.drop_item()
