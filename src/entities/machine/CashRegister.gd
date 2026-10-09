extends Machine

signal cash_deposited

func interact(p: Player) -> void:
	if p.held_item == "plata":
		p.drop_item()
		cash_deposited.emit()
