class_name SceneLoader extends Area3D

@export var disabled_on_first_pass : bool = false
@export var offload_delay : float = 2.0
@export var scene_going_right : String
@export var scene_going_left : String

var player_touched : bool = false

func is_player_facing_collider(player) -> bool:
	var player_forward = -player.transform.basis.z
	var dot_product = player_forward.dot(self.transform.basis.z)
	print("Dot product: ", dot_product)
	return dot_product > 0 #facing towards if > 0

func _on_body_entered(body: Node3D) -> void:
	print("Body entered")
	if player_touched: return
	if !(body.is_in_group("player")): return
	player_touched = true
	if disabled_on_first_pass:
		disabled_on_first_pass = false
		return
	
	var player = body as Player
	var is_facing_collider : bool = is_player_facing_collider(player.model)
	if is_facing_collider == false:
		print("Player not facing scene: trying to load ", scene_going_right)
		ContentLoader.load_scene(scene_going_right)
	elif is_facing_collider == true:
		print("Player facing scene")
		ContentLoader.load_scene(scene_going_left)

func _on_body_exited(body: Node3D) -> void:
	if !(body.is_in_group("player")): return
	player_touched = false
	await get_tree().create_timer(offload_delay).timeout #wait a bit so the player doesn't see it being unloaded
	ContentLoader.offload_old_scenes()
