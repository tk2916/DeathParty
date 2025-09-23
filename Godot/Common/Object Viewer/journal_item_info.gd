class_name JournalItemInfo extends InfoContainerGUI

@export var text_label : RichTextLabel
@export var img : TextureRect

func set_info(journal_item_rsc : JournalItemResource) -> void:
	text_label.text = journal_item_rsc.description
	img.texture = journal_item_rsc.texture
