class_name Post extends Control

@export var social_media_app : SocialMediaApp
@export var button : Button
@export var character_resource : CharacterResource

@export var image_label : TextureRect
@export var name_label : RichTextLabel
@export var tag_label : RichTextLabel

func _ready() -> void:
	image_label.texture = character_resource.profile_image
	name_label.text = character_resource.name
	tag_label.text = character_resource.profile_tag
	
	button.pressed.connect(social_media_app.on_user_pressed.bind(character_resource))
	
