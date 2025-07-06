extends Control


@onready var fullscreen_option_button : OptionButton = %FullscreenOptionButton


func _ready() -> void:
	fullscreen_option_button.selected = Settings.fullscreen


func _on_fullscreen_option_button_item_selected(value : int) -> void:
	Settings.set_fullscreen(value)
