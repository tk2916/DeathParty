extends Control

@onready var list = %BindingList
@onready var bindingItemPrefab = preload("res://input_binding_item.tscn")

var buttonToChange 
var actionInputToChange
var changingInput = false

@onready var editableInputs = {
	"move_left" : "Left",
	"move_right" : "Right",
	"move_up" : "Up",
	"move_down" : "Down",
	"jump" : "Jump",
	"interact" : "Interact"
	
}

func _ready():
	PopulateList()
	
	
func PopulateList():
	InputMap.load_from_project_settings()
	for action in InputMap.get_actions():
		if !editableInputs.has(action):
			continue
		var bindingItem = bindingItemPrefab.instantiate()
		var labelAction = bindingItem.find_child("ActionName")
		var inputA = bindingItem.find_child("InputA")
		var inputB = bindingItem.find_child("InputB")
		labelAction.text = editableInputs[action]
		var inputs = InputMap.action_get_events(action)
		
		if inputs.size() == 0:
			inputA.text = "-"
			inputB.text = "-"
		elif inputs.size() == 1:
			if inputs.size() == 1:
				inputA.text = inputs[0].as_text().trim_suffix(" (Physical)")
				inputB.text = "-"
		elif inputs.size() > 1:
			inputA.text = inputs[0].as_text().trim_suffix(" (Physical)")
			inputB.text = inputs[1].as_text().trim_suffix(" (Physical)")
		
		list.add_child(bindingItem)
		inputA.pressed.connect(ButtonPressed.bind(inputA,action,0))
		inputB.pressed.connect(ButtonPressed.bind(inputB,action,1))
	
func ButtonPressed(inputButton,action,index):
	if Input.is_action_just_released("remove_input"):
		RemoveInput(action,index)
		inputButton.text = "-"
	else:
		buttonToChange = inputButton
		actionInputToChange = InputMap.action_get_events(action)[index]
		changingInput = true
		
func RemoveInput(action,index):
	InputMap.action_get_events(action)[index].physical_keycode = Key.KEY_NONE
	InputMap.action_get_events(action)[index].keycode = Key.KEY_NONE
	
func AddInput(action,index):
	var actionInputs = InputMap.action_get_events(action)[index]
	#if(actionInputs.size > index):
		
	#else:
		
	
func _input(event):
	if changingInput:
		if(event is InputEventKey):
			buttonToChange.text = event.as_text_keycode()
			actionInputToChange.keycode = event.keycode
			actionInputToChange.physical_keycode = event.keycode
			changingInput = false
