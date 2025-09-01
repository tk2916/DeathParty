class_name HoverButton extends Button

@export var texture_rect : TextureRect
@onready var rtl : RichTextLabel = texture_rect.get_node("RichTextLabel")
@export var default_texture : CompressedTexture2D
@export var hover_texture : CompressedTexture2D

var option_text : String

func _ready() -> void:
	texture_rect.texture = default_texture
	option_text = rtl.text
	
func change_text(new_text : String) -> void:
	option_text = new_text
	rtl.text = "[color=white]"+option_text+"[/color]"

func _on_mouse_entered() -> void:
	texture_rect.texture = hover_texture
	rtl.text = "[color=black]"+option_text+"[/color]"

func _on_mouse_exited() -> void:
	texture_rect.texture = default_texture
	rtl.text = "[color=white]"+option_text+"[/color]"
