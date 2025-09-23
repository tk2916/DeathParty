extends Node3D

var mouse : Vector2
const DIST : float = 1000.0

var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var result_position : Vector3 = Vector3(-1,-1,-1)
var grabbed_object : Node3D = null

var grabbed_control : ThreeDGUI = null
var og_grabbed_control : ThreeDGUI = null
var grabbed_scroll_container : ScrollContainer = null
const SCROLL_AMOUNT : int = 40

var dragged_object : ObjectViewerInteractable = null
var outline_mesh : MeshInstance3D = null

@onready var main_camera3d : Camera3D
@onready var camera3d : Camera3D

var og_viewport : Viewport
var cur_sub_viewport : Viewport = null
var object_viewer : ObjectViewer = null

var main_page_static : MeshInstance3D

signal mouse_position_changed(delta : Vector2)

func _ready() -> void:
	og_viewport = get_viewport()
	main_camera3d = og_viewport.get_camera_3d()
	camera3d = main_camera3d

	params.collide_with_areas = true
	params.collision_mask = 9

	var main : Node = get_tree().root.get_node_or_null("Main")
	if main:
		object_viewer = main.get_node("ObjectViewerCanvasLayer/ObjectViewer")
		object_viewer.enabled.connect(switch_camera)
	
func switch_camera(enabled : bool, new_cam : Camera3D = null) -> void:
	if !enabled:
		camera3d = main_camera3d
	else:
		camera3d = new_cam

func _input(event: InputEvent) -> void:
	if !DialogueSystem.in_dialogue:
		if event is InputEventMouseMotion:
			var motion_event : InputEventMouseMotion = event
			mouse = motion_event.position
			mouse_position_changed.emit(motion_event.relative)
			get_mouse_world_pos()
			if cur_sub_viewport and main_page_static and result_position != Vector3(-1,-1,-1):
				cur_sub_viewport.push_input(event)
				og_grabbed_control = grabbed_control
				grabbed_control = convert_position(result_position, cur_sub_viewport, main_page_static)
				pass_input_to_collided_ui()
		
		elif event is InputEventMouseButton:
			var button_event : InputEventMouseButton = event
			#print("Input, scroll container: ", grabbed_scroll_container)
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:# and event.pressed:
				if grabbed_scroll_container:
					grabbed_scroll_container.scroll_vertical = grabbed_scroll_container.scroll_vertical-SCROLL_AMOUNT
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:# and event.pressed:
				if grabbed_scroll_container:
					grabbed_scroll_container.scroll_vertical = grabbed_scroll_container.scroll_vertical+SCROLL_AMOUNT
			elif button_event.button_index == MOUSE_BUTTON_LEFT:
				if grabbed_control and button_event.pressed == true:
					grabbed_control.on_mouse_down()
				if button_event.pressed == false: 
					#will fire even if mouse is outside of object
					if dragged_object == null: return
					dragged_object.on_mouse_up()
					dragged_object = null
				if grabbed_object and grabbed_object is ObjectViewerInteractable:
					print("Clicked on ObjectViewerInteractable")
					if button_event.pressed == true:
						grabbed_object.on_mouse_down()
						dragged_object = grabbed_object

func mouse_in_world_projection() -> Vector3:
	return camera3d.project_position(mouse, DIST)

#func create_debug_dot(coords: Vector2, color:Color=Color.BLUE):
	#var viewport : Viewport = camera3d.get_viewport()
	#var debug_dot : ColorRect
	#
	## Create new debug dot
	#debug_dot = ColorRect.new()
	#debug_dot.color = color
	#debug_dot.size = Vector2(10, 10)  # 10x10 pixel red dot
	#debug_dot.position = coords - Vector2(5, 5)  # Center the dot on the coordinates
	#debug_dot.z_index = 1000  # Make sure it's on top
	#debug_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't interfere with mouse events
	#
	## Add to viewport
	#if viewport == null: return
	#viewport.add_child(debug_dot)
	#
	## Optional: Make it fade after a short time
	#var tween = viewport.create_tween()
	#tween.tween_property(debug_dot, "modulate:a", 0.0, 2)
	#tween.tween_callback(func(): if debug_dot: debug_dot.queue_free())

func get_mouse_world_pos() -> void:
	if camera3d == null: return
	mouse = camera3d.get_viewport().get_mouse_position() #important bc otherwise it gets the wrong mouse pos
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	#we will check if there's anything between the start and end points of the ray DIST long
	var start : Vector3 = camera3d.project_ray_origin(mouse)
	#create_debug_dot(mouse)
	var end : Vector3 = mouse_in_world_projection()

	params.from = start
	params.to = end
	
	var result : Dictionary = space.intersect_ray(params)
	if result.is_empty() == false:
		var og_grabbed_object : Node3D = grabbed_object
		
		grabbed_object = result.collider
		result_position = result.position
		#print("Grabbed object: ", grabbed_object.name)
		if og_grabbed_object == grabbed_object:
			#print("Grabbed object equal")
			return
		#print("Grabbed object not in group: ", grabbed_object.name)
		if grabbed_object is ObjectViewerInteractable:
			#print("Grabbed object: ", grabbed_object.name)
			if og_grabbed_object and og_grabbed_object is ObjectViewerInteractable:
				if !(og_grabbed_object is JournalInventoryCollider and (grabbed_object is DragDropPolaroid or grabbed_object is ClickableInventoryItem)):
					og_grabbed_object.exit_hover()
			grabbed_object.enter_hover()
	else:
		result_position = Vector3(-1,-1,-1)
		if grabbed_object and grabbed_object is ObjectViewerInteractable:
			grabbed_object.exit_hover()
		grabbed_object = null
		
