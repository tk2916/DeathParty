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

func _ready() -> void:
	page_tracker = 0
	page1_mat = page1.mesh.surface_get_material(0)
	page2_mat = page2.mesh.surface_get_material(0)
	page1_mat.albedo_texture = journal_textures[page_tracker]
	journal_textures_size = journal_textures.size()
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_anim_finished)

func bookflip(backward : bool = false):
	if (flipping):
		return
	if !backward && page_tracker<journal_textures.size()-1:
		flipping = true;
		page_tracker += 1
		page1_mat.albedo_texture = journal_textures[page_tracker-1]
		page2_mat.albedo_texture = journal_textures[page_tracker]
		animation_player.play("pageFlip")
	elif backward && page_tracker>0:
		flipping = true;
		page_tracker -= 1
		page1_mat.albedo_texture = journal_textures[page_tracker]
		page2_mat.albedo_texture = journal_textures[page_tracker+1]
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
