class_name LineInfo

var speaker : String
var line : String
var text_color : String
var name_color : String
var no_animation : bool

func _init(
	_speaker : String, 
	_line : String, 
	_text_color : String, 
	_name_color : String, 
	_no_animation : bool
) -> void:
	speaker = _speaker
	line = _line
	text_color = _text_color
	name_color = _name_color
	no_animation = _no_animation
	
