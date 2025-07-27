class_name DragDropControl extends Control

@export var node_root : Control
@export var node_save_path : String

@export var correct_item : InventoryItemResource
@export var reveal_scene : PackedScene
@export var reveal_texture : CompressedTexture2D

@export var color_rect : ColorRect

func _ready() -> void:
	if color_rect:
		color_rect.visible = false
	if SaveSystem.is_journal_entry_active(correct_item.name):
		reveal_info()

func enter_hover() -> void:
	if color_rect:
		color_rect.visible = true
func exit_hover() -> void:
	if color_rect:
		color_rect.visible = false

func reveal_info() -> void:
	if color_rect:
		self.remove_child(color_rect)
		color_rect.queue_free()
	if reveal_scene:
		var revealed_info : Control = reveal_scene.instantiate()
		self.add_child(revealed_info)
	elif reveal_texture:
		var texture_rect = TextureRect.new()
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		texture_rect.texture = reveal_texture
		self.add_child(texture_rect)
	
func mouse_up(resource : InventoryItemResource, instance : DragDropPolaroid) -> void:
	if resource == correct_item:
		SaveSystem.remove_item(resource.name)
		SaveSystem.set_journal_entry(resource.name, true)
		reveal_info()
		
		#var packed_scene := PackedScene.new()
		#packed_scene.pack(node_root)
		#ResourceSaver.save(packed_scene, node_save_path)
		print("Correct model!")
		pass
	else:
		instance.return_to_og_position()
		exit_hover()
		pass
