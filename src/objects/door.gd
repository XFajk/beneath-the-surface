extends StaticBody3D

var interacter: Object = null

@export_category("Totorial lable")
@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)
@export var enable_tutorial_lable: bool = false

@export_category("Rotation cap")
@export var start_door_angle: float = 0
@export var open_door_angle: float = 90
@export var door_speed: float = 3.0
var desired_angle: float = 0.0
var opened: bool = false

@export_category("Locking")
@export var locked: bool = false
@export_range(1, 4, 1) var lock_level


func _physics_process(delta: float) -> void:
	rotation_degrees.y = lerp(rotation_degrees.y, desired_angle, delta * door_speed)
	if interacter != null:
		interact()

func start_interaction(new_interacter: Object) -> bool:
	#if enable_tutorial_lable:
		#new_interacter.key_billboards.LEFT_MOUSE_BUTTON.global_position = global_position+transform.basistutorial_lable_pos
		#new_interacter.key_billboards.LEFT_MOUSE_BUTTON.set_visible(true)
		#new_interacter.key_billboards.KEY_E.global_position = global_position+transform.basis*tutorial_lable_pos+Vector3(0, 0.21, 0)
		#new_interacter.key_billboards.KEY_E.set_visible(true)

	if Input.is_action_just_pressed("pick_up"):
		if not opened:
			desired_angle = open_door_angle
			opened = true
		else:
			desired_angle = start_door_angle
			opened = false
		return true
	return false

func interact() -> void:
	pass

func end_interaction() -> void:
	interacter = null
