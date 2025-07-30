class_name BookFlip extends Node3D

@onready var page_flip_sound : FmodEventEmitter2D = %PageFlipSound

@export var animation_player : AnimationPlayer

@export var page1 : MeshInstance3D
@export var page2 : MeshInstance3D

@export var page1_subviewport : Viewport
@export var page2_subviewport : Viewport

@export var viewport_texture1 : ViewportTexture
@export var viewport_texture2 : ViewportTexture

var page1_mat : Material
var page2_mat : Material

@export var journal_textures : Array #either CompressedTexture2D or Control
var journal_textures_size : int 

var page_tracker : int = 0
var flipping : bool = false

@export var tabs_node_left : Node
@export var tabs_node_right : Node
var left_tabs : Array[Node]
var right_tabs : Array[Node]

var cur_tab : Node
var old_tab : Node

var timer : Timer = Timer.new()

var tab_handler : JournalTabHandler

var cur_subviewport : Viewport  #referenced in other classes

func _ready() -> void:
	left_tabs = tabs_node_left.get_children()
	right_tabs = tabs_node_right.get_children()
	right_tabs.reverse()
	
	tab_handler = JournalTabHandler.new(left_tabs, right_tabs)
	
	cur_tab = tab_handler.get_tab(0)
	old_tab = tab_handler.get_tab(0)
	cur_tab.move_upward()
	
	page1_mat = page1.material_override
	page2_mat = page2.material_override
	
	journal_textures_size = journal_textures.size()
	animation_player.animation_finished.connect(_on_anim_finished)
	animation_player.play("idle")
	
	#set left page texture to first page
	set_page(1, page_tracker)
	
	#timer for moving tabs to correct places
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(move_tab)
	
	for tab in left_tabs:
		tab.tab_pressed.connect(on_tab_pressed.bind(tab))
	for tab in right_tabs:
		tab.tab_pressed.connect(on_tab_pressed.bind(tab))

func on_tab_pressed(tab:Node):
	var flipBackwards : bool = tab.flip_to_page <= page_tracker
	bookflip(flipBackwards, tab.flip_to_page)
	
func move_tab():
	tab_handler.flip_page(page_tracker)
	cur_tab = tab_handler.get_tab_from_page_number(page_tracker)
	old_tab.return_to_original_pos()
	if old_tab != cur_tab:
		cur_tab.move_upward()
		old_tab = cur_tab

func set_page(side_of_page : int, index : int):
	var journal_entry = journal_textures[index]
	var page_mat : Material = page1_mat
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
		page_mat.set_shader_parameter("albedo_texture", viewport_texture)
		viewport_texture.viewport_path = page_subviewport.get_path()
		page_subviewport.add_child(journal_entry.instantiate())	
		cur_subviewport = page_subviewport

func bookflip(backward : bool = false, flip_to_page : int = -1):
	if (flipping or flip_to_page == page_tracker or flip_to_page > journal_textures_size-1):
		return
	var old_page_index = page_tracker
	if !backward && (page_tracker<journal_textures_size-1 || flip_to_page != -1):
		flipping = true;
		if flip_to_page == -1:
			page_tracker = page_tracker+1  
		else:
			page_tracker = flip_to_page
		set_page(1, old_page_index)
		set_page(2, page_tracker)
		animation_player.play("pageFlip")
		page_flip_sound.play()
		timer.start(.5)
	elif backward && (page_tracker>0 || flip_to_page != -1):
		flipping = true;
		if flip_to_page == -1:
			page_tracker = page_tracker-1  
		else:
			page_tracker = flip_to_page
		set_page(1, page_tracker)
		set_page(2, old_page_index)
		animation_player.play_backwards("pageFlip")
		page_flip_sound.play()
		timer.start(.2)

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "pageFlip":
		set_page(1, page_tracker)
		flipping = false
		animation_player.play("idle")
