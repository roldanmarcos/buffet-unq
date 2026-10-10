extends Machine


func interact(p: Player) -> void:
	if p.has_item():
		p.drop_item()
