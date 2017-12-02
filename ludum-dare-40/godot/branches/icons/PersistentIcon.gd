extends TextureButton

signal notification_count_changed

var count = 0
export(float) var spawn_rate = 0.4


func _ready():
	add_to_count(0)
	$Timer.wait_time = spawn_rate
	$Timer.start()


func _on_Timer_timeout():
	add_to_count(1)


func add_to_count(value):
	count += value
	count = clamp(count, 0, 99)
	$"Notification/Label".text = str(count)
	emit_signal("notification_count_changed", count)


func _on_button_down():
	add_to_count(-1)
