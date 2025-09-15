class_name InteractionDetectorData extends SceneObject

var detector : InteractionDetector
var collision_shape_position : Vector3
var collision_shape_size : Vector3

'''
DEBUG NOTE: If your InteractionDetectors' CollisionShape3Ds are all the same size, 
remember to tick "Resource Local to Scene", so that they aren't all referring to the same BoxShape3D
'''

func _init(
	_scene : LoadableScene,
	_instance : InteractionDetector,
	_parent_node : GameObject,
) -> void:
	super(
	_scene, 
	_instance,
	_parent_node
	)
	detector = instance as InteractionDetector
	active = true
	save_properties()

func load_in() -> Node3D:
	await super()
	detector = instance as InteractionDetector
	load_properties()
	return detector

func save_properties() -> void:
	collision_shape_position = detector.collision_shape.position
	var shape : BoxShape3D =  detector.collision_shape.shape as BoxShape3D
	collision_shape_size = shape.size
	#print("SAVING [", detector.name, " | ", detector.get_instance_id(), " | ", scene.name, "] - Position: ", collision_shape_position, " Shape Size: ", collision_shape_size)
	
func load_properties() -> void:
	detector.collision_shape.position = collision_shape_position
	var shape : BoxShape3D = detector.collision_shape.shape as BoxShape3D
	shape.size = collision_shape_size
	#print("LOADING [", detector.name, " | ", detector.get_path(), " | ", scene.name, "] - Position: ", collision_shape_position, " Shape Size: ", collision_shape_size)
