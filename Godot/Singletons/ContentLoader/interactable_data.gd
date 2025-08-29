class_name InteractableData

var name : String
var file : PackedScene
var transform : Transform3D
var g_pos : Vector3
var aabb : AABB
var interactable : Interactable = null
var parent_scene : Node3D = null
var owner_quadrants : Array[Quadrant]
var active : bool = false #set by add_interactable() in Quadrant

func _init(_name : String, _file : PackedScene, _interactable : Interactable) -> void:
	name = _name
	file = _file
	interactable = _interactable
	transform = interactable.global_transform
	var collision_shape : CollisionShape3D = interactable.interaction_detector.collision_shape
	aabb =  Utils.get_collision_shape_aabb(collision_shape)
	print("Initiated interactable data for : ", name, " | file: ", file)

func load_in(_parent_scene : Node3D):
	active = true
	parent_scene = _parent_scene
	interactable = file.instantiate() as Interactable
	assert(interactable != null, name + " doesn't have the NPC/Interactable script attached to it in its base scene!")
	parent_scene.add_child.call_deferred(interactable)
	interactable.call_deferred("set_global_transform", transform)

func add_quadrant(quad:Quadrant) -> void:
	owner_quadrants.push_back(quad)

func get_surface_materials(mesh : MeshInstance3D) -> Array[Material]:
	var arr : Array[Material] = []
	for i in range(0,2):
		var material : Material = mesh.get_active_material(i)
		if material:
			arr.push_back(material)
	return arr

func fade(fade_in : bool = true):
	print("Fading in")
	var mesh_parts : Array[Node] = Utils.get_descendants(interactable, [MeshInstance3D], false)
	var alpha_initial : float = 1
	var alpha_final : float = 0
	if fade_in:
		alpha_initial = 0
		alpha_final = 1
	for mesh : MeshInstance3D in mesh_parts:
		print("Tween mesh")
		var materials : Array[Material] = get_surface_materials(mesh)
		for material : Material in materials:
			print("Tween material")
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = alpha_initial
			var tween = parent_scene.get_tree().create_tween()
			tween.set_parallel(true)
			tween.tween_property(mesh, "albedo_color:a", alpha_final, 2)

func offload():
	#might not be offloaded bc another quadrant is still active
	var deactivate = true
	for quad : Quadrant in owner_quadrants:
		if quad.active == true:
			deactivate = false
			break
	if !deactivate: return
	active = false
	if parent_scene and interactable:
		parent_scene.remove_child.call_deferred(interactable)
		interactable.queue_free()
