extends Container

signal notifications_over_limit
signal lowered_notifications


func _ready():
	for child in $IconRow.get_children():
		child.connect('notification_count_changed', self, '_on_notification_count_changed')


func _on_notification_count_changed(count, change):
	if count > 10:
		emit_signal('notifications_over_limit')
	if change < 0:
		emit_signal('lowered_notifications', change)

