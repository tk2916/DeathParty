class_name PlayerData extends Resource

#This will be dynamically added to with Ink
var variable_dict : Dictionary[String, Variant] = {
    time = 22.0,
    intelligence = 10,
    strength = 10,
    empathy = 10,
    sleaziness = 10,
}

@export var name : String = "Player1"
var journal_entries : Dictionary[String, bool] = {}
var tasks : Array[String] = []
