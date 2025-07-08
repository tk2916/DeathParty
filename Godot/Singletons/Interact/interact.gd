extends Node3D

var mouse : Vector2
const DIST : int = 1000

var grabbed_object : Node3D = null
var outline_mesh : MeshInstance3D = null

@onready var main_camera3d : Camera3D
@onready var camera3d : Camera3D

var cur_sub_viewport : Viewport = null

func _ready() -> void:
	main_camera3d = get_viewport().get_camera_3d()
	camera3d = main_camera3d
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		main.get_node("ObjectViewer").enabled.connect(switch_camera)
		
func switch_camera(enabled, new_cam = null):
	if !enabled:
		camera3d = main_camera3d
	else:
		camera3d = new_cam

func _input(event: InputEvent) -> void:
	if !DialogueSystem.in_dialogue:
		if event is InputEventMouseMotion:
			mouse = event.position
			get_mouse_world_pos()
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
				if cur_sub_viewport:
					#print("Hovering over tab, pushing input", grabbed_object)
					cur_sub_viewport.push_input(event)
					return
				if outline_mesh: #this means something is currently selected & interactable
					outline_mesh.visible = false
					grabbed_object.interact()
					grabbed_object = null
					outline_mesh = null
			
func get_mouse_world_pos():
	if camera3d == null: return
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	#we will check if there's anything between the start and end points of the ray DIST long
	var start : Vector3 = camera3d.project_ray_origin(mouse)
	var end : Vector3 = camera3d.project_position(mouse, DIST)
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	
	params.collision_mask = 9
	
	var result : Dictionary = space.intersect_ray(params)
	if result.is_empty() == false:
		grabbed_object = result.collider
		outline_mesh = grabbed_object.get_node_or_null("Outline")
		if outline_mesh:
			outline_mesh.visible = true
		var tab = grabbed_object.get_node_or_null("Tab")
		if tab:
			var subviewport = tab.get_node("SubViewport")
			cur_sub_viewport = subviewport
	else:
		cur_sub_viewport = null
		#turn off highlight
		if outline_mesh:
			outline_mesh.visible = false
			grabbed_object = null
			outline_mesh = null
