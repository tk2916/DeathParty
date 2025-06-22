extends Panel

@export var journal_pages : Array[Node] = []

func disable_all_but_one(exception : Node):
	if exception.visible: #set all other pages to invisible
		for page in journal_pages:
			if page != exception:
				page.visible = false

func _ready() -> void:
	for page in journal_pages:
		page.visibility_changed.connect(disable_all_but_one.bind(page))
