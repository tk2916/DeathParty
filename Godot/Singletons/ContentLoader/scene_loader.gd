class_name SceneLoader extends Interactable

@export var use_front_icon : bool = false
@export var teleport_player : bool = true
@export var offload_delay : float = 0
@export var target_location_index : Globals.SCENE_LOCATIONS_ENUM = Globals.SCENE_LOCATIONS_ENUM.Entrance
var target_scene : String:
	get: return Globals.get_scene_location(target_location_index)
	
@export var local_spawn_point : Globals.SPAWN_OPTIONS = Globals.SPAWN_OPTIONS.ONE

@export var play_door_sound: bool = false

@onready var press_e_left : Sprite3D = $PressELeft
@onready var press_e_right : Sprite3D = $PressERight
@onready var press_e_front : Sprite3D = $PressEFront

var teleport_point : TeleportPointData

func _ready() -> void:
	super()
	clear_icons()

func is_player_facing_collider(player_model : Node3D) -> bool:
	var player_forward : Vector3 = -player_model.transform.basis.z
	var dot_product : float = player_forward.dot(self.transform.basis.z)
	return dot_product > 0 #facing towards if > 0
		
func on_interact() -> void:
	super()
	print("Teleport point for ", target_scene, " is ", teleport_point)
	ContentLoader.scene_loader_teleport(target_scene, teleport_point)
		
	if play_door_sound:
		Sounds.play_door()

func clear_icons()->void:
	press_e_right.visible = false
	press_e_left.visible = false
	press_e_front.visible = false
	
func on_in_range(in_range : bool) -> void:
	super(in_range)
	print("In range of SceneLoader to ", target_scene)
	clear_icons()
	if in_range:
		if use_front_icon:
			##Front/Back icon
			press_e_front.visible = true
		else:
			##Left/Right icon
			var is_facing_collider : bool = is_player_facing_collider(Globals.player.model)
			if is_facing_collider == false:
				press_e_right.visible = true
			else:
				press_e_left.visible = true
		
	
