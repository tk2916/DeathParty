class_name DialogueLine extends Control

@export var Name : RichTextLabel;
@export var Img : TextureRect;
@export var Text : RichTextLabel;

func set_image(texture : CompressedTexture2D) -> void:
	if Img:
		Img.texture = texture

func set_name_label(new_name : String) -> void:
	if Name:
		Name.text = new_name

func toggle_image(toggle : bool) -> void:
	if Img:
		Img.visible = toggle

func toggle_name(toggle : bool) -> void:
	if Name:
		Name.visible = toggle
