extends ObjectViewerInteractable

@export var flip_backwards : bool = false
@export var bookflip_instance : BookFlip

func _ready() -> void:
	print("AnimatableBody3D collision_layer: ", self.collision_layer)
	print("AnimatableBody3D layer binary: ", String.num_int64(self.collision_layer, 2))
	print("Object has layer 7: ", (self.collision_layer & 64) > 0)

##INHERITED
func on_mouse_up():
	bookflip_instance.bookflip(flip_backwards)
	pass
