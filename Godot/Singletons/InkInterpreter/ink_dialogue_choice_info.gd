class_name InkChoiceInfo extends RefCounted

var text : String
var jump : Array #hierarchy copy

func _init( _text : String, _jump : Array) -> void:
	text = _text
	jump = _jump
