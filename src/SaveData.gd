class_name SaveData

const PATH := "user://progreso.cfg"
const SECTION := "progreso"

static func unlocked_level() -> int:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return 0
	return config.get_value(SECTION, "nivel_desbloqueado", 0)

static func hot_dogs_tutorial_seen() -> bool:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return false
	return config.get_value(SECTION, "vio_tutorial_panchos", false)

static func mark_hot_dogs_tutorial_seen() -> void:
	var config := ConfigFile.new()
	config.load(PATH)
	config.set_value(SECTION, "vio_tutorial_panchos", true)
	config.save(PATH)

static func unlock_level(index: int) -> void:
	if index <= unlocked_level():
		return
	var config := ConfigFile.new()
	config.load(PATH)
	config.set_value(SECTION, "nivel_desbloqueado", index)
	config.save(PATH)
