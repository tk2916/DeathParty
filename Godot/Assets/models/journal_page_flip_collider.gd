extends ObjectViewerInteractable

@export var flip_backwards : bool = false
@export var bookflip_instance : BookFlip

##INHERITED
func on_mouse_up():
	bookflip_instance.bookflip(flip_backwards)
	pass
