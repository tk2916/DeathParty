class_name InkRedirect extends InkNode

var redirect : String

func _init(
    _parent_container: InkContainer,
    _redirect : String,
    _path : String, 
    _evaluation_stack: Array = [], 
    _condition : bool = true
) -> void:
    super(_parent_container, _path, _evaluation_stack, _condition)
    redirect = _redirect
    _parent_container.dialogue_lines.push_back(self)

func tostring() -> String:
    return "Redirect: " + redirect + " " + super()