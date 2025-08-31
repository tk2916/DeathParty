extends ScrollContainer

@export var text_label : RichTextLabel
@export var arrow : TextureRect

func _ready() -> void:
	resized.connect(toggle_arrow)
	var scroll_bar : VScrollBar = get_v_scroll_bar()
	scroll_bar.modulate.a = 0.0 
	scroll_bar.changed.connect(toggle_arrow)
	toggle_arrow()

func toggle_arrow():
	await get_tree().process_frame
	var visible_size := size.y
	var text_label_size := text_label.size.y
	if text_label_size > visible_size:
		arrow.visible = true
	else:
		arrow.visible = false
