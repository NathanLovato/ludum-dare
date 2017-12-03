extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

	$Battery.connect('depleted_battery', self, 'game_over')
	$Dock.connect('notifications_over_limit', self, 'game_over')
	$GameOver/RetryButton.connect('button_down', self, 'restart_game')
	set_process_input(false)


func game_over():
#	$AppIcons.visible = false
	for child in $AppIcons/Icons.get_children():
		child.visible = false
	$Dock.visible = false
	$GameOver.visible = true

#	get_tree().set_pause(true)



func restart_game():
	get_tree().reload_current_scene()
