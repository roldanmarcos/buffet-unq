extends CharacterBody2D
class_name Player

const FOOTSTEP_PATHS := [
	"res://assets/sound/footstep.mp3",
	"res://assets/sound/footstep_1.mp3",
]
const SPEED = 300.0
@export var MARGIN: Vector2 = Vector2(36, 57)

var held_item: String = ""
var held_value: int = 0
var footstep_sounds: Array[AudioStream] = []
var last_footstep_index := -1
@onready var held_item_visual: Sprite2D = $HeldItem
@onready var footstep_player: AudioStreamPlayer2D = $FootstepSound
@onready var footstep_timer: Timer = $FootstepTimer

var was_walking := false


func _ready() -> void:
	for sound_path in FOOTSTEP_PATHS:
		var sound := load(sound_path) as AudioStream
		if sound:
			footstep_sounds.append(sound)
	footstep_timer.timeout.connect(_on_footstep_timer_timeout)


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * SPEED

	move_and_slide()
	var is_walking := direction.length_squared() > 0.0
	if is_walking and not was_walking:
		_play_footstep()
		footstep_timer.start()
	elif not is_walking and was_walking:
		footstep_timer.stop()
		footstep_player.stop()
	was_walking = is_walking
	
	var screen: Rect2 = get_viewport_rect()
	global_position = global_position.clamp(screen.position + MARGIN, screen.end - MARGIN)


func _on_footstep_timer_timeout() -> void:
	if velocity.length_squared() > 0.0:
		_play_footstep()


func _play_footstep() -> void:
	if footstep_sounds.is_empty():
		return
	var sound_index := randi_range(0, footstep_sounds.size() - 1)
	if footstep_sounds.size() > 1 and sound_index == last_footstep_index:
		sound_index = (sound_index + 1) % footstep_sounds.size()
	last_footstep_index = sound_index
	footstep_player.stream = footstep_sounds[sound_index]
	footstep_player.play()

func hold(item: String, value: int = 0) -> void:
	held_item = item
	held_value = value
	Items.apply_icon(held_item_visual, item, 60)
	held_item_visual.visible = true

func has_item() -> bool:
	return held_item != ""

func drop_item() -> void:
	held_item = ""
	held_value = 0
	held_item_visual.visible = false
