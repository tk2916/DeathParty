extends Button

@export var phone : Control
@export var apps : Array[Control]

func _pressed() -> void:
	var no_apps_visible : bool = true
	for app in apps:
		if app.visible:
			no_apps_visible = false
			app.visible = false
	if no_apps_visible:
		GuiSystem.hide_gui("Phone")
