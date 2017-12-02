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

export(float) var timer_duration = 2.0

var active_apps_count = 0


func _ready():
	for x in range($Icons.get_child_count()):
		icons_array.append([])
		var IconRow = $Icons.get_child(x)
		for y in range(IconRow.get_child_count()):
			var ThrowableIcon = IconRow.get_child(y)
			icons_array[x].append(ThrowableIcon)

			ThrowableIcon.connect("thrown_away", self, 'update_apps_count', [-1])
			ThrowableIcon.connect("spawned", self, 'update_apps_count', [1])

	icons_array_size = Vector2(icons_array.size(), icons_array[0].size())

	var spawn_indices = []
	for x in range(icons_array_size.x):
		for y in range(icons_array_size.y):
			spawn_indices.append(Vector2(x, y))

	spawn_order = shuffle(spawn_indices)

	$SpawnTimer.wait_time = timer_duration
	$SpawnTimer.start()
	$SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout")


func update_apps_count(value):
	active_apps_count += value
	emit_signal('active_apps_count_changed', active_apps_count)


func _on_SpawnTimer_timeout():
	var node_indices = spawn_order[spawn_index]
	spawn_node = icons_array[node_indices.x][node_indices.y]

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
