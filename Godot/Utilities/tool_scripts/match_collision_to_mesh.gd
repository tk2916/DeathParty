## Put this tool (temporarily) on the parent of an object with childs
## CollisionShape3D and MeshInstance3D that you want to have the same size

## CHANGE MESHINSTANCE3D, CollisionShape3D will match it
@tool
extends StaticBody3D

func _process(delta: float) -> void:
	if true and $CollisionShape3D.shape.size != $MeshInstance3D.mesh.size:
		$CollisionShape3D.shape.size = $MeshInstance3D.mesh.size
