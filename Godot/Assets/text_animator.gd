class_name TextAnimator

var text_label: RichTextLabel
var animation_style: DialogueSystem.ANIMATION_STYLES

#ANIMATION
var char_delay: float = .03
var text_index: int = 0
var done_state: bool = false
var timer: Timer

var full_text: String
var typewriter_text: String = ""

signal done

func _init(
	_text_label: RichTextLabel,
	_animation_style: DialogueSystem.ANIMATION_STYLES = DialogueSystem.ANIMATION_STYLES.NONE,
) -> void:
	text_label = _text_label
	animation_style = _animation_style

func set_text(line_info: InkLineInfo) -> void:
	full_text = line_info.text
	print("set text: ", full_text)

	if animation_style == DialogueSystem.ANIMATION_STYLES.TYPEWRITER:
		#timer that will execute typewriter animation
		if timer == null:
			timer = Timer.new()
			timer.wait_time = char_delay
			timer.autostart = true
			timer.timeout.connect(typewriter)
			text_label.add_child(timer)
		typewriter_text = ""
		text_label.text = ""
		text_index = 0
	else:
		skip()


func typewriter() -> void:
	#timer is continuously firing even when paused
	if (text_index > full_text.length() - 1): # end loop
		timer.queue_free()
		finish()
		return
	typewriter_text = typewriter_text + full_text[text_index]
	text_label.text = typewriter_text
	text_index += 1

	# play printing sound if the last char added wasnt a space
	if full_text[text_index - 1] != " ":
		Sounds.play_dialogue_print()


func skip() -> void:
	print("Skipping")
	text_index = full_text.length()
	if timer:
		timer.stop()
		timer.queue_free()
	text_label.text = full_text
	print("Setting label text ", text_label, " to ", full_text, " | ", text_label.text)
	finish()

func finish() -> void:
	print("Done firing")
	done.emit()
	done_state = true
