extends Machine

signal cash_deposited(amount: int)

func interact(p: Player) -> void:
	if p.held_item == "plata":
		var amount := p.held_value
		p.drop_item()
		cash_deposited.emit(amount)
