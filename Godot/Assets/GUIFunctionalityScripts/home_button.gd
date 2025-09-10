extends Button

@export var phone : Control
@export var apps : Array[Control]

func _pressed() -> void:
	var no_apps_visible : bool = true
	for app in apps:
		if app.visible:
			no_apps_visible = false
			if app is MessageAppBox:
				var message_app : MessageAppBox = app
				message_app.on_back_pressed()
			app.visible = false
	if no_apps_visible:
		GuiSystem.hide_gui("Phone")
