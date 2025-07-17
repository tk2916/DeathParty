extends Node

func find_first_child_of_class(item : Node, type : Variant):
	for child in item.get_children():
		if is_instance_of(child, type):
			return child
	for child in item.get_children():
		return find_first_child_of_class(child, type)
	return null
	
func draw_debug_raycast(from: Vector3, to: Vector3, color: Color = Color.RED, duration: float = 1.0):
	var mesh_instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	
	var length = from.distance_to(to)
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02
	cylinder.height = length
	mesh_instance.mesh = cylinder
	
	# Position & rotate
	var mid = from.lerp(to, 0.5)
	mesh_instance.global_transform.origin = mid
	mesh_instance.look_at(to, Vector3.UP, true)
	mesh_instance.rotate_x(deg_to_rad(90)) # Align cylinder along the ray
	
	# Material (optional color)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.unshaded = true
	cylinder.material = mat
	
	get_tree().current_scene.add_child(mesh_instance)
	
	# Auto-remove after duration
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.timeout.connect(func():
		mesh_instance.queue_free()
		timer.queue_free()
	)
	mesh_instance.add_child(timer)
	timer.start()
