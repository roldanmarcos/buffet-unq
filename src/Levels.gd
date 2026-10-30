class_name Levels

const CURRENT_LEVEL_META := "current_level"

const LEVELS := [
	{
		"orderable": ["gaseosa", "cafe"],
		"seconds": 90.0,
		"spawn_delay_min": 2.0,
		"spawn_delay_max": 4.0,
		"patience_multiplier": 1.0,
	},
	{
		"orderable": ["gaseosa", "cafe", "pancho"],
		"seconds": 90.0,
		"spawn_delay_min": 1.5,
		"spawn_delay_max": 3.0,
		"patience_multiplier": 0.85,
	},
]

static func current(tree: SceneTree) -> int:
	return tree.get_meta(CURRENT_LEVEL_META, 0)

static func set_current(tree: SceneTree, index: int) -> void:
	tree.set_meta(CURRENT_LEVEL_META, clampi(index, 0, LEVELS.size() - 1))

static func data(index: int) -> Dictionary:
	return LEVELS[index]

static func has_next(index: int) -> bool:
	return index + 1 < LEVELS.size()
