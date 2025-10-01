class_name ClickableJournalItem extends ThreeDCursorHover

@export var texture_rect : TextureRect
@export var item_resource : JournalItemResource

@export var background_fade_on_hover : bool = true
@export var background_fade : ColorRect
var background_fade_shader : ShaderMaterial
var og_zindex : int

func _ready() -> void:
	item_resource.refresh()
	if background_fade_on_hover:
		background_fade.visible = false
		background_fade_shader = background_fade.material
		background_fade_shader.set_shader_parameter("aspect_ratio", texture_rect.get_viewport().get_visible_rect().size)
		og_zindex = texture_rect.z_index

##INHERITED
func on_mouse_down() -> void:
	GuiSystem.inspect_journal_item(item_resource)
	if item_resource.talking_object_resource:
		print("Starting chat with talking object resource")
		item_resource.talking_object_resource.start_chat()

func enter_hover() -> void:
	super()
	var global_rect : Rect2 = texture_rect.get_global_rect()
	print("Global rect size, position: ", global_rect.size, " ", global_rect.position)
	background_fade_shader.set_shader_parameter("exclusion_size", global_rect.size)
	background_fade_shader.set_shader_parameter("exclusion_corner", global_rect.position)
	background_fade_shader.set_shader_parameter("exclusion_rotation", texture_rect.rotation_degrees)
	background_fade.visible = true
	texture_rect.z_index = 100

func exit_hover() -> void:
	super()
	background_fade.visible = false
	texture_rect.z_index = og_zindex
