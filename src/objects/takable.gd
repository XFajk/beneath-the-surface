extends Node3D

@export var score: int = 100
@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)
@export var enable_tutorial_label: bool = false

var interacter: Object = null
	
func start_interaction(new_interacter: Object) -> bool:
	if enable_tutorial_label:
		new_interacter.key_billboards.KEY_E.global_position = global_position+tutorial_lable_pos
		new_interacter.key_billboards.KEY_E.set_visible(true)

	if Input.is_action_just_pressed("take"):
		if new_interacter.number_of_items < new_interacter.player_state.inventory_size:
			var copy_particles: GPUParticles3D = new_interacter.take_particles.instantiate()
			new_interacter.add_child(copy_particles)
			copy_particles.global_position = global_position
			new_interacter.score += score
			new_interacter.number_of_items += 1
			queue_free()
		else:
			new_interacter.active_cursor_shake = 5
	return false
	
func interact() -> void:
	pass

func end_interaction() -> void:
	interacter = null
