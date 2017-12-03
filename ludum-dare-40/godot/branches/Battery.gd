extends Control

signal depleted_battery

var score = 0 setget set_score

var life = 100
const MAX_LIFE = 100

export(float) var APP_DRAIN = 1.4
var drain_rate = 0
var refill_rate = 0

var previous_app_count = 0

const COLOR_LIFE_UP = Color('#43A047')
const COLOR_LIFE_LOW = Color('#F57F17')
const COLOR_LIFE_CRITICAL = Color('#F50057')


enum STATE { LIFE_HIGH, LIFE_MEDIUM, LIFE_REFILL, LIFE_LOW }
var state = null


func _ready():
	$"../AppIcons".connect("active_apps_count_changed", self, "_on_icons_count_changed")
	$"../Dock".connect("lowered_notifications", self, "_on_lowered_notifications")
	
	change_state(LIFE_HIGH)


func change_state(new_state):
	match new_state:
		LIFE_REFILL:
			$ProgressBar.modulate = COLOR_LIFE_UP
		LIFE_HIGH:
			$ProgressBar.modulate = Color(1.0, 1.0, 1.0)
			$AnimationPlayer.play('SETUP')
		LIFE_MEDIUM:
			$ProgressBar.modulate = COLOR_LIFE_LOW
			$AnimationPlayer.play('life_medium')
		LIFE_LOW:
			$ProgressBar.modulate = COLOR_LIFE_CRITICAL
			$AnimationPlayer.play('life_low')
	state = new_state


func _process(delta):
	var fill_rate = refill_rate - drain_rate
	life += fill_rate * delta
	life = clamp(life, 0, MAX_LIFE)

	if state != LIFE_REFILL and refill_rate - drain_rate > 0:
		change_state(LIFE_REFILL)
	elif state != LIFE_MEDIUM:
		if life < 50 and life >= 20:
			change_state(LIFE_MEDIUM)
	elif state != LIFE_LOW and life < 20:
		change_state(LIFE_LOW)


	if life == 0:
		emit_signal('depleted_battery')
		set_process(false)

	$ProgressBar.value = life


func _on_icons_count_changed(apps_count, apps_count_change):
	drain_rate = APP_DRAIN * apps_count
#	print(drain_rate)
	if apps_count_change == -1:
		self.score += 2


func _on_lowered_notifications(change):
	self.score += abs(change)


func set_score(value):
	score = value
	$Score/Label.text = str('%04d' % score)
