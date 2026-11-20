extends CanvasLayer
class_name TutorialGuide

signal finished

const DEFAULT_RADIUS := 85.0
const DIM_ALPHA := 0.6
const STEP_DELAY := 0.45

@onready var dim: ColorRect = $Dim
@onready var dim_material: ShaderMaterial = dim.material
@onready var arrow: Node2D = $Arrow
@onready var message_panel: PanelContainer = $MessagePanel
@onready var message_label: Label = $MessagePanel/Margin/VBox/Message
@onready var continue_badge: PanelContainer = $ContinueBadge

var steps: Array = []
var current := -1
var running := false
var advancing := false
var time := 0.0
var spot_center := Vector2.ZERO
var spot_strength := 0.0
var badge_seen := false
var badge_pulsing := false


func _ready() -> void:
	hide()


func start(new_steps: Array) -> void:
	steps = new_steps
	current = -1
	running = true
	spot_strength = 0.0
	badge_seen = false
	show()
	_next_step()


func _next_step() -> void:
	current += 1
	if current >= steps.size():
		running = false
		hide()
		finished.emit()
		return
	var step: Dictionary = steps[current]
	if step.has("on_start"):
		step.on_start.call()
	message_label.text = step.text
	continue_badge.visible = not step.has("done")
	if continue_badge.visible:
		badge_pulsing = not badge_seen
		badge_seen = true
		continue_badge.scale = Vector2.ONE
	var target = _target_position(step)
	if target != null:
		spot_center = target
	message_panel.pivot_offset = message_panel.size / 2.0
	message_panel.scale = Vector2(0.9, 0.9)
	create_tween().tween_property(message_panel, "scale", Vector2.ONE, 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if not running:
		return
	visible = not get_tree().paused
	if get_tree().paused:
		return
	time += delta
	_update_continue_badge()
	var step: Dictionary = steps[current]
	var target = _target_position(step)
	_update_highlight(step, target, delta)
	if step.has("done") and not advancing and step.done.call():
		advancing = true
		await get_tree().create_timer(STEP_DELAY, false).timeout
		advancing = false
		_next_step()


func _unhandled_input(event: InputEvent) -> void:
	if not running or advancing or get_tree().paused:
		return
	if steps[current].has("done"):
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_next_step()


func _update_continue_badge() -> void:
	if not continue_badge.visible:
		return
	continue_badge.pivot_offset = continue_badge.size / 2.0
	if badge_pulsing:
		continue_badge.scale = Vector2.ONE * (1.0 + 0.06 * sin(time * 5.0))
	continue_badge.position = message_panel.position + Vector2(
		message_panel.size.x - continue_badge.size.x + 22.0,
		message_panel.size.y - 6.0
	)


func _target_position(step: Dictionary) -> Variant:
	if not step.has("target"):
		return null
	return step.target.call()


func _update_highlight(step: Dictionary, target: Variant, delta: float) -> void:
	var has_target := target != null
	spot_strength = move_toward(spot_strength, 1.0 if has_target else 0.0, delta * 4.0)
	if has_target:
		spot_center = spot_center.lerp(target, minf(1.0, delta * 10.0))
	var radius: float = step.get("radius", DEFAULT_RADIUS)
	var pulse := radius + 6.0 * sin(time * 4.0)
	dim_material.set_shader_parameter("center", spot_center)
	dim_material.set_shader_parameter("rect_size", dim.size)
	dim_material.set_shader_parameter("radius", pulse)
	dim_material.set_shader_parameter("strength", spot_strength * DIM_ALPHA)

	arrow.visible = has_target
	if not has_target:
		return
	var bounce := 8.0 * sin(time * 6.0)
	if spot_center.y - radius - 40.0 < 110.0:
		arrow.rotation = PI
		arrow.position = spot_center + Vector2(0, radius + 10.0 + bounce)
	else:
		arrow.rotation = 0.0
		arrow.position = spot_center - Vector2(0, radius + 10.0 + bounce)
