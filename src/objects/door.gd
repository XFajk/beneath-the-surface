extends StaticBody3D

var interacter: Object = null

@export_category("Totorial lable")
@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)
@export var enable_tutorial_lable: bool = false

@export_category("Rotation cap")
@export var min_door_clamp: float = -90
@export var max_door_clamp: float = 0

@export_category("Locking")
@export var locked: bool = false
@export_range(1, 4, 1) var lock_level

var door_drager: Node3D = null

func _physics_process(delta: float) -> void:
	if interacter != null:
		interact()
	
func start_interaction(new_interacter: Object) -> bool:
	if enable_tutorial_lable:
		new_interacter.key_billboards.LEFT_MOUSE_BUTTON.global_position = global_position+transform.basis*tutorial_lable_pos
		new_interacter.key_billboards.LEFT_MOUSE_BUTTON.set_visible(true)
		new_interacter.key_billboards.KEY_E.global_position = global_position+transform.basis*tutorial_lable_pos+Vector3(0, 0.21, 0)
		new_interacter.key_billboards.KEY_E.set_visible(true)
		
	if Input.is_action_just_pressed("pick_up"):
		door_drager = Node3D.new()
		
		interacter = new_interacter
		interacter.interaction_ray.add_child(door_drager)
		var collision_point: Vector3 = interacter.interaction_ray.get_collision_point()
		door_drager.position = interacter.to_local(collision_point)*-1
		
		return true
	return false
	
func interact() -> void:
	if Input.is_action_pressed("pick_up"):
		look_at(door_drager.global_position)
		rotation.x = 0.0
		rotation.z = 0.0
		rotation.y = clamp(
			rotation.y,
			deg_to_rad(min_door_clamp), deg_to_rad(max_door_clamp)
		)
	else:
		end_interaction()
	
func end_interaction() -> void:
	interacter = null
	door_drager = null

