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
var lockpicking_speed: float = 0.0
var lockpicking_decrement_speed: float = 15.0

func _ready():
	desired_angle = start_door_angle
	rotation_degrees.y = start_door_angle
	

func _process(_delta):
	if interacter != null:
		interact()

func _physics_process(delta: float) -> void:
	rotation_degrees.y = lerp(rotation_degrees.y, desired_angle, delta*door_speed)
	
func start_interaction(new_interacter: Object) -> bool:
	if enable_tutorial_lable:
		if not locked:
			new_interacter.key_billboards.LEFT_MOUSE_BUTTON.global_position = global_position+transform.basis*tutorial_lable_pos
			new_interacter.key_billboards.LEFT_MOUSE_BUTTON.set_visible(true)
		else:
			new_interacter.key_billboards.LOCK_ICON.global_position = global_position+transform.basis*tutorial_lable_pos
			new_interacter.key_billboards.LOCK_ICON.set_visible(true)
			new_interacter.key_billboards.KEY_E.global_position = global_position+transform.basis*tutorial_lable_pos+Vector3(0, 0.21, 0)
			new_interacter.key_billboards.KEY_E.set_visible(true)
		
	if Input.is_action_just_pressed("pick_up") and not locked:
		if not opened:
			desired_angle = open_door_angle
			opened = true
		else:
			desired_angle = start_door_angle
			opened = false
	elif Input.is_action_just_pressed("pick_up") and locked:
		new_interacter.active_cursor_shake = 5
	
	
	if Input.is_action_just_pressed("take") and locked:
		interacter = new_interacter
		
		match interacter.lockpick_level:
			1:
				lockpicking_speed = 6
			2:
				lockpicking_speed = 8
			3: 
				lockpicking_speed = 12
			4: 
				lockpicking_speed = 18
				
		interacter.lockpicking_bar.visible = true
		
		return true
		
	return false
	
func interact() -> void:
	
	interacter.lockpicking_bar.visible = true
	
	if interacter.interaction_ray.get_collider() == null:
		end_interaction()
		return
	
	if Input.is_action_just_pressed("take"):
		interacter.lockpicking_bar.value += lockpicking_speed
		
	if interacter.captured_mouse:
		interacter.lockpicking_bar.visible = true
		interacter.lockpicking_bar.value -= lockpicking_decrement_speed*get_process_delta_time()
	else:
		interacter.lockpicking_bar.visible = false
	
	if interacter.lockpicking_bar.value > 99:
		locked = false
		end_interaction()
	
func end_interaction() -> void:
	interacter.lockpicking_bar.visible = false
	interacter.lockpicking_bar.value = 0
	interacter = null

