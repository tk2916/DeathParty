extends Node3D

@export var animation_player : AnimationPlayer

@export var page1 : MeshInstance3D
@export var page2 : MeshInstance3D

var page1_mat : Material
var page2_mat : Material

@export var journal_textures : Array[CompressedTexture2D]
var journal_textures_size : int 

var page_tracker : int
var flipping : bool = false

@export var tabs_node : Node
var all_tabs : Array[Node]
var cur_tab : Node

func on_tab_pressed(tab : Node):
	cur_tab.return_to_original_pos()
	tab.button_pressed()
	cur_tab = tab
	bookflip(true, cur_tab.flip_to_page)

func _ready() -> void:
	page_tracker = 0
	all_tabs = tabs_node.get_children()
	page1_mat = page1.mesh.surface_get_material(0)
	page2_mat = page2.mesh.surface_get_material(0)
	page1_mat.albedo_texture = journal_textures[page_tracker]
	journal_textures_size = journal_textures.size()
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_anim_finished)
	
	for tab in all_tabs:
		tab.button.pressed.connect(on_tab_pressed.bind(tab))

func bookflip(backward : bool = false, flip_to_page : int = -1):
	if (flipping):
		return
	var old_page_index = page_tracker
	if !backward && page_tracker<journal_textures.size()-1:
		flipping = true;
		page_tracker = page_tracker+1 if flip_to_page == -1 else flip_to_page
		page1_mat.albedo_texture = journal_textures[old_page_index]
		page2_mat.albedo_texture = journal_textures[page_tracker]
		animation_player.play("pageFlip")
	elif backward && page_tracker>0:
		flipping = true;
		page_tracker = page_tracker-1 if flip_to_page == -1 else flip_to_page
		page1_mat.albedo_texture = journal_textures[page_tracker]
		page2_mat.albedo_texture = journal_textures[old_page_index]
		animation_player.play_backwards("pageFlip")	
	
func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "pageFlip":
		page1_mat.albedo_texture = journal_textures[page_tracker]
		flipping = false
		animation_player.play("idle")
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_A:
			bookflip(true);
		elif event.keycode == KEY_D:
			bookflip();
