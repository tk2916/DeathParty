class_name Interactable extends Area3D

@export var primary_mesh: MeshInstance3D
@export var use_first_mesh: bool = true
@export var outline_thickness: float = .7

@export var talking_object_resource: TalkingObjectResource

#@export var outline_shader : ShaderMaterial = preload("res://Assets/Shaders/OutlineShader.tres")
var outline_shader: ShaderMaterial = preload("res://Assets/Shaders/OutlineShader/TestOutlineShader.tres")
var surface_material: StandardMaterial3D = null

var popup: Node3D

var player_in_range := false

@export var enabled: bool = true:
	set(value):
		enabled = value
		# call on_in_range if the player is already standing in the interactable
		# area when the interactable gets enabled (since otherwise it wouldnt
		# get an on_entered signal since the player's already in there)
		if enabled:
			var overlapping_bodies: Array = get_overlapping_bodies()
			for body: PhysicsBody3D in overlapping_bodies:
				if body == Globals.player:
					on_in_range(true)


func _enter_tree() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _ready() -> void:
	#Get the popup that will be used:
	popup = get_node_or_null("Popup")
	
	#print("Loading ", name, ": ", primary_mesh, " ", use_first_mesh)
	if primary_mesh:
		create_outline()
	elif use_first_mesh:
		primary_mesh = Utils.find_first_child_of_class(self, MeshInstance3D)
		create_outline()
	if popup:
		popup.visible = false


func physics_process() -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		interact()


func toggle_popup(on: bool) -> void:
	if popup:
		popup.visible = on
	if surface_material:
		var value: float
		if on:
			value = 1.0
		else:
			value = 0.0
		var shader: ShaderMaterial = surface_material.next_pass

		# this is commented out to disable the outline shader temporarily
		# should work like normal if we un-comment
		#shader.set_shader_parameter("alpha", value)

	if talking_object_resource:
		talking_object_resource = SaveSystem.get_talking_object(talking_object_resource.name)


##OVERRIDE THESE METHODS (but call super() at the beginning)
func interact() -> void:
	if InteractablePriority.active_interactable == self:
		toggle_popup(false)
		if talking_object_resource:
			talking_object_resource.start_chat()


func on_in_range(in_range: bool) -> void:
	if !enabled: return
	toggle_popup(in_range)


func _on_body_entered(body: Node3D) -> void:
	if body == Globals.player:
		print("player entered interactable range of ", name)
		if !enabled: return
		InteractablePriority.add_interactable(self)
		toggle_popup(true)


func _on_body_exited(body: Node3D) -> void:
	if body == Globals.player:
		print("player exited interactable range of ", name)
		InteractablePriority.remove_interactable(self)
		toggle_popup(true)


func create_outline() -> void:
	#print("Creating outline")
	if primary_mesh == null: return
	surface_material = primary_mesh.get_active_material(0)
	var new_shader: ShaderMaterial = outline_shader.duplicate()
	new_shader.set_shader_parameter("alpha", 0)
	new_shader.set_shader_parameter("thickness", outline_thickness)
	surface_material.next_pass = new_shader
