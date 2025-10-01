class_name BookFlip extends Node3D

@onready var page_flip_sound : FmodEventEmitter2D = %PageFlipSound

@export var animation_player : AnimationPlayer

@export var page1 : MeshInstance3D
@export var page2 : MeshInstance3D

@export var page1_subviewport : SubViewport
@export var page2_subviewport : SubViewport

@export var viewport_texture1 : ViewportTexture
@export var viewport_texture2 : ViewportTexture

var page1_mat : ShaderMaterial
var page2_mat : ShaderMaterial

@export var journal_textures : Array #either CompressedTexture2D or Control
var journal_textures_size : int 

var page_tracker : int = 0
var flipping : bool = false

@export var tabs_node : Node
var tabs : Array[JournalTab]

var cur_tab : Node
var old_tab : Node

var tab_handler : JournalTabHandler

var cur_subviewport : Viewport  #referenced in other classes

func _ready() -> void:
	page1_subviewport.size = Vector2i(1920, 1080)
	page2_subviewport.size = Vector2i(1920, 1080)
	
	for tab in tabs_node.get_children():
		if tab is JournalTab:
			tabs.push_back(tab)
	
	tab_handler = JournalTabHandler.new(self, tabs)
	
	cur_tab = tab_handler.get_tab(0)
	old_tab = tab_handler.get_tab(0)
	
	page1_mat = page1.material_overlay
	page2_mat = page2.material_overlay

	page1_mat.set_shader_parameter("multiplier", 1)
	page2_mat.set_shader_parameter("multiplier", 1)
	
	journal_textures_size = journal_textures.size()
	animation_player.animation_finished.connect(_on_anim_finished)
	animation_player.play("Idle")
	
	#set left page texture to first page
	set_page(1, page_tracker)

func flip_to_page(page_number : int) -> void:
	var flipBackwards : bool = page_number <= page_tracker
	bookflip(flipBackwards, page_number)

func set_page(side_of_page : int, index : int) -> void:
	var journal_entry : Variant = journal_textures[index]
	var page_mat : ShaderMaterial = page1_mat
	var page_subviewport : Viewport = page1_subviewport
	var viewport_texture : ViewportTexture = viewport_texture1
	if side_of_page == 2:
		page_mat = page2_mat
		page_subviewport = page2_subviewport
		viewport_texture = viewport_texture2
	#clear children of subviewport if any
	for child in page_subviewport.get_children():
		page_subviewport.remove_child(child)
		child.queue_free()
	
	if journal_entry is CompressedTexture2D:
		page_mat.set_shader_parameter("albedo_texture", journal_entry)
		cur_subviewport = null
		
	elif journal_entry is PackedScene:
		var entry_prefab : PackedScene = journal_entry
		page_mat.set_shader_parameter("albedo_texture", viewport_texture)
		viewport_texture.viewport_path = page_subviewport.get_path()
		page_subviewport.add_child(entry_prefab.instantiate())	
		cur_subviewport = page_subviewport

func bookflip(backward : bool = false, direct_flip : int = -1) -> void:
	if (flipping or direct_flip == page_tracker or direct_flip > journal_textures_size-1):
		return
	var old_page_index : int= page_tracker
	if !backward && (page_tracker<journal_textures_size-1 || direct_flip != -1):
		flipping = true;
		if direct_flip == -1:
			page_tracker = page_tracker+1  
		else:
			page_tracker = direct_flip
		set_page(1, old_page_index)
		set_page(2, page_tracker)
		animation_player.play("Flip Front")
		page_flip_sound.play()
		tab_handler.flip_page(page_tracker)
	elif backward && (page_tracker>0 || direct_flip != -1):
		flipping = true;
		if direct_flip == -1:
			page_tracker = page_tracker-1  
		else:
			page_tracker = direct_flip
		set_page(2, old_page_index)
		set_page(1, page_tracker)
		animation_player.play("Flip Back")
		page_flip_sound.play()
		tab_handler.flip_page(page_tracker)

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "Flip Back" or anim_name == "Flip Front":
		set_page(1, page_tracker)
		flipping = false
		animation_player.play("idle")
