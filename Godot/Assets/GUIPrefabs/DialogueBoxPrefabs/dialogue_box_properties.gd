class_name DialogueBoxProperties extends Control

@onready var tree := get_tree()
var done_state : bool = false
signal done

var printing_sound : Node = find_child("TextPrintingSound")

class AnimatedTextLabel:
	var parent : DialogueBoxProperties
	var animator : TextAnimator
	func _init(
		dialogue_box : DialogueBoxProperties, 
		text_label : RichTextLabel,
		animation_style : DialogueSystem.ANIMATION_STYLES = DialogueSystem.ANIMATION_STYLES.NONE
	) -> void:
		parent = dialogue_box
		animator = TextAnimator.new(
			text_label,
			animation_style,
			parent.printing_sound,
		)
		animator.done.connect(parent.on_text_animator_finish)
	func set_text(line : InkLineInfo) -> void:
		parent.done_state = false
		animator.set_text(line)

## OVERRIDE THESE FUNCTIONS
func add_line(_line : InkLineInfo) -> void:
	pass

func set_choices(_choices : Array[InkChoiceInfo]) -> void:
	pass

func pause_conversation() -> void:
	pass

func on_text_animator_finish() -> void:
	done_state = true
	done.emit()
