extends Node3D


@onready var page_flip_sound : FmodEventEmitter3D = %PageFlipSound

@export var animation_player : AnimationPlayer

@export var page1 : MeshInstance3D
@export var page2 : MeshInstance3D

@export var page1_subviewport : Viewport
@export var page2_subviewport : Viewport

@export var viewport_texture : ViewportTexture

var page1_mat : Material
var page2_mat : Material

@export var journal_textures : Array #either CompressedTexture2D or Control
var journal_textures_size : int 

var page_tracker : int
var flipping : bool = false

@export var tabs_node : Node
var all_tabs : Array[Node]
var cur_tab : Node
var old_tab : Node

var timer : Timer = Timer.new()

func _ready() -> void:
	page_tracker = 0
	all_tabs = tabs_node.get_children()
	cur_tab = all_tabs[0]
	old_tab = all_tabs[0]
	cur_tab.move_upward()
	
	page1_mat = page1.material_overlay#mesh.surface_get_material(0)
	page2_mat = page2.material_overlay#mesh.surface_get_material(0)
	
	journal_textures_size = journal_textures.size()
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_anim_finished)
	
	#page1_mat.albedo_texture = journal_textures[page_tracker]
	set_page(1, page_tracker)
	
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(move_tab)
	
	for tab in all_tabs:
		tab.button.pressed.connect(on_tab_pressed.bind(tab))

func on_tab_pressed(tab:Node):
	print("On tab pressed")
	bookflip(tab.flip_to_page <= page_tracker, tab.flip_to_page)
	
func move_tab():
	old_tab.return_to_original_pos()
	if old_tab != cur_tab:
		cur_tab.move_upward()
		old_tab = cur_tab

func set_page(page_number : int, index : int):
	var journal_entry = journal_textures[index]
	var page_mat : Material = page1_mat
	var page_subviewport : Viewport = page1_subviewport
	if page_number == 2:
		page_mat = page2_mat
		page_subviewport = page2_subviewport
	#clear children of subviewport if any
	for child in page_subviewport.get_children():
		page_subviewport.remove_child(child)
		child.queue_free()
	
	if journal_entry is CompressedTexture2D:
		page_mat.albedo_texture = journal_entry
		
	elif journal_entry is PackedScene:
		page_mat.albedo_texture = viewport_texture
		viewport_texture.viewport_path = page_subviewport.get_path()
		page_subviewport.add_child(journal_entry.instantiate())

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

	#bring a bookmark up front
	for tab in all_tabs:
		if page_tracker == tab.flip_to_page:
			cur_tab = tab


func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "pageFlip":
		set_page(1, page_tracker)
		flipping = false
		animation_player.play("idle")
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_A:
			bookflip(true);
		elif event.keycode == KEY_D:
			bookflip();
