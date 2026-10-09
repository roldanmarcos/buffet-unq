extends Machine

enum State { IDLE, PREPARING, READY }

@export var prep_seconds: float = 5.0

var state: State = State.IDLE

@onready var prep_timer: Timer = $PrepTimer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	super._ready()
	prep_timer.one_shot = true
	prep_timer.wait_time = prep_seconds
	prep_timer.timeout.connect(_on_prep_timer_timeout)
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
	match state:
		State.IDLE:
			sprite.modulate = Color.WHITE
		State.PREPARING:
			sprite.modulate = Color(0.5, 0.5, 0.5)
		State.READY:
			sprite.modulate = Color(1.0, 0.85, 0.4)
