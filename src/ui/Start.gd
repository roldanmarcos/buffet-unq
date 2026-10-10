extends Control

const GAME_SCENE := "res://src/Main.tscn"

@onready var intro_layer: CenterContainer = $IntroLayer
@onready var menu_layer: CenterContainer = $MenuLayer
@onready var tutorial_layer: Control = $TutorialLayer
@onready var intro_timer: Timer = $IntroTimer
@onready var tutorial_sprite: Sprite2D = $TutorialLayer/TutorialSprite


func _ready() -> void:
	$MenuLayer/Menu/StartButton.pressed.connect(_on_start_pressed)
	$MenuLayer/Menu/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$TutorialLayer/BackButton.pressed.connect(_on_back_pressed)
	intro_timer.timeout.connect(_on_intro_timer_timeout)
	get_viewport().size_changed.connect(_center_tutorial_sprite)
	_center_tutorial_sprite()
	intro_timer.start()


func _on_intro_timer_timeout() -> void:
	intro_layer.hide()
	menu_layer.show()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_tutorial_pressed() -> void:
	menu_layer.hide()
	tutorial_layer.show()


func _on_back_pressed() -> void:
	tutorial_layer.hide()
	menu_layer.show()


func _center_tutorial_sprite() -> void:
	tutorial_sprite.position = get_viewport_rect().size / 2.0
