extends Resource

var VariableDict : Dictionary = {}

@export var name : String = "Player1"
@export var inventory : Dictionary[String, int] = {}
@export var tasks : Array[String] = []
@export var journal_entries : Dictionary[String, bool] = {}

@export var time : float = 22.00
@export var intelligence : int = 10
@export var strength : int = 10
@export var empathy : int = 10
@export var sleaziness : int = 10
@export var current_outtfit : String = "none"
