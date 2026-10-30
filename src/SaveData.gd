class_name SaveData

# Progreso guardado en la compu (o en el navegador, en la versión web).
const PATH := "user://progreso.cfg"
const SECTION := "progreso"

static func unlocked_level() -> int:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return 0
	return config.get_value(SECTION, "nivel_desbloqueado", 0)

static func unlock_level(index: int) -> void:
	if index <= unlocked_level():
		return
	var config := ConfigFile.new()
	config.load(PATH)
	config.set_value(SECTION, "nivel_desbloqueado", index)
	config.save(PATH)
