class_name Items

const ICON_PATHS := {
	"gaseosa": "res://assets/soda_pepsi.png",
	"cafe": "res://assets/coffee.png",
	"plata": "res://assets/money.png"
}

const ORDERABLE := ["gaseosa", "cafe"]
const PRICES := {
	"gaseosa": 10,
	"cafe": 10
}

static func icon(item: String) -> Texture2D:
	return load(ICON_PATHS[item]) if ICON_PATHS.has(item) else null

static func random_order() -> String:
	return ORDERABLE.pick_random()

static func price(item: String) -> int:
	return PRICES.get(item, 10)

static func apply_icon(sprite: Sprite2D, item: String, size_px: float) -> void:
	var tex := icon(item)
	sprite.texture = tex
	if tex == null:
		return
	var s := size_px / float(maxi(tex.get_width(), tex.get_height()))
	sprite.scale = Vector2(s, s)
