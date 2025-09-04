class_name TeleportPointData extends SceneObject

var teleport_pos : Vector3
var spawn_number : Globals.SPAWN_OPTIONS

func _init(scene : LoadableScene, instance : TeleportPoint, parent : GameObject) -> void:
	super(scene, instance, parent)
	teleport_pos = instance.teleport_pos
	spawn_number = instance.spawn_point_number
	scene.teleport_points.push_back(self)
