extends Node3D

var mouse : Vector2
const DIST : float = 1000.0

var grabbed_object : Node3D = null
var dragged_object : Node3D = null
var outline_mesh : MeshInstance3D = null

@onready var main_camera3d : Camera3D
@onready var camera3d : Camera3D

var cur_sub_viewport : Viewport = null
var object_viewer : ObjectViewer = null

signal mouse_position_changed(delta : Vector2)

func _ready() -> void:
	main_camera3d = get_viewport().get_camera_3d()
	camera3d = main_camera3d
	var main : Node = get_tree().root.get_node_or_null("Main")
	if main:
		object_viewer = main.get_node("ObjectViewer")
		object_viewer.enabled.connect(switch_camera)
	
func switch_camera(enabled, new_cam = null):
	if !enabled:
		camera3d = main_camera3d
	else:
		camera3d = new_cam

func _input(event: InputEvent) -> void:
	if !DialogueSystem.in_dialogue:
		if event is InputEventMouseMotion:
			mouse = event.position
			mouse_position_changed.emit(event.relative)
			get_mouse_world_pos()
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if cur_sub_viewport:
					print("Pushing input to subviewport")
					cur_sub_viewport.push_input(event)
					return
				if event.pressed == false: 
					#will fire even if mouse is outside of object
					if dragged_object == null: return
					dragged_object.on_mouse_up()
					dragged_object = null
				if grabbed_object and grabbed_object is ObjectViewerInteractable:
					if event.pressed == true:
						grabbed_object.on_mouse_down()
						dragged_object = grabbed_object

func mouse_in_world_projection() -> Vector3:
	return camera3d.project_position(mouse, DIST)

func get_mouse_world_pos() -> void:
	if camera3d == null: return
	mouse = camera3d.get_viewport().get_mouse_position() #important bc otherwise it gets the wrong mouse pos
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	#we will check if there's anything between the start and end points of the ray DIST long
	var start : Vector3 = camera3d.project_ray_origin(mouse)
	var end : Vector3 = mouse_in_world_projection()
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	
	params.collision_mask = 9
	
	var result : Dictionary = space.intersect_ray(params)
	if result.is_empty() == false:
		var og_grabbed_object : Node3D = grabbed_object
		
		grabbed_object = result.collider
		if og_grabbed_object == grabbed_object:
			#print("Grabbed object equal")
			return
		#print("Grabbed object not in group: ", grabbed_object.name)
		if grabbed_object is ObjectViewerInteractable:
			#print("Grabbed object: ", grabbed_object.name)
			if og_grabbed_object and og_grabbed_object is ObjectViewerInteractable:
				if !(og_grabbed_object.name == "BookflipBody" and grabbed_object.name.substr(0,13) == "InventoryItem"):
					og_grabbed_object.exit_hover()
			grabbed_object.enter_hover()
	else:
		if grabbed_object and grabbed_object is ObjectViewerInteractable:
			grabbed_object.exit_hover()
		grabbed_object = null
		
func set_active_subviewport(subviewport : Viewport) -> void:
	cur_sub_viewport = subviewport
func clear_active_subviewport() -> void:
	cur_sub_viewport = null
