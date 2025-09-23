extends ObjectViewerInteractable
class_name JournalTab

@export var texture_open : CompressedTexture2D
@export var texture_closed : CompressedTexture2D

@export var sprite3d : Sprite3D

@export var flip_to_page : int

var disabled : bool = false

signal tab_pressed

func _ready() -> void:
	sprite3d.texture = texture_closed
	
func on_tab_pressed() -> void:
	if disabled: return
	print(self, " Pressed!")
	tab_pressed.emit()

func tab_opened() -> void:
	sprite3d.texture = texture_open

func tab_closed() -> void:
	sprite3d.texture = texture_closed

##INHERITED METHODS (OVERRIDDEN)
func enter_hover() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func exit_hover() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func on_mouse_up() -> void:
	on_tab_pressed()
