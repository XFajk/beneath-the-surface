extends RigidBody3D

var interacter: Object = null

func _physics_process(delta):
	if interacter != null:
		interact()

func start_interact(new_interacter: Object) -> bool:
	if Input.is_action_pressed("pick_up"):
		interacter = new_interacter
		return true
	
	return false

func interact() -> void:
	if Input.is_action_pressed("pick_up"):
		gravity_scale = 0.0
		linear_velocity = (interacter.hand.global_position - global_position)*1000.0*get_physics_process_delta_time()
	else:
		end_interaction()
		gravity_scale = 1.0
	
func end_interaction() -> void:
	interacter = null
