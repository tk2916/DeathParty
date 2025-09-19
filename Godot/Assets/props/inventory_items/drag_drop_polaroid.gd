class_name DragDropPolaroid extends ObjectViewerDraggable
var tree : SceneTree
var bookflip_instance : BookFlip

#var grabbed_control : DragDropControl = null
#var og_grabbed_control : DragDropControl = null

@onready var og_position : Vector3 = position
var mesh : MeshInstance3D

var item_resource : InventoryItemResource

var og_scale : Vector3

func _init(_item_resource : InventoryItemResource) -> void:
	super()
	item_resource = _item_resource
	og_scale = Vector3.ONE*item_resource.inventory_scale
	scale = og_scale

func _ready() -> void:
	super()
	tree = get_tree()
	mesh = Utils.find_first_child_of_class(self, MeshInstance3D)
	
func return_to_og_position() -> void:
	position = og_position

##INHERITED
func enter_hover() -> void:
	if tree == null: return
	var tween := tree.create_tween()
	tween.tween_property(self, "scale", og_scale*1.2, .2)
	
func exit_hover() -> void:
	if tree == null: return
	var tween := tree.create_tween()
	tween.tween_property(self, "scale", og_scale, .2)
	
func on_mouse_down()-> void:
	super()
	self.set_collision_layer_value(1, false)
	self.set_collision_layer_value(4, false)
	
func on_mouse_up() -> void:
	super()
	self.set_collision_layer_value(1, true)
	self.set_collision_layer_value(4, true)
	if Interact.grabbed_control and Interact.grabbed_control is DragDropControl:
		Interact.grabbed_control.mouse_up_polaroid(item_resource, self)
		Interact.grabbed_control.exit_hover()
	#pass_input()
