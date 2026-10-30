extends CanvasLayer

signal main_menu_requested
signal restart_requested
signal next_level_requested

@onready var result_menu: Control = $UI/ResultMenu
@onready var result_title: Label = $UI/ResultMenu/CenterContainer/ResultOptions/TitleLabel
@onready var result_score: Label = $UI/ResultMenu/CenterContainer/ResultOptions/ScoreLabel
@onready var money_label: Label = $UI/MoneyPanel/MoneyLabel
@onready var pause_menu: Control = $UI/PauseMenu
@onready var timer_label: Label = $UI/TimerPanel/TimerLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var restart_button: TextureButton = $UI/ResultMenu/CenterContainer/ResultOptions/RestartButton
@onready var next_level_button: TextureButton = $UI/ResultMenu/CenterContainer/ResultOptions/NextLevelButton
const HEART_FULL := preload("res://assets/ui/corazon_lleno.png")
const HEART_EMPTY := preload("res://assets/ui/corazon_vacio.png")
const WIN_SOUND := preload("res://assets/sound/win.mp3")
const LOST_SOUND := preload("res://assets/sound/lost.mp3")
@onready var result_sound: AudioStreamPlayer = $ResultSound
@onready var hearts := [$UI/LivesPanel/Heart1, $UI/LivesPanel/Heart2, $UI/LivesPanel/Heart3]

func set_time(seconds_left: float) -> void:
	var s := ceili(seconds_left)
	timer_label.text = "%d:%02d" % [floori(s / 60.0), s % 60]
	timer_label.modulate = Color.RED if s <= 10 else Color.WHITE

func set_lives(lives_left: int) -> void:
	for i in hearts.size():
		hearts[i].texture = HEART_FULL if i < lives_left else HEART_EMPTY

func _ready() -> void:
	$UI/PauseButton.pressed.connect(_on_pause_button_pressed)
	$UI/PauseMenu/CenterContainer/PauseOptions/ResumeButton.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/CenterContainer/PauseOptions/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	restart_button.pressed.connect(func(): restart_requested.emit())
	next_level_button.pressed.connect(func(): next_level_requested.emit())
	$UI/ResultMenu/CenterContainer/ResultOptions/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	set_money(0)
	set_lives(3)


func set_money(amount: int) -> void:
	money_label.text = "%d" % amount


func _on_pause_button_pressed() -> void:
	pause_menu.show()
	get_tree().paused = true


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()


func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()


func show_level_intro(level_number: int) -> void:
	level_label.text = "Nivel %d" % level_number
	level_label.modulate.a = 1.0
	level_label.show()
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(level_label, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(level_label.hide)


func show_level_result(won: bool, score: int, level_number: int, has_next_level: bool) -> void:
	pause_menu.hide()
	level_label.hide()
	if not won:
		result_title.text = "Perdiste: se fueron 3 clientes"
	elif has_next_level:
		result_title.text = "¡Nivel %d completado!" % level_number
	else:
		result_title.text = "¡Ganaste el juego!"
	result_title.add_theme_font_size_override("font_size", 32 if won else 22)
	var show_next := won and has_next_level
	next_level_button.visible = show_next
	restart_button.visible = not show_next
	result_score.text = "Recaudaste: $%d" % score
	result_menu.show()
	result_sound.stream = WIN_SOUND if won else LOST_SOUND
	result_sound.play()
	get_tree().paused = true
