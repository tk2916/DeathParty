extends Button

@export var notification_root : PhoneNotification
var contact_resource : ChatResource

func _on_mouse_entered() -> void:
	if notification_root.seen:
		notification_root.slide(true)

func _on_mouse_exited() -> void:
	if notification_root.seen:
		notification_root.slide(false)

func _on_pressed() -> void:
	GuiSystem.show_phone(contact_resource)
	notification_root.queue_free()
