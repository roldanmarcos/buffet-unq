class_name Items

const ICON_PATHS := {
	"gaseosa": "res://assets/soda_pepsi.png",
	"cafe": "res://assets/coffee.png",
	"pancho": "res://assets/hotDog.png",
	"pan": "res://assets/bread.png",
	"plata": "res://assets/money.png"
}

const ORDERABLE := ["gaseosa", "cafe"]
const PRICES := {
	"gaseosa": 10,
	"cafe": 15,
	"pancho": 20
}
# Segundos que espera un cliente según lo que pide.
# Lo que hay que preparar en una máquina da más tiempo.
const PATIENCE := {
	"gaseosa": 15.0,
	"cafe": 25.0,
	"pancho": 25.0
}
# Cuántos clientes pueden estar esperando el mismo pedido a la vez.
# Los productos que no están acá no tienen límite.
const MAX_WAITING := {
	"cafe": 2
}

static func icon(item: String) -> Texture2D:
	return load(ICON_PATHS[item]) if ICON_PATHS.has(item) else null

static func random_order(orderable: Array = ORDERABLE) -> String:
	return orderable.pick_random()

static func price(item: String) -> int:
	return PRICES.get(item, 10)

static func patience(item: String) -> float:
	return PATIENCE.get(item, 15.0)

static func can_order(item: String, waiting: int) -> bool:
	return not MAX_WAITING.has(item) or waiting < MAX_WAITING[item]

static func apply_icon(sprite: Sprite2D, item: String, size_px: float) -> void:
	var tex := icon(item)
	sprite.texture = tex
	if tex == null:
		return
	var s := size_px / float(maxi(tex.get_width(), tex.get_height()))
	sprite.scale = Vector2(s, s)
