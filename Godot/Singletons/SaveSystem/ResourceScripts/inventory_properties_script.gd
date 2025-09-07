class_name InventoryItemResource extends Resource

@export var name : String
@export var description : String
@export var model : PackedScene
@export var inventory_scale : float = 1.0
@export var inventory_position : Vector2 = Vector2.ZERO

@export var amount_owned : int = 0
@export var dialogue_on_first_view : JSON
var viewed : bool = false
