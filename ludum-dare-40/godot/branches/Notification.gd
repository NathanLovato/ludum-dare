extends TextureRect

const TWEEN_DURATION = 0.3

enum STATES { INACTIVE, ACTIVE, TWEENING }
var state = null


func _ready():
	visible = false
	rect_scale = Vector2(0, 0)

	$"..".connect('notification_count_changed', self, "_on_notification_count_changed")


func _on_notification_count_changed(new_count):
	if new_count == 0:
		change_state(INACTIVE)
	elif state == INACTIVE:
		change_state(ACTIVE)


func change_state(new_state):
	state = new_state

	match new_state:
		ACTIVE:
			$Tween.interpolate_property(self, 'rect_scale', rect_scale, Vector2(1, 1), TWEEN_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
			$Tween.start()
			visible = true
		INACTIVE:
			$Tween.interpolate_property(self, 'rect_scale', rect_scale, Vector2(0.0, 0.0), TWEEN_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
			$Tween.start()



func _on_Tween_tween_completed( object, key ):
	if state == INACTIVE:
		visible = false
