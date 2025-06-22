extends Control

@export var char_image : TextureRect
@export var char_name: RichTextLabel
@export var char_descriptors: RichTextLabel
@export var char_notes_container: VBoxContainer
@export var char_note_scene : PackedScene

var char_resource : Resource

func load_notes():
	for note_label in char_notes_container.get_children():
		char_notes_container.remove_child(note_label)
		note_label.queue_free()
	for note in char_resource.character_notes:
		var new_note = char_note_scene.instantiate()
		new_note.text = "[color=black]"+note+"[/color]"
		char_notes_container.add_child(new_note)

func load_character(resource : Resource):
	char_resource = resource
	char_image.texture = char_resource.image_torso
	char_name.text = "[color=black]"+char_resource.name+"[/color]"
	char_descriptors.text = "[color=black]"+char_resource.character_description+"[/color]"
	load_notes()
