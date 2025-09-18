class_name InkChoiceInfo extends InkNode

var text : String
var jump : String #hierarchy copy

func _init( 
	_container: InkContainer,
	_path : String,
	_text : String, 
	_jump : String,
	_condition_stack: Array = [], 
) -> void:
	super(_container, _path, _condition_stack)
	parent_container.dialogue_choices.push_back(self)
	text = _text
	jump = _jump

func tostring() -> String:
	var eval_stack : String = super()
	return "Choice: " + text + " | Jump: " + jump + " " + eval_stack
