class_name TextAnimator

var dialogue_box : DialogueBoxProperties
var text_label : RichTextLabel;
var line_info : InkLineInfo
var dialogue_resource : DialogueBoxResource
var speaker_resource : CharacterResource

##TEXT PROPERTIES (from dialogue_resource, for easy access)
var text_color : String;
var text_contents : String
var text_prefix : String
var text_suffix : String = "[/color]"

var special_font : FontFile

#ANIMATION
var char_delay : float = .03
var text_index : int = 0
var done_state : bool = false
var timer : Timer

var no_animation : bool = false
var typewriter_ready : bool = false
var typewriter_text : String = ""

signal done

func _init(
	_dialogue_box : DialogueBoxProperties,
	_dialogue_resource : DialogueBoxResource,
	_text_label : RichTextLabel = null
) -> void:
	dialogue_box = _dialogue_box
	dialogue_resource = _dialogue_resource
	text_label = _text_label
	
	
	if dialogue_resource:
		text_color = dialogue_resource.default_text_color
		if dialogue_resource.text_font:
			self.special_font = dialogue_resource.text_font
	if text_label:
		text_label.bbcode_enabled = true
		if special_font:
			text_label.add_theme_font_override("normal_font", special_font)
		if dialogue_resource:
			if special_font:
				text_label.add_theme_constant_override("line_separation", dialogue_resource["line_separation"])
			text_label.add_theme_font_size_override("normal_font_size", dialogue_resource["text_size"])
	
	text_prefix = "[color="+text_color+"]"
			
	#SET/ANIMATE TEXT

func set_text(_line_info : InkLineInfo, _speaker_resource : CharacterResource) -> void:
	line_info = _line_info
	if dialogue_box is MainDialogueBox:
		#bc it changes labels
		self.text_label = dialogue_box.text_label
	if _speaker_resource != speaker_resource:
		speaker_resource = _speaker_resource
		if speaker_resource: #if there is an entry for this character, get its properties
			if speaker_resource.text_color != "":
				self.text_color = speaker_resource.text_color
	if !no_animation and dialogue_resource:
		if dialogue_resource.text_animation == "typewriter":
			if timer == null:
				timer = Timer.new()
				timer.wait_time = char_delay
				timer.autostart = true
				timer.timeout.connect(typewriter)
				dialogue_box.add_child(timer)
			typewriter_text = ""
			text_label.text = ""
			text_index = 0
			typewriter_ready = true
			#timer that will execute typewriter animation
		else:
			skip()
	else:
		skip()

func typewriter() -> void:
	#timer is continuously firing even when paused
	if !typewriter_ready: return
	if (text_index > line_info.text.length()-1): #end loop
		timer.queue_free()
		finish()
		return
	typewriter_text = typewriter_text + line_info.text[text_index]
	text_label.text = text_prefix + typewriter_text + text_suffix
	text_index += 1

func skip() -> void:
	text_index = text_contents.length()
	if timer:
		timer.stop()
		timer.queue_free()
	text_label.text = text_prefix+line_info.text+text_suffix
	finish()

func finish() -> void:
	done.emit()
	done_state = true
	typewriter_ready = false
