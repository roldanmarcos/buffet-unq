extends Machine

enum SlotState { EMPTY, COOKING, READY }

const SLOT_ICON_SIZE := 40.0

@export var prep_seconds: float = 4.0

@onready var slots: Array[Sprite2D] = [$Slot1, $Slot2]
var slot_states: Array[SlotState] = [SlotState.EMPTY, SlotState.EMPTY]


func _ready() -> void:
	super._ready()
	for i in slots.size():
		var prep_timer: Timer = slots[i].get_node("PrepTimer")
		prep_timer.one_shot = true
		prep_timer.wait_time = prep_seconds
		prep_timer.timeout.connect(_on_prep_timer_timeout.bind(i))
		_set_slot_state(i, SlotState.EMPTY)


func interact(p: Player) -> void:
	if p.held_item == "pan":
		var empty_slot := slot_states.find(SlotState.EMPTY)
		if empty_slot == -1:
			return
		p.drop_item()
		_set_slot_state(empty_slot, SlotState.COOKING)
		slots[empty_slot].get_node("PrepTimer").start()
	elif not p.has_item():
		var ready_slot := slot_states.find(SlotState.READY)
		if ready_slot == -1:
			return
		p.hold("pancho")
		_set_slot_state(ready_slot, SlotState.EMPTY)


func _on_prep_timer_timeout(slot_index: int) -> void:
	_set_slot_state(slot_index, SlotState.READY)


func _set_slot_state(slot_index: int, new_state: SlotState) -> void:
	slot_states[slot_index] = new_state
	var slot := slots[slot_index]
	slot.visible = (new_state != SlotState.EMPTY)
	match new_state:
		SlotState.COOKING:
			Items.apply_icon(slot, "pan", SLOT_ICON_SIZE)
		SlotState.READY:
			Items.apply_icon(slot, "pancho", SLOT_ICON_SIZE)
