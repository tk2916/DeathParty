class_name InkLineInfo extends InkNode

var speaker : String
var text : String

func _init( 
	_parent_container: InkContainer,
	_path : String,
	_speaker : String,
	_text : String, 
	_condition_stack: Array[String] = [], 
) -> void:
	super(_parent_container, _path, _condition_stack)
	speaker = _speaker
	text = _text
	if parent_container:
		parent_container.dialogue_lines.push_back(self)

func tostring() -> String:
	var eval_stack : String = super()
	return "Line: " + speaker + " | Text: " + text + " " + eval_stack