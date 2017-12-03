# Track empty app slots and shuffle them
# Increase the app spawn speed over time
# Use array of empty/filled slots to affect battery life
extends Control

signal active_apps_count_changed

var icons_array = []
var icons_array_size = Vector2()
var spawn_node = null

var spawn_order = []
var spawn_index = 0

export(float) var start_timer_duration = 2.0
export(float) var min_timer_duration = 0.8
var timer_duration = start_timer_duration


var active_apps_count = 0


func _ready():
	for child in $Icons.get_children():
		icons_array.append(child)

		child.connect("thrown_away", self, 'update_apps_count', [-1])
		child.connect("spawned", self, 'update_apps_count', [1])

	icons_array_size = icons_array.size()

	var spawn_indices = []
	for x in range(icons_array_size):
		spawn_indices.append(x)

	spawn_order = shuffle(spawn_indices)

	$SpawnTimer.wait_time = timer_duration
	$SpawnTimer.start()
	$SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout")


func _process(delta):
	if timer_duration > min_timer_duration:
		timer_duration -= delta / 10
	else:
		timer_duration = min_timer_duration
		set_process(false)


func update_apps_count(value):
	active_apps_count += value
	emit_signal('active_apps_count_changed', active_apps_count, value)


func _on_SpawnTimer_timeout():
	$SpawnTimer.wait_time = timer_duration

	var index = spawn_order[spawn_index]
	spawn_node = icons_array[index]

	if spawn_node.state == spawn_node.INIT:
		spawn_node.change_state(spawn_node.SPAWN)

	spawn_index += 1
	if spawn_index > spawn_order.size() - 1:
		shuffle(spawn_order)
		spawn_index = 0


func shuffle(array):
	var array_size = len(array)

	for x in range(array_size, 0, -1):
		randomize()
		var index = x - 1
		var rand_index = randi() % array_size

		var temp_value = array[index]
		array[index] = array[rand_index]
		array[rand_index] = temp_value
	return array
