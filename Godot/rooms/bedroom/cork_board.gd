extends Interactable


@export var title:CanvasLayer


func _on_interaction_detector_player_interacted() -> void:
	title.visible=false
	Globals.polaroid_camera_ui.visible=true
	print("camera scene should be on")


func _on_tutorial_ui_toggle_corkboard_interactable(value: bool) -> void:
	if value == true:
		interaction_detector.monitoring = true
	else:
		interaction_detector.monitoring = false
