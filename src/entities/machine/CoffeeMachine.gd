extends Machine

const COFFEE_MACHINE_SOUND := preload("res://assets/sound/coffe_machine.mp3")

enum State { IDLE, PREPARING, READY }

@export var prep_seconds: float = 5.0

var state: State = State.IDLE

@onready var prep_timer: Timer = $PrepTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cup: Sprite2D = $Cup
@onready var machine_sound: AudioStreamPlayer = $MachineSound


func _ready() -> void:
	super._ready()
	Items.apply_icon(cup, "cafe", 30)
	prep_timer.one_shot = true
	prep_timer.wait_time = prep_seconds
	prep_timer.timeout.connect(_on_prep_timer_timeout)
	var looping_sound := COFFEE_MACHINE_SOUND.duplicate() as AudioStreamMP3
	looping_sound.loop = true
	machine_sound.stream = looping_sound
	_set_state(State.IDLE)


func interact(p: Player) -> void:
	match state:
		State.IDLE:
			_set_state(State.PREPARING)
			prep_timer.start()
		State.PREPARING:
			pass
		State.READY:
			if p.has_item():
				return
			p.hold("cafe")
			_set_state(State.IDLE)


func _on_prep_timer_timeout() -> void:
	_set_state(State.READY)


func _set_state(new_state: State) -> void:
	state = new_state
	cup.visible = (state == State.READY)
	if state == State.PREPARING:
		machine_sound.play()
	else:
		machine_sound.stop()
	match state:
		State.IDLE:
			sprite.play("idle")
		State.PREPARING:
			sprite.play("working")
		State.READY:
			sprite.play("idle")
