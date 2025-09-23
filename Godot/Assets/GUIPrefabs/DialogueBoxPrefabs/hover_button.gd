class_name HoverButton extends Button

@export var texture_rect : TextureRect
@onready var rtl : RichTextLabel = texture_rect.get_node("RichTextLabel")
@export var default_texture : CompressedTexture2D
@export var hover_texture : CompressedTexture2D

var click_sound_scene: PackedScene = preload("res://audio/choice_button_click_sound.tscn")

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

#region Keyboard/controller naviagtion visuals
func _on_focus_entered() -> void:
	texture_rect.texture = hover_texture
	rtl.text = "[color=black]"+option_text+"[/color]"
	
func _on_focus_exited() -> void:
	texture_rect.texture = default_texture
	rtl.text = "[color=white]"+option_text+"[/color]"
#endregion

func _on_pressed() -> void:
	var click_sound: FmodEventEmitter3D = click_sound_scene.instantiate()
	get_tree().root.get_node_or_null("Main").add_child(click_sound)
