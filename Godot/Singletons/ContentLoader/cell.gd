class_name Cell

var scene : LoadableScene
var id : int
var coords : Vector3
var aabb : AABB
var loadable_objects : Array[SceneObject]
var active : bool = true

var button : Button

func _init(_scene : LoadableScene, _id : int, cell_coords : Vector3, origin : Vector3, size : Vector3) -> void:
	scene = _scene
	id = _id
	coords = cell_coords
	aabb = AABB(origin, size)

func load_in():
	if loadable_objects.size() == 0: return
	scene.cell_debugger.add_cell(self)
	
func set_active(_active : bool, initial_load : bool) -> void:
	var start = Time.get_ticks_msec()
	#if !initial_load and active == _active: return #causes errors
	active = _active
	#print("Setting Cell ", id, " to active=", active)
	'''
	Set all objects active or inactive beforehand,
	so that we're not offloading and reloading children
	'''
	if initial_load:
		#otherwise it tries to access nodes that are being offloaded
		for obj : SceneObject in loadable_objects:
			obj.assign_existing_node()
	##Once active status is set, load/offload
	for obj : SceneObject in loadable_objects:
		if active:
			obj.load_in()
		else:
			#print("Offloading existing node: ", obj.name, " ", obj.parent_obj.name, " ", obj.instance)
			obj.offload()
	scene.cell_debugger.update_cell(self)
	var duration = (Time.get_ticks_msec() - start)
	#print("Duration of set_active: ", duration)

func intersects_interactable(data:SceneObject) -> bool:
	return intersects(data.aabb)

func intersects(aabb2:AABB):
	return aabb.intersects(aabb2)

func add_object(data:SceneObject) -> bool:
	#if data.cell_id != -1: return false #already assigned
	if intersects_interactable(data):
		#data.cell_id = self.id
		data.add_cell(self) #an obj might belong to multiple cells
		loadable_objects.push_back(data)
		return true
	else:
		return false
