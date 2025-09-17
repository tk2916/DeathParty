class_name InkContainer extends InkNode

'''
Sometimes, containers have names and sometimes they don't and they are referred to by path.
A container is an ARRAY in the tree.
'''

var name : String
var dialogue_lines : Array[InkNode] ## could be InkLineInfo or InkContainer
var dialogue_choices : Array[InkChoiceInfo] ## InkChoice info
var redirects : Dictionary[String, InkContainer]

func _init(
    _parent_container: InkContainer,
    _name : String,
    _path : String, 
    _evaluation_stack: Array[String] = [], 
    is_redirect : bool = false,
) -> void:
    #print("Initial container names: ", _name)
    super(_parent_container, _path, _evaluation_stack)
    name = _name
    if parent_container:
        if is_redirect:
            parent_container.redirects[self.name] = self
        else:
            parent_container.dialogue_lines.push_back(self)

func tostring() -> String:
    var export_str : String = "------CONTAINER " + name + " at " + path + ":\n"
    export_str = export_str + "---"+name+" Dialogue Lines: "
    if dialogue_lines.is_empty():
        export_str = export_str + "[]"
    export_str = export_str + "\n"
    for line in dialogue_lines:
        if line is InkLineInfo:
        #print("Parsing json: ", line, " ", line.path,   " container=", line is InkContainer, " redi    rect=", line is InkRedirect, " line=", line is InkLineInfo)
            export_str = export_str + line.tostring() + "\n"
    export_str = export_str + "---"+name+" Choices: "
    if dialogue_choices.is_empty():
        export_str = export_str + "[]"
    export_str = export_str + "\n"
    for choice : InkChoiceInfo in dialogue_choices:
        export_str = export_str + choice.tostring()
    return export_str