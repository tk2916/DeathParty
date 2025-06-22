extends Control

@export var panel : Panel
var activated_offset_right : float
var activated_offset_left : float

func _ready() -> void:
	activated_offset_right = panel.offset_right
	activated_offset_left = panel.offset_left
	deactivate()
	
func activate():
	panel.offset_right = activated_offset_right
	panel.offset_left = activated_offset_left
		
func deactivate():
	panel.offset_right = 0
	panel.offset_left = 0
	
