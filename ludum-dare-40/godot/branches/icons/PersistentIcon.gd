extends TextureButton

signal notification_count_changed

var count = 0
export(float) var spawn_rate = 0.4
export(bool) var active

enum STATES { INACTIVE, ACTIVE }
var state = null


func _ready():
	if active:
		change_state(ACTIVE)
	else:
		change_state(INACTIVE)


func change_state(new_state):
	state = new_state

	match state:
		INACTIVE:
			visible = false
			$Timer.stop()
		ACTIVE:
			visible = true
			add_to_count(0)
			$Timer.wait_time = spawn_rate
			$Timer.start()



func _on_Timer_timeout():
	add_to_count(1)


func _on_button_down():
	add_to_count(-1)


func add_to_count(value):
	count += value
	count = clamp(count, 0, 99)
	$"Notification/Label".text = str(count)
	emit_signal("notification_count_changed", count, value)
