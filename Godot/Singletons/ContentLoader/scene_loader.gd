@tool

class_name SceneLoader extends Interactable

enum Direction {LEFT, RIGHT, DOWN}

@export var target_location_index: Globals.SCENE_LOCATIONS_ENUM = Globals.SCENE_LOCATIONS_ENUM.Entrance
var target_scene: String:
	get: return Globals.get_scene_location(target_location_index)
@export var local_spawn_point: Globals.SPAWN_OPTIONS = Globals.SPAWN_OPTIONS.ONE
@export var play_door_sound: bool = false

@export_group("assets")
@export var left_arrow_asset: CompressedTexture2D
@export var right_arrow_asset: CompressedTexture2D
@export var down_arrow_asset: CompressedTexture2D

@export_group("")
@export var arrow_direction: Direction:
	set(dir):
		arrow_direction = dir
		match arrow_direction:
			Direction.LEFT:
				%Popup.texture = left_arrow_asset
			Direction.RIGHT:
				%Popup.texture = right_arrow_asset
			Direction.DOWN:
				%Popup.texture = down_arrow_asset


var teleport_point: TeleportPointData

const POPUP_SCALE = .1

func _ready() -> void:
	super ()
	popup.scale = Vector3.ONE * POPUP_SCALE
	arrow_direction = arrow_direction

func is_player_facing_collider(player_model: Node3D) -> bool:
	var player_forward: Vector3 = - player_model.transform.basis.z
	var dot_product: float = player_forward.dot(self.transform.basis.z)
	return dot_product > 0 # facing towards if > 0
		
func on_interact() -> void:
	if !enabled: return
	super ()
	print("Teleport point for ", target_scene, " is ", teleport_point.spawn_number, " vs ", local_spawn_point)
	ContentLoader.scene_loader_teleport(target_scene, teleport_point)
		
	if play_door_sound:
		Sounds.play_door()
