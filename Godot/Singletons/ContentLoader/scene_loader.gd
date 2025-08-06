class_name SceneLoader extends Area3D

@export var disabled_on_first_pass : bool = false
@export var teleport_player : bool = true
@export var offload_delay : float = 2.0
@export var scene_going_right : String
@export var scene_going_left : String

@onready var color_rect : ColorRect = $CanvasLayer/ColorRect

var teleport_pos : Vector3 = Vector3(-1,-1,-1)

var player : Player
var player_touched : bool = false

func _ready() -> void:
	#print("Sceneloader ready")
	#if position_left != Vector3(-1,-1,-1): return
	var teleport_point : Node3D = $TeleportPoint
	#print("OnReady positions: ", teleport_left.global_position, teleport_right.global_position)
	teleport_point.visible = false
	if teleport_pos == Vector3(-1,-1,-1):
		teleport_pos = teleport_point.global_position
	#print("Sceneloader ready, teleport left: ", position_left)
	
	print("Scene going left: ", self.name, scene_going_left)
	#print("Teleport left: ", position_left)

func is_player_facing_collider(player) -> bool:
	var player_forward = -player.transform.basis.z
	var dot_product = player_forward.dot(self.transform.basis.z)
	return dot_product > 0 #facing towards if > 0

func _on_body_entered(body: Node3D) -> void:
	print("Body entered: ", self.name)
	if player_touched: return
	if !(body.is_in_group("player")): return
	player_touched = true
	if disabled_on_first_pass:
		disabled_on_first_pass = false
		return
	
	player = body as Player
	var is_facing_collider : bool = is_player_facing_collider(player.model)
	if is_facing_collider == false:
		ContentLoader.load_scene(scene_going_right)
		print("Loaded scene going right: ", scene_going_right)
	elif is_facing_collider == true:
		ContentLoader.load_scene(scene_going_left)
		print("Loaded scene going left: ", scene_going_left)
		
	if teleport_player:
		loading_screen_on(teleport_pos)

func _on_body_exited(body: Node3D) -> void:
	if !(body.is_in_group("player")): return
	player_touched = false
	await get_tree().create_timer(offload_delay).timeout #wait a bit so the player doesn't see it being unloaded
	ContentLoader.offload_old_scenes()
	
func loading_screen_on(new_global_position : Vector3):
	print("Loading screen on")
	var tween : Tween = ContentLoader.fade_loading_screen_in(1)
	tween.tween_callback(loading_screen_off.bind(new_global_position))
	
func loading_screen_off(new_global_position : Vector3):
	print("Teleporting player to: ", new_global_position)
	player.global_position = new_global_position
