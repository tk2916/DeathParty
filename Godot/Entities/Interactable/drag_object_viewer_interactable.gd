class_name ObjectViewerDraggable extends ObjectViewerInteractable

var dragging : bool = false
@export var constrain_x : bool = false
@export var constrain_y : bool = false

var local_y_dir : Vector3
var local_x_dir : Vector3

var parallel_plane : Plane

func _ready() -> void:
	Interact.mouse_position_changed.connect(on_mouse_pos_changed)
	parallel_plane = Plane(self.global_transform.basis.y, self.global_position)

func on_mouse_pos_changed(delta : Vector2):
	if !dragging:
		return
	var origin : Vector3 = Interact.camera3d.project_ray_origin(Interact.mouse)
	var direction : Vector3 = Interact.camera3d.project_ray_normal(Interact.mouse)
	var intersection : Vector3 = parallel_plane.intersects_ray(origin, direction)
	
	if intersection:
		global_position = intersection
		if not constrain_y:
			global_position.y = intersection.y
		if not constrain_x:
			global_position.x = intersection.x

##INHERITED
func on_mouse_down() -> void:
	dragging = true
	
func on_mouse_up() -> void:
	dragging = false
	
