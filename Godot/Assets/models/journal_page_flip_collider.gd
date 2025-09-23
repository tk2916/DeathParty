class_name PageFlipper extends ObjectViewerInteractable

@export var flip_backwards : bool = false
@export var bookflip_instance : BookFlip

var og_viewport : Viewport

##INHERITED
func on_mouse_up() -> void:
	if Interact.grabbed_control: return
	bookflip_instance.bookflip(flip_backwards)

func enter_hover() -> void:
	if bookflip_instance.cur_subviewport == null: return
	og_viewport = get_viewport()
	#Interact.set_active_subviewport(bookflip_instance.cur_subviewport)
	
func exit_hover() -> void:
	if bookflip_instance.cur_subviewport == null: return
	#Interact.set_active_subviewport(og_viewport)
