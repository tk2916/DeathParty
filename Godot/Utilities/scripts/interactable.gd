class_name Interactable extends Node3D

@export var primary_mesh : MeshInstance3D
@export var use_first_mesh : bool = false

var outline_shader : ShaderMaterial = preload("res://Assets/Shaders/OutlineShader.tres")
var interaction_detector_file = preload("res://Entities/interaction_detector.tscn")
var interaction_detector : InteractionDetector

var popup : Node3D
var surface_material : StandardMaterial3D = null

func _ready() -> void:
	print("New interctable")
	interaction_detector = interaction_detector_file.instantiate()
	add_child(interaction_detector)
	interaction_detector.player_interacted.connect(on_interact)
	interaction_detector.player_in_range.connect(on_in_range)
	
	if use_first_mesh:
		primary_mesh = Utils.find_first_child_of_class(self, MeshInstance3D)
	if primary_mesh:
		print("Primary mesh")
		create_outline()
	else:
		popup = get_node_or_null("Popup")
		
	if popup:
		popup.visible = false
		
func create_outline():
	print("Creating outline")
	surface_material = primary_mesh.get_active_material(0)
	var new_shader : ShaderMaterial = outline_shader.duplicate()
	new_shader.resource_local_to_scene = true
	new_shader.set_shader_parameter("alpha", 0)
	surface_material.next_pass = new_shader
	
func toggle_popup(on : bool):
	if popup:
		popup.visible = on
	if surface_material:
		var value : float
		if on:
			value = 1.0
		else:
			value = 0.0
		surface_material.next_pass.set_shader_parameter("alpha", value)
	
##OVERRIDE THESE METHODS (but call super() at the beginning)
func on_interact() -> void:
	print("Interacting")
	toggle_popup(false)
	
func on_in_range(in_range : bool) -> void:
	toggle_popup(in_range)
