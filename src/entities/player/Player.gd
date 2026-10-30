extends CharacterBody2D
class_name Player

const FOOTSTEP_PATHS := [
	"res://assets/sound/footstep.mp3",
	"res://assets/sound/footstep_1.mp3",
]
const SPEED = 300.0
const CHARACTER_META := "character"
const CHARACTERS := {
	"chico": preload("res://assets/characters/chico.tres"),
	"chica": preload("res://assets/characters/chica.tres"),
}
# Dónde se ve lo que lleva en la mano según para dónde mira.
const HELD_ITEM_OFFSETS := {
	"down": Vector2(-16, 20),
	"up": Vector2(34, 12),
	"left": Vector2(-30, 16),
	"right": Vector2(30, 16),
}
@export var MARGIN: Vector2 = Vector2(40, 76)

var held_item: String = ""
var held_value: int = 0
var footstep_sounds: Array[AudioStream] = []
var last_footstep_index := -1
@onready var held_item_visual: Sprite2D = $HeldItem
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footstep_player: AudioStreamPlayer2D = $FootstepSound
@onready var footstep_timer: Timer = $FootstepTimer

var was_walking := false
var facing := "down"


func _ready() -> void:
	sprite.sprite_frames = CHARACTERS[get_tree().get_meta(CHARACTER_META, "chico")]
	_update_animation(Vector2.ZERO)
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
	_update_animation(direction)
	
	var screen: Rect2 = get_viewport_rect()
	global_position = global_position.clamp(screen.position + MARGIN, screen.end - MARGIN)


func _update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "right" if direction.x > 0.0 else "left"
		else:
			facing = "down" if direction.y > 0.0 else "up"
	var animation := ("walk_" if direction != Vector2.ZERO else "idle_") + facing
	# De frente tiene cuadros con el brazo sujetando lo que lleva.
	if facing == "down" and has_item():
		animation += "_holding"
	if sprite.animation != animation:
		sprite.play(animation)
	held_item_visual.position = HELD_ITEM_OFFSETS[facing]


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
	Items.apply_icon(held_item_visual, item, Items.HAND_SIZE)
	held_item_visual.rotation_degrees = 90.0 if item == "pancho" else 0.0
	held_item_visual.visible = true

func has_item() -> bool:
	return held_item != ""

func drop_item() -> void:
	held_item = ""
	held_value = 0
	held_item_visual.visible = false
