class_name DialogueBoxProperties extends Control

@onready var tree := get_tree()
var done_state: bool = false
signal done


class AnimatedTextLabel:
	var parent: DialogueBoxProperties
	var animator: TextAnimator
	func _init(
		dialogue_box: DialogueBoxProperties,
		text_label: RichTextLabel,
		animation_style: DialogueSystem.ANIMATION_STYLES = DialogueSystem.ANIMATION_STYLES.NONE
	) -> void:
		parent = dialogue_box
		animator = TextAnimator.new(
			text_label,
			animation_style,
		)
		animator.done.connect(parent.on_text_animator_finish)
	func set_text(line: InkLineInfo) -> void:
		parent.done_state = false
		animator.set_text(line)
	func skip() -> void:
		animator.skip()

## OVERRIDE THESE FUNCTIONS
func add_line(_line: InkLineInfo, _skip_delay : bool = false) -> void:
	assert(false, "You need to define add_line() in your DialogueBox")

func set_choices(_choices: Array[InkChoiceInfo]) -> void:
	assert(false, "You need to define set_choices() in your DialogueBox")

func pause_conversation() -> void:
	assert(false, "You need to define pause_conversation() in your DialogueBox")

func on_text_animator_finish() -> void:
	done_state = true
	done.emit()

func skip() -> void:
	assert(false, "You need to define skip() in your DialogueBox")
