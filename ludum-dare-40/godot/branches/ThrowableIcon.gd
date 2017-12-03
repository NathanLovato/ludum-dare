extends Control

signal thrown_away
signal spawned

var start_position = Vector2()
var global_start_position = Vector2()
var last_position = Vector2()


enum STATES { INIT, SPAWN, IDLE, MOVE, RETURN, THROW }
var state = null

var velocity = Vector2()
var direction = Vector2()
const GRAVITY = Vector2(0, 200)

var throw_power = 0
var throw_speed = 0


var Y_POSITION_DESTROY = 1920
const RETURN_THRESHOLD = 30
const TWEEN_DURATION = 0.25
const TWEEN_RETURN_DELAY = 0.15

const COLOR_WHITE_TRANSPARENT = Color(1.0, 1.0, 1.0, 0.0)
const COLOR_WHITE_OPAQUE = Color(1.0, 1.0, 1.0, 1.0)


func _ready():
	change_state(INIT)

	$Randomizer/Button.connect("button_down", self, "_on_button_down")
	$Randomizer/Button.connect("button_up", self, "_on_button_up")

	start_position = rect_position
	global_start_position = get_global_position()

	set_process_input(false)


func _process(delta):
	match state:
		MOVE:
			last_position = rect_position
			rect_position = get_global_mouse_position() - global_start_position + start_position
			throw_power = last_position.distance_to(rect_position)
		THROW:
			velocity += GRAVITY
			rect_position += velocity * delta
			if rect_position.y > Y_POSITION_DESTROY:
				change_state(INIT)


func _on_button_down():
	if not state == IDLE:
		return
	change_state(MOVE)


func _on_button_up():
	if not state == MOVE:
		return
	if throw_power < RETURN_THRESHOLD:
		change_state(RETURN)
	else:
		change_state(THROW)


func change_state(new_state):
	state = new_state

#	if not new_state == INIT:
#		print('Node %s changed to state %s' % [get_path(), new_state])
	match new_state:
		SPAWN:
			$Randomizer/Label.visible = true
			$Tween.interpolate_property($Randomizer/Button, 'visible', false, true, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$Tween.interpolate_property(self, 'rect_scale', Vector2(), Vector2(1.0, 1.0), TWEEN_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
			$Tween.interpolate_property($Randomizer/Label, 'modulate', COLOR_WHITE_TRANSPARENT, COLOR_WHITE_OPAQUE, TWEEN_DURATION * 2, Tween.TRANS_BACK, Tween.EASE_OUT, TWEEN_DURATION + TWEEN_RETURN_DELAY)
			$Tween.start()
		IDLE:
			emit_signal('spawned')
			rect_position = start_position
			$Randomizer/Button.set_process_input(true)
		MOVE:
			last_position = start_position
			$Tween.interpolate_property($Randomizer/Label, 'modulate', $Randomizer/Label.modulate, COLOR_WHITE_TRANSPARENT, TWEEN_DURATION / 2, Tween.TRANS_BACK, Tween.EASE_OUT)
			$Tween.start()
		RETURN:
			$Tween.interpolate_property(self, 'rect_position', rect_position, start_position, TWEEN_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT, TWEEN_RETURN_DELAY)
			$Tween.interpolate_property($Randomizer/Label, 'modulate', $Randomizer/Label.modulate, COLOR_WHITE_OPAQUE, TWEEN_DURATION / 2, Tween.TRANS_BACK, Tween.EASE_OUT, TWEEN_RETURN_DELAY + TWEEN_DURATION)
			$Tween.start()
		THROW:
			direction = (rect_position - last_position).normalized()
			throw_speed = pow(throw_power, 1.2) * 4
			velocity = throw_speed * direction
			emit_signal("thrown_away")
		INIT:
			$Randomizer/Button.visible = false
			$Randomizer/Label.visible = false
			rect_scale = Vector2()
			print(rect_scale)
			$Randomizer/Label.modulate = COLOR_WHITE_TRANSPARENT


func _on_Tween_tween_completed( object, key ):
	match state:
		RETURN:
			change_state(IDLE)
		SPAWN:
			change_state(IDLE)
