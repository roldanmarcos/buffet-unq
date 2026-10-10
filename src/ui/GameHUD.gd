extends CanvasLayer

signal main_menu_requested

@onready var money_label: Label = $UI/MoneyPanel/MoneyLabel
@onready var pause_menu: Control = $UI/PauseMenu
@onready var timer_label: Label = $UI/TimerPanel/TimerLabel

func set_time(seconds_left: float) -> void:
	var s := ceili(seconds_left)
	timer_label.text = "%d:%02d" % [floori(s / 60.0), s % 60]
	timer_label.modulate = Color.RED if s <= 10 else Color.WHITE

func _ready() -> void:
	$UI/PauseButton.pressed.connect(_on_pause_button_pressed)
	$UI/PauseMenu/CenterContainer/PauseOptions/ResumeButton.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/CenterContainer/PauseOptions/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	set_money(0)


func set_money(amount: int) -> void:
	money_label.text = "Plata: $%d" % amount


func _on_pause_button_pressed() -> void:
	pause_menu.show()
	get_tree().paused = true


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()


func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()
