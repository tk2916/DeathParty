extends Resource

const possible_items : Array = ["Knife", "Map", "Spray Paint", "Key", "Phone"]

var VariableDict : Dictionary = {}

@export var name : String = "Player1"
@export var inventory : Dictionary[String, int] = {}

@export var time : float = 22.00
@export var intelligence : int = 10
@export var strength : int = 10
@export var empathy : int = 10
@export var sleaziness : int = 10
@export var current_outtfit : String = "none"