func set_active_subviewport(subviewport : Viewport) -> void:
	if subviewport == og_viewport:
		cur_sub_viewport = null
		return
	cur_sub_viewport = subviewport
func clear_active_subviewport() -> void:
	cur_sub_viewport = null
	
##FOR RAYCASTING INTO GUIs
func pass_input_to_collided_ui() -> void:
	if grabbed_control:
		if og_grabbed_control == grabbed_control: return
		if og_grabbed_control:
			og_grabbed_control.exit_hover()
		grabbed_control.enter_hover()
	else:
		if og_grabbed_control:
			og_grabbed_control.exit_hover()

func raycast_to_page(viewport : Viewport, map_mesh : MeshInstance3D, start : Vector3, end : Vector3, exclusions : Array[RID]) -> Control:
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var camera3d : Camera3D = Interact.camera3d
	if start == Vector3(-1,-1,-1):
		start = camera3d.project_ray_origin(mouse)
	if end == Vector3(-1,-1,-1):
		end = mouse_in_world_projection()
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	params.collision_mask = 9
	params.exclude = exclusions
	var result : Dictionary = space.intersect_ray(params)
	if result:
		var global_position_hit : Vector3 = result.position	
		return convert_position(global_position_hit, viewport, map_mesh)
	return null
		

func convert_position(global_position_hit : Vector3, viewport : Viewport, map_mesh : MeshInstance3D) -> Control:
	#use coordinates relative to main_page_static (non-animated main page)
	var local_position_hit : Vector3 = map_mesh.to_local(global_position_hit)
	#create_debug_dot(camera3d.unproject_position(global_position_hit), Color.PURPLE)
	var surface : Array = map_mesh.mesh.surface_get_arrays(0)
	var UVs : PackedVector2Array = surface[Mesh.ARRAY_TEX_UV]
	
	'''
	hit_indices = [Vector3(hit_indices), Vector3(baricentric_coords)]
	'''
	var hit_indices : Array[Vector3] = find_collided_triangle(local_position_hit, surface)
	if hit_indices.size() == 0: #no triangle found
		return null
	var indices := hit_indices[0]
	var bari_coords := hit_indices[1]
	
	var UV_coordinates : Array[Vector2] = [
		UVs[indices.x],
		UVs[indices.y],
		UVs[indices.z],
	]
	'''
	Use Baricentric coords to interpolate the three UV coordinates to 
	find the exact UV coordinates (not just the triangle corners)
	'''
	var interpolated_uv_coords : Vector2 = UV_coordinates[0]*bari_coords.x + UV_coordinates[1]*bari_coords.y + UV_coordinates[2]*bari_coords.z
	var viewport_coords := uv_to_viewport_coords(interpolated_uv_coords, viewport)
	#create_debug_dot(viewport_coords)
	return find_raycasted_ui(viewport_coords, viewport)

##FIND RAYCASTED UI
var deepest_node : ThreeDGUI
var deepest_node_depth : int = 0
func find_raycasted_ui_recursive(coords : Vector2, node : Control, cur_depth : int) -> void:
	for child : Control in node.get_children():
		if child.visible:
			var hover_area : Rect2 = Rect2(child.global_position, child.size)
			if hover_area.has_point(coords):
				if deepest_node_depth <= cur_depth and child is ThreeDGUI:
					deepest_node = child
					deepest_node_depth = cur_depth
				if child is ScrollContainer and child.get_v_scroll_bar().visible == true:
					grabbed_scroll_container = child
				find_raycasted_ui_recursive(coords, child, cur_depth+1)

func find_raycasted_ui(coords : Vector2, viewport : Viewport) -> ThreeDGUI:
	deepest_node = null
	deepest_node_depth = 0
	grabbed_scroll_container = null
	
	for child in viewport.get_children():
		if child.visible:
			var hover_area : Rect2 = Rect2(child.position, child.size)
			if hover_area.has_point(coords):
				if child is ThreeDGUI:
					deepest_node = child
				find_raycasted_ui_recursive(coords, child, deepest_node_depth)
	return deepest_node
	
func find_collided_triangle(local_position_hit : Vector3, surface : Array) -> Array[Vector3]:
	var vertices : PackedVector3Array = surface[Mesh.ARRAY_VERTEX]
	var indices : PackedInt32Array = surface[Mesh.ARRAY_INDEX]
	#indices tell you which vertices make up a triangle (every 3 vertices)
	for i in range(0, indices.size(), 3): #loop through every third index
		#get the 3 indices that link to the vertices of the triangle
		var index0 : int = indices[i]
		var index1 : int = indices[i+1]
		var index2 : int = indices[i+2]
		
		var point0 : Vector3 = vertices[index0]
		var point1 : Vector3 = vertices[index1]
		var point2 : Vector3 = vertices[index2]
		
		'''
		Barycentric coordinates: checks if point is inside triangle
		by assigning 3 weights, combined with the triangle's vertices
		P = w0 * point0 + w1 * point1 + w2 * point2
		It's inside the triangle if 
		w0 + w1 + w2 = 1 & each weight is between 0 & 1
		'''
		var bari_coords : Vector3 = Geometry3D.get_triangle_barycentric_coords(local_position_hit, point0, point1, point2)
		if bari_coords.x >= 0 and bari_coords.y >= 0 and bari_coords.z >= 0:
			var sum : float = bari_coords.x + bari_coords.y + bari_coords.z
			if abs(sum-1.0) <= .05: #0.95 to 1.05
				return [Vector3(index0, index1, index2), bari_coords] #return indices (used to get UV coords)
	return []

func uv_to_viewport_coords(uv : Vector2, viewport : Viewport) -> Vector2:
	return uv * Vector2(viewport.size)
##END FIND RAYCASTED UI
