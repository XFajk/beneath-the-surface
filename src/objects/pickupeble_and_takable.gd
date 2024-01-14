extends RigidBody3D

@export var score: int = 100
@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)
@export var enable_tutorial_lable: bool = false

var take_particles: PackedScene = preload("res://assets/entities/TakeParticles.tscn")

var interacter: Object = null

func _ready():
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	

func _physics_process(_delta):
	if interacter != null:
		interact()

func start_interaction(new_interacter: Object) -> bool:
	
	if enable_tutorial_lable:
		new_interacter.key_billboards.LEFT_MOUSE_BUTTON.global_position = global_position+tutorial_lable_pos
		new_interacter.key_billboards.LEFT_MOUSE_BUTTON.set_visible(true)
		new_interacter.key_billboards.KEY_E.global_position = global_position+tutorial_lable_pos+Vector3(0, 0.21, 0)
		new_interacter.key_billboards.KEY_E.set_visible(true)
	
	if Input.is_action_pressed("pick_up"):
		interacter = new_interacter
		set_collision_layer_value(1, false)
		return true
	
	if Input.is_action_just_pressed("take"):
		if new_interacter.number_of_items < new_interacter.inventory_size:
			var copy_particles: GPUParticles3D = take_particles.instantiate()
			new_interacter.add_child(copy_particles)
			copy_particles.global_position = global_position
			global.score += score
			new_interacter.number_of_items += 1
			queue_free()
		else:
			new_interacter.active_cursor_shake = 5
	
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
	set_collision_layer_value(1, true)
