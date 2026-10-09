class_name Items

const ICON_PATHS := {
	"gaseosa": "res://icon.svg",
	"cafe": "res://assets/coffee.png",
	"plata": "res://assets/money.png"
}

const ORDERABLE := ["gaseosa", "cafe"]

static func icon(item: String) -> Texture2D:
	return load(ICON_PATHS[item]) if ICON_PATHS.has(item) else null

static func random_order() -> String:
	return ORDERABLE.pick_random()
