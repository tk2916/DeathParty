class_name InkNode extends RefCounted

# Initialization
var parent_container : InkContainer
var path : String
var evaluation_stack_items : Array

# At runtime
const ALL_OPERATORS : Array[String] = ["+", "-", "/", "*", "%", "==", ">", "<", ">=", "<=", "!=", "!", "&&", "||", "MIN", "MAX"]
var evaluation_stack : Array = []

##EVAL STACK FUNCTIONS
func pop() -> Variant:
    return evaluation_stack.pop_back()
func push(item : Variant) -> void:
    evaluation_stack.push_back(item)

func _init(
    _container: InkContainer, 
    _path : String, 
    _evaluation_stack_items: Array, 
) -> void:
    parent_container = _container
    path = _path
    evaluation_stack_items = _evaluation_stack_items

func tostring() -> String:
    var eval_stack_str : String = "Evaluation stack: \n"
    for item : Variant in evaluation_stack:
        eval_stack_str = eval_stack_str + "Evaluation stack item: " + str(item) + "\n"
    return eval_stack_str

## EVALUATION STACK TO DETERMINE IF VISIBLE
func is_visible() -> bool:
    if evaluation_stack_items.is_empty():
        return true
    for item : Variant in evaluation_stack_items:
        if ALL_OPERATORS.has(item):
            var item_str : String = item
            logical_operation(item_str)
        elif item is Dictionary:
            var item_dict : Dictionary = item
            if item_dict.has("VAR?"):
                var variable_name : String = item_dict["VAR?"]
                push(SaveSystem.get_key(variable_name))
            elif item_dict.has("VAR="):
                var variable_name : String = item_dict["VAR="]
                SaveSystem.set_key(variable_name, pop())
    
    var result : bool = pop()
    evaluation_stack = []
    return result

func logical_operation(current_operator : String) -> Variant:
    var arg1 : Variant = pop()
    var arg2 : Variant = null
    if current_operator != "!": # ! is a single argument function
        arg2 = pop()
    return operate(current_operator, arg2, arg1)

func operate(op : String, arg1 : Variant, arg2 : Variant) -> Variant:
    if arg2 != null:
        if typeof(arg1) != typeof(arg2):
            #puts them both in true or false terms
            arg1 = !!arg1
            arg2 = !!arg2
    #print("OPERATING: ", arg1, op, arg2)
    var result : Variant#can be bool or number
    match (op):
        "+":
            result = arg1+arg2
        "-":
            result = arg1-arg2
        "/":
            result = arg1/arg2
        "*":
            result = arg1*arg2
        "%":
            result = arg1%arg2
        "==":
            result = arg1==arg2
        ">":
            result = arg1>arg2
        "<":
            result = arg1<arg2
        ">=":
            result = arg1>=arg2
        "<=":
            result = arg1<=arg2
        "!=":
            result = arg1!=arg2
        "!":
            result = !arg1
        "&&":
            result = arg1&&arg2
        "||":
            result = arg1||arg2
        "MIN":
            result = min(arg1,arg2)
        "MAX":
            result = max(arg1,arg2)
			
    push(result)
    print("operation result: ", arg1, op, arg2, "=", result)
    return result