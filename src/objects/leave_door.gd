extends StaticBody3D

@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)

var interacter: Object = null

func _process(_delta):
	if interacter != null:
		interact()
	
func start_interaction(new_interacter: Object) -> bool:
	new_interacter.key_billboards.HOLD_KEY_E.global_position = global_position+transform.basis*tutorial_lable_pos
	new_interacter.key_billboards.HOLD_KEY_E.set_visible(true)
	new_interacter.key_billboards.PRESS_KEY_E.global_position = global_position+transform.basis*tutorial_lable_pos+Vector3(0, 0.21, 0)
	new_interacter.key_billboards.PRESS_KEY_E.set_visible(true)
	
	if Input.is_action_just_pressed("take"):
		interacter = new_interacter
		interacter.hold_interaction_bar.set_visible(true)
		return true
	
	return false
	
func interact() -> void:
	if Input.is_action_just_released("take"):
		if interacter.number_of_items > 0:
			var copy_particles: GPUParticles3D = interacter.take_particles.instantiate()
			interacter.add_child(copy_particles)
			copy_particles.global_position = global_position+transform.basis*tutorial_lable_pos+Vector3(0, 0.21, 0)
			interacter.number_of_items = 0
			interacter.player_state.score += interacter.score
			interacter.score = 0
		end_interaction()
	
	if Input.is_action_pressed("take"):
		if interacter.interaction_ray.get_collider() == null:
			end_interaction()
			return
			
		if interacter.hold_interaction_bar.value > 99.9:
			interacter.player_state.won = true
			interacter.player_state.score += interacter.score
			interacter.hold_interaction_bar.value = 0.0
	
		interacter.hold_interaction_bar.value += get_process_delta_time()*50.0

func end_interaction() -> void:
	interacter.hold_interaction_bar.set_visible(false)
	interacter.hold_interaction_bar.value = 0.0
	interacter = null
