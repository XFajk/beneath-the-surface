extends Node3D
	
var interacter: Object = null
	
func start_interaction(new_interacter: Object) -> bool:
	if Input.is_action_just_pressed("take"):
		queue_free()
	return false
	
func interact() -> void:
	pass

func end_interaction() -> void:
	interacter = null
