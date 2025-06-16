extends Control

@export var Name : RichTextLabel;
@export var Text : RichTextLabel;

var line_text : String;
var line_speaker : String;
var text_color : String;
var name_color : String;
var text_properties : Resource;

var name_contents : String
var text_contents : String

var text_prefix : String
var text_suffix : String = "[/color]"

var special_font : FontFile

#ANIMATION
var char_delay : float = .03
var text_index : int = 0
var done_state = false
var timer : Timer

signal done

func initialize():
	text_prefix = "[color="+text_color+"]"
	if Name:
		Name.text = name_contents
		Name.bbcode_enabled = true
		#if text_properties["name_in_separate_container"] == true:
		Name.add_theme_font_size_override("normal_font_size", text_properties["name_size"])
		name_contents = "[color="+name_color+"]"+line_speaker+":[/color]";
			#text_prefix = "[color="+text_color+"]"
	elif text_properties["include_speaker_in_text"]:
		Name.size_flags_stretch_ratio = 0
		name_contents = ""
		if line_speaker.length() > 0:
			text_prefix = "[color="+name_color+"]"+line_speaker+": [/color][color="+text_color+"]"
			#else:
			#	text_prefix = "[color="+text_color+"]"
		
	Text.bbcode_enabled = true
	Text.add_theme_font_size_override("normal_font_size", text_properties["text_size"])
	if special_font:
		Text.add_theme_font_override("normal_font", special_font)
		Text.add_theme_constant_override("line_separation", text_properties["line_separation"])
			
	#SET/ANIMATE TEXT
	if text_properties["text_animation"] == "typewriter":
		Text.text = ""
		#timer that will execute typewriter animation
		timer = Timer.new()
		timer.wait_time = char_delay
		timer.autostart = true
		timer.timeout.connect(typewriter)
		add_child(timer)
	elif text_properties["text_animation"] == "sliding":
		Text.text = text_prefix+line_text+text_suffix
		#TO BE ADDED: animate mask over each line that tweens to 0 width
	else:
		skip()

var typewriter_text : String = ""
func typewriter():
	if (text_index > line_text.length()-1): #end loop
		timer.queue_free()
		finish()
		return
	typewriter_text = typewriter_text + line_text[text_index]
	Text.text = text_prefix + typewriter_text + text_suffix
	text_index += 1

func skip():
	text_index = text_contents.length()
	if timer:
		timer.queue_free()
	Text.text = text_prefix+line_text+text_suffix
	finish()

func finish():
	done.emit()
	done_state = true

func _process(delta):
	var content_height : int = Text.get_content_height()
	var content_width : int = Text.get_content_width()
	
	self.custom_minimum_size.y = content_height
	self.custom_minimum_size.x = content_height
		
