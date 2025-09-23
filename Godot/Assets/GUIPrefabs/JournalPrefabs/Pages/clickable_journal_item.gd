class_name ClickableJournalItem extends ThreeDCursorHover

@export var texture_rect : TextureRect
@export var item_resource : JournalItemResource

@export var background_fade_on_hover : bool = true
@export var background_fade : ColorRect
var background_fade_shader : ShaderMaterial

func _ready() -> void:
	if background_fade_on_hover:
		background_fade.visible = false
		background_fade_shader = background_fade.material
		print("Setting shader viewport size: ", texture_rect.get_viewport().get_visible_rect().size)
		background_fade_shader.set_shader_parameter("screen_size", texture_rect.get_viewport().get_visible_rect().size)

##INHERITED
func on_mouse_down() -> void:
	GuiSystem.inspect_journal_item(item_resource)

func enter_hover() -> void:
	super()
	var global_rect : Rect2 = texture_rect.get_global_rect()
	var half_size : Vector2 = global_rect.size/2
	background_fade_shader.set_shader_parameter("exclusion_size", Vector2(half_size.x/2, half_size.y/1.5))
	background_fade_shader.set_shader_parameter("exclusion_center", global_rect.get_center() + Vector2(20,-30))
	background_fade_shader.set_shader_parameter("exclusion_rotation", texture_rect.rotation_degrees-73)
	background_fade.visible = true

func exit_hover() -> void:
	super()
	background_fade.visible = false
