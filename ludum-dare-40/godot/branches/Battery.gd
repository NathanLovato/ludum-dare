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




func _ready():
	$"../AppIcons".connect("active_apps_count_changed", self, "_on_icons_count_changed")
	$"../Dock".connect("lowered_notifications", self, "_on_lowered_notifications")


func _process(delta):
	var fill_rate = refill_rate - drain_rate
	life += fill_rate * delta
	life = clamp(life, 0, MAX_LIFE)

	if refill_rate - drain_rate > 0:
		$Battery/HBoxContainer/ProgressBar.modulate = COLOR_LIFE_UP
	elif life < 50 and life >= 20:
		$Battery/HBoxContainer/ProgressBar.modulate = COLOR_LIFE_LOW
	elif life < 20:
		$Battery/HBoxContainer/ProgressBar.modulate = COLOR_LIFE_CRITICAL


	if life == 0:
		emit_signal('depleted_battery')
		set_process(false)

	$Battery/HBoxContainer/ProgressBar.value = life


func _on_icons_count_changed(apps_count, apps_count_change):
	drain_rate = APP_DRAIN * apps_count
#	print(drain_rate)
	if apps_count_change == -1:
		self.score += 2


func _on_lowered_notifications(change):
	self.score += abs(change)


func set_score(value):
	score = value
	$Battery/Score/Label.text = str('%04d' % score)
