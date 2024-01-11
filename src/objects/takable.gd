extends Node3D

@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)
@export var enable_tutorial_lable: bool = false

var interacter: Object = null
	
func start_interaction(new_interacter: Object) -> bool:
	if enable_tutorial_lable:
		new_interacter.key_billboards.KEY_E.global_position = global_position+tutorial_lable_pos
		new_interacter.key_billboards.KEY_E.set_visible(true)

	if Input.is_action_just_pressed("take"):
		queue_free()
	return false
	
func interact() -> void:
	pass

func end_interaction() -> void:
	interacter = null
