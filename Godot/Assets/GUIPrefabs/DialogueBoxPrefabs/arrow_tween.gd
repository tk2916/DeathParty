extends TextureRect

var tween : Tween
var tree : SceneTree

func _ready() -> void:
	visible = false
	tree = get_tree()

func _on_visibility_changed() -> void:
	if tween:
		tween.kill()
	while visible:
		tween = tree.create_tween()
		tween.tween_property(self, "modulate:a", 1, .5)
		await tween.finished
		tween = tree.create_tween()
		tween.tween_property(self, "modulate:a", 0, .5)
		await tween.finished
	self.modulate.a = 0
