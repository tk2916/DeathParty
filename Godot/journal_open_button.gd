class_name JournalOpenButton extends GuiButton

var journal_showing : bool = false

func _pressed() -> void:
	print("Journal button pressed")
	if journal_showing == false:
		GuiSystem.show_journal()
	else:
		GuiSystem.hide_journal()
	journal_showing = !journal_showing
