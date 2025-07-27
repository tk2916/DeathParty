class_name DragDropPolaroid extends ObjectViewerDraggable
var tree : SceneTree
var main_page_static : MeshInstance3D
var bookflip_instance : BookFlip

var grabbed_control : DragDropControl = null
var og_grabbed_control : DragDropControl = null

@onready var og_position : Vector3 = position
var mesh : MeshInstance3D

var item_resource : Resource

var og_scale : Vector3

func _init(_item_resource : Resource, _static_page_1 : MeshInstance3D, _bookflip_instance : BookFlip) -> void:
	super()
	item_resource = _item_resource
	bookflip_instance = _bookflip_instance
	main_page_static = _static_page_1
	og_scale = Vector3.ONE*_item_resource.inventory_scale

func _ready() -> void:
	super()
	tree = get_tree()
	mesh = Utils.find_first_child_of_class(self, MeshInstance3D)
	scale = og_scale
	
func return_to_og_position():
	position = og_position

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

##FIND UI
func find_raycasted_ui_recursive(coords : Vector2, node : Control) -> Control:
	for child in node.get_children():
		if child.visible:
			var hover_area : Rect2 = Rect2(child.position, child.size)
			if hover_area.has_point(coords):
				return find_raycasted_ui_recursive(coords, child)
	return node

func find_raycasted_ui(coords : Vector2, viewport : Viewport) -> Control:
	for child in viewport.get_children():
		if child.visible:
			var hover_area : Rect2 = Rect2(child.position, child.size)
			if hover_area.has_point(coords):
				return find_raycasted_ui_recursive(coords, child)
	return null
##END FIND UI

var debug_dot : ColorRect = null

# Add these functions to your class without changing raycast_to_page

#func create_debug_dot(viewport: Viewport, coords: Vector2, color:Color=Color.BLUE):
	## Remove existing dot
	##if debug_dot != null:
		##debug_dot.queue_free()
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

#func create_debug_cube(parent:Node3D, pos : Vector3):
	#var cube : MeshInstance3D = MeshInstance3D.new()
	#cube.mesh = BoxMesh.new()
	#cube.scale = Vector3(.1,.1,.1)
	#cube.material_overlay = StandardMaterial3D.new()
	#cube.material_overlay.albedo_color = Color.ORANGE
	##get_tree().root.get_child(0).add_child(cube)
	#parent.add_child(cube)
	#cube.position = pos
	#
#func create_debug_cube_global(pos : Vector3):
	#var cube : MeshInstance3D = MeshInstance3D.new()
	#cube.mesh = BoxMesh.new()
	#cube.scale = Vector3(.1,.1,.1)
	#cube.material_overlay = StandardMaterial3D.new()
	#cube.material_overlay.albedo_color = Color.ORANGE
	#get_tree().root.get_child(0).add_child(cube)
	#cube.global_position = pos

func raycast_to_page(viewport : Viewport):
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var camera3d : Camera3D = Interact.camera3d
	var start : Vector3 = mesh.global_position
	var end : Vector3 = start - self.transform.basis.z * Interact.DIST#camera3d.global_transform.basis.z.normalized()*Interact.DIST#self.global_transform.basis.y.normalized()*.5#Vector3(0,0,1)#start - Vector3(0,0,Interact.DIST)#self.global_transform.basis.z * Interact.DIST
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	params.collision_mask = 9
	params.exclude = [self.get_rid()]
	var result : Dictionary = space.intersect_ray(params)
	if result:
		var global_position_hit : Vector3 = result.position	
		
		#use coordinates relative to main_page_static (non-animated main page)
		var local_position_hit : Vector3 = main_page_static.to_local(global_position_hit)
		#create_debug_dot(viewport, camera3d.unproject_position(global_position_hit), Color.PURPLE)
		var surface : Array = main_page_static.mesh.surface_get_arrays(0)
		var UVs : PackedVector2Array = surface[Mesh.ARRAY_TEX_UV]
		
		'''
		hit_indices = [Vector3(hit_indices), Vector3(baricentric_coords)]
		'''
		var hit_indices : Array[Vector3] = find_collided_triangle(local_position_hit, surface)
		if hit_indices.size() == 0: #no triangle found
			return null
		var indices = hit_indices[0]
		var bari_coords = hit_indices[1]
		
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
		var viewport_coords = uv_to_viewport_coords(interpolated_uv_coords, viewport)
		#create_debug_dot(viewport, viewport_coords)
		var control_hit : Control = find_raycasted_ui(viewport_coords, viewport)
		if control_hit:
			return control_hit
		return null
		
func callControlFuncs():
	var hit_control = raycast_to_page(bookflip_instance.cur_subviewport)
	if hit_control:
		if hit_control is DragDropControl:
			og_grabbed_control = grabbed_control
			grabbed_control = hit_control
			if og_grabbed_control == grabbed_control: return
			if og_grabbed_control:
				og_grabbed_control.exit_hover()
			grabbed_control.enter_hover()
	else:
		if grabbed_control:
			grabbed_control.exit_hover()
			grabbed_control = null
		
func _physics_process(delta: float) -> void:
	if dragging:
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(4, false)
	else:
		self.set_collision_layer_value(1, true)
		self.set_collision_layer_value(4, true)
	#var albedo_texture : Texture = main_page.material_override.get_shader_parameter("albedo_texture")
	if bookflip_instance.cur_subviewport and dragging:#albedo_texture is ViewportTexture:
		callControlFuncs()
				
func _input(event: InputEvent) -> void:
	if grabbed_control and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed == false:
				grabbed_control.mouse_up(item_resource, self)

##INHERITED
func enter_hover() -> void:
	if tree == null: return
	var tween = tree.create_tween()
	tween.tween_property(self, "scale", og_scale*1.2, .2)
	
func exit_hover() -> void:
	if tree == null: return
	var tween = tree.create_tween()
	tween.tween_property(self, "scale", og_scale, .2)
	
func on_mouse_up() -> void:
	super()
	callControlFuncs()
