@tool
class_name SceneLoader extends Interactable


enum Direction {LEFT, RIGHT, DOWN}
enum DoorSoundType {WOOD, METAL}

## enable to give this scene loader an interactable popup
## (disable to make the scene loader instantly tp the player when they enter its area)
@export var interactable := true:
	set(value):
		interactable = value
		notify_property_list_changed()

		if interactable:
			popup_arrow_direction = popup_arrow_direction
		else:
			%Popup.texture = null

# SceneLoader functionality
## the scene this scene loader will load
@export var target_scene: Globals.SCENES = Globals.SCENES.Entrance
## the teleport point within the target scene that the player will be teleported to
@export var local_spawn_point: Globals.SPAWN_OPTIONS = Globals.SPAWN_OPTIONS.ONE
## enable to play a door sound effect when this scene loader is used
@export var play_door_sound: bool = false:
	set(value):
		play_door_sound = value
		notify_property_list_changed()
## the type of door sound that will play (if play door sound is true)
@export var door_sound_type: DoorSoundType = DoorSoundType.WOOD

#Popup
@export_group("assets")
@export var left_arrow_asset: CompressedTexture2D
@export var right_arrow_asset: CompressedTexture2D
@export var down_arrow_asset: CompressedTexture2D

@export_group("")
## the direction the arrow on the popup will point to
@export var popup_arrow_direction: Direction:
	set(dir):
		popup_arrow_direction = dir
		match popup_arrow_direction:
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


func _validate_property(property: Dictionary) -> void:
	if property.name == "popup_arrow_direction":
		if not interactable:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "door_sound_type":
		if not play_door_sound:
			property.usage = PROPERTY_USAGE_NO_EDITOR


func is_player_facing_collider(player_model: Node3D) -> bool:
	var player_forward: Vector3 = - player_model.transform.basis.z
	var dot_product: float = player_forward.dot(self.transform.basis.z)
	return dot_product > 0 # facing towards if > 0


func on_interact() -> void:
	super ()
	if !enabled: return
	print("Teleport point for ", target_scene, " is ", teleport_point.spawn_number, " vs ", local_spawn_point)
	ContentLoader.scene_loader_teleport(target_scene, teleport_point)
	handle_audio()


func on_in_range(in_range: bool) -> void:
	if !enabled: return
	if interactable:
		super (in_range)
	else:
		print("Teleport point for ", target_scene, " is ", teleport_point.spawn_number, " vs ", local_spawn_point)
		ContentLoader.scene_loader_teleport(target_scene, teleport_point)
		handle_audio()


func handle_audio() -> void:
	if play_door_sound:
		match door_sound_type:
			DoorSoundType.WOOD:
				Sounds.play_door()
			DoorSoundType.METAL:
				Sounds.play_metal_door()
