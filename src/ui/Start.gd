extends Control

const GAME_SCENE := "res://src/Main.tscn"
const START_SOUND := preload("res://assets/sound/start.mp3")

@onready var intro_layer: CenterContainer = $IntroLayer
@onready var menu_layer: CenterContainer = $MenuLayer
@onready var tutorial_layer: Control = $TutorialLayer
@onready var level_layer: CenterContainer = $LevelLayer
@onready var level_buttons: Array[TextureButton] = [
	$LevelLayer/Levels/Level1Button,
	$LevelLayer/Levels/Level2Button,
]
@onready var intro_timer: Timer = $IntroTimer
@onready var tutorial_sprite: Sprite2D = $TutorialLayer/TutorialSprite


func _ready() -> void:
	$MenuLayer/Menu/StartButton.pressed.connect(_on_start_pressed)
	$MenuLayer/Menu/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$TutorialLayer/BackButton.pressed.connect(_on_back_pressed)
	$LevelLayer/Levels/BackButton.pressed.connect(_on_back_pressed)
	for i in level_buttons.size():
		level_buttons[i].pressed.connect(_start_level.bind(i))
	intro_timer.timeout.connect(_on_intro_timer_timeout)
	get_viewport().size_changed.connect(_center_tutorial_sprite)
	_center_tutorial_sprite()
	if get_tree().has_meta("returning_to_main_menu"):
		get_tree().remove_meta("returning_to_main_menu")
		intro_timer.stop()
		intro_layer.hide()
		menu_layer.show()
		return
	$IntroSound.stream = START_SOUND
	$IntroSound.play()
	intro_timer.start()


func _on_intro_timer_timeout() -> void:
	intro_layer.hide()
	menu_layer.show()


func _on_start_pressed() -> void:
	# Si todavía no ganó ningún nivel, arranca directo en el 1.
	if SaveData.unlocked_level() == 0:
		_start_level(0)
		return
	for i in level_buttons.size():
		level_buttons[i].disabled = i > SaveData.unlocked_level()
	menu_layer.hide()
	level_layer.show()


func _start_level(index: int) -> void:
	Levels.set_current(get_tree(), index)
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_tutorial_pressed() -> void:
	menu_layer.hide()
	tutorial_layer.show()


func _on_back_pressed() -> void:
	tutorial_layer.hide()
	level_layer.hide()
	menu_layer.show()


func _center_tutorial_sprite() -> void:
	tutorial_sprite.position = get_viewport_rect().size / 5.0
