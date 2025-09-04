class_name TeleportPointData extends SceneObject

var point_instance : TeleportPoint
var teleport_pos : Vector3
var spawn_number : Globals.SPAWN_OPTIONS

func _init(_scene : LoadableScene, _instance : TeleportPoint, _parent : GameObject) -> void:
	super(_scene, _instance, _parent)
	point_instance = instance as TeleportPoint
	teleport_pos = point_instance.teleport_pos
	spawn_number = point_instance.spawn_point_number
	scene.teleport_points[spawn_number] = self
	if spawn_number == Globals.SPAWN_OPTIONS.ONE:
		scene.main_teleport_point = self
