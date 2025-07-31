class_name DialogueLine extends Control

@export var Name : RichTextLabel;
@export var Img : TextureRect;
@export var Text : RichTextLabel;

##ASSIGNED BY DIALOGUE SYSTEM
var line_info : InkLineInfo
var text_properties : DialogueBoxResource
var speaker_resource : CharacterResource
var image_container : TextureRect
var name_container : RichTextLabel
##

##TEXT PROPERTIES (from text_properties, for easy access)
var text_color : String;
var name_color : String;

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

var no_animation : bool = false

signal done

func initialize():
	text_color = text_properties.default_text_color
	name_color = text_properties.default_name_color
	if text_properties.text_font:
		self.special_font = text_properties.text_font
	if Img:
		self.image_container = Img
	
	if speaker_resource: #if there is an entry for this character, get its properties
		if image_container:
			var image_key : String = "image_" + text_properties.image_key
			var image : CompressedTexture2D = speaker_resource[image_key]
			if image == null:
				#default to "full" if full is not null
				image = speaker_resource.image_full
			#if image != null:
			image_container.texture = image
		if speaker_resource.text_color != "":
			self.text_color = speaker_resource.text_color
		if speaker_resource.name_color != "":
			self.name_color = speaker_resource.name_color
	
	if name_container:
		#self.line_speaker = "" #we aren't putting the speaker in the text, we are putting it in the name container
		name_container.add_theme_font_size_override("normal_font_size", text_properties["name_size"])
		name_container.text = "[color="+self.name_color+"]"+line_info.speaker.to_upper()+"[/color]"
	
	text_prefix = "[color="+text_color+"]"
	if Name:
		Name.bbcode_enabled = true
		#if text_properties["name_in_separate_container"] == true:
		Name.add_theme_font_size_override("normal_font_size", text_properties["name_size"])
		name_contents = "[color="+name_color+"]"+line_info.speaker+"[/color]";
		Name.text = name_contents
	elif text_properties.include_speaker_in_text:
		Name.size_flags_stretch_ratio = 0
		name_contents = ""
		if line_info.speaker.length() > 0:
			text_prefix = "[color="+name_color+"]"+line_info.speaker+": [/color][color="+text_color+"]"
		
	Text.bbcode_enabled = true
	Text.add_theme_font_size_override("normal_font_size", text_properties["text_size"])
	if special_font:
		Text.add_theme_font_override("normal_font", special_font)
		Text.add_theme_constant_override("line_separation", text_properties["line_separation"])
			
	#SET/ANIMATE TEXT
	if !no_animation:
		if text_properties.text_animation == "typewriter":
			Text.text = ""
			#timer that will execute typewriter animation
			timer = Timer.new()
			timer.wait_time = char_delay
			timer.autostart = true
			timer.timeout.connect(typewriter)
			add_child(timer)
		elif text_properties.text_animation == "sliding":
			Text.text = text_prefix+line_info.text+text_suffix
			#TO BE ADDED: animate mask over each line that tweens to 0 width
		else:
			skip()
	else:
		skip()

var typewriter_text : String = ""
func typewriter():
	if (text_index > line_info.text.length()-1): #end loop
		timer.queue_free()
		finish()
		return
	typewriter_text = typewriter_text + line_info.text[text_index]
	Text.text = text_prefix + typewriter_text + text_suffix
	text_index += 1

func skip():
	text_index = text_contents.length()
	if timer:
		timer.stop()
		timer.queue_free()
	Text.text = text_prefix+line_info.text+text_suffix
	finish()

func finish():
	done.emit()
	done_state = true
