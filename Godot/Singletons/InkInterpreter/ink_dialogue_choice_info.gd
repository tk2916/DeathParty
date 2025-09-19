class_name InkChoiceInfo extends InkNode

var text : String
var jump : String
var once_only : bool
var id : String

func _init( 
	_container: InkContainer,
	_path : String,
	_text : String, 
	_jump : String,
	_condition_stack: Array = [],
	_once_only: bool = false,
) -> void:
	super(_container, _path, _condition_stack)
	parent_container.dialogue_choices.push_back(self)
	text = _text
	jump = _jump
	once_only = _once_only

	id = text.substr(4)+jump
	if once_only and SaveSystem.key_exists(id+"-viewed") == false:
		SaveSystem.set_key(id+"-viewed", false)

func set_viewed() -> void:
	if once_only:
		SaveSystem.set_key(id+"-viewed", true)

## INHERITED
func is_visible() -> bool:
	if once_only and SaveSystem.get_key(id+"-viewed"):
		return false
	else:
		return super()

func tostring() -> String:
	var eval_stack : String = super()
	return "Choice: " + text + " | Jump: " + jump + " " + eval_stack
