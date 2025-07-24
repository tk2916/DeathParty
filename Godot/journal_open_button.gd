class_name JournalOpenButton extends GuiButton

var journal_showing : bool = false

func _pressed() -> void:
	print("Journal button pressed")
	if journal_showing == false:
		gui_controller.show_journal()
	else:
		gui_controller.hide_journal()
	journal_showing = !journal_showing
