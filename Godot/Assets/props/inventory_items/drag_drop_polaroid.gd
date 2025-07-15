class_name DragDropPolaroid extends ObjectViewerDraggable
var tree : SceneTree

func _ready() -> void:
	super()
	tree = get_tree()
	
func raycast_to_page():
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var camera3d : Camera3D = Interact.camera3d
	var mouse : Vector2 = Interact.mouse
	var start : Vector3 = self.position#camera3d.project_ray_origin(mouse)
	var end : Vector3 = camera3d.project_position(mouse, 10)#self.position+Vector3(0,10,0)#
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	#params.exclude = [self.get_node("CollisionShape3D").shape.get_rid()] #raycast excluding self
	params.collision_mask = 16
	var result : Dictionary = space.intersect_ray(params)
	if result:
		print("Collided with ", result, "!")
		
func _physics_process(delta: float) -> void:
	raycast_to_page()

##INHERITED
func enter_hover():
	if tree == null: return
	var tween = tree.create_tween()
	tween.tween_property(self, "scale", Vector3(1.2,1.2,1.2), .2)
	
func exit_hover():
	if tree == null: return
	var tween = tree.create_tween()
	tween.tween_property(self, "scale", Vector3(1,1,1), .2)
