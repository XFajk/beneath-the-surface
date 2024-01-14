extends CharacterBody3D

@onready var key_billboards: Dictionary = {
	PRESS_KEY_E = $KeyBillboards/PressKeyE,
	HOLD_KEY_E = $KeyBillboards/HoldKeyE,
	KEY_E = $KeyBillboards/KeyE,
	LEFT_MOUSE_BUTTON = $KeyBillboards/LeftMouseButton,
	LOCK_ICON = $KeyBillboards/LockIcon
}

@onready var head: Node3D = $Head
@onready var hand: Node3D = $Head/Eyes/Hand

@onready var stamina_bar: ProgressBar = $Head/Eyes/PlayerUI/StaminaBar
@onready var lockpicking_bar: ProgressBar = $Head/Eyes/PlayerUI/LockPickingBar
@onready var hold_interaction_bar: ProgressBar = $Head/Eyes/PlayerUI/HoldInteractionBar

@onready var main_camera: Camera3D = $Head/Eyes
@onready var tutorial_camera: Camera3D = $Head/Eyes/SubViewportContainer/SubViewport/TutorialCamera

@onready var interaction_ray: RayCast3D = $Head/Eyes/InteractionRay
@onready var cross_hair: Sprite2D = $Head/Eyes/PlayerUI/Crosshair/CrosshairSprite

@onready var body_collision: CollisionShape3D = $Body
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var crouch_check: RayCast3D = $CrouchCheckRay

@export_range(3, 7, 1) var inventory_size: int = 3
var number_of_items: int = 0

@export_category("Mouse")
@export var captured_mouse: bool = true
@export var mouse_sensitivity: float = 0.05

@export_category("Movement")
@export var walk_speed: float = 2
@export var runnig_speed: float = 5
@export var crouch_speed: float = 1
@export var acceleration: float = 1
var current_speed: float = 0.0
var final_direction: Vector3 = Vector3.ZERO

@export_category("Stamina")
@export var stamina_delition: float = 5
@export var stamina_regeneration: float = 2.5
@export var stamina_soft_limit: float = 30.0
@export var stamina_bar_blink_speed: float = 5.0
@export var stamina_bar_color_lerp_speed: float = 3.0
var stamina_bar_blink_index: float = 0.0
var reached_soft_limit: bool = false

@export_category("Physics")
@export var gravity: float = 30.0
@export var vertical_speed = 0.0

@export_category("Jumping")
@export var jump_strength: float = 8.5
var jumped: bool = false

@export_category("Crouch and Stand")
var is_crouching: bool = false

@export var go_to_chrouch_speed: float = 4.0

@export var player_stand_heigh: float = 1.9
@export var head_stand_height: float = 0.5

@export var player_crouch_heigh: float = 0.3
@export var head_crouch_height: float = -0.5

@export_category("Headbob")
@onready var head_bob_on: bool = global.head_bob_on
var head_bob_timmer: float = 0.0
@export var head_bob_walk_speed: float = 10.0
@export var head_bob_running_speed: float = 15.0
@export var head_bob_crouch_speed: float = 7.0
var head_bob_speed: float = 0.0
@export var head_bob_ammount: float = 10.0 # 1=big bob, 1000 small bob
var original_head_y: float = head_stand_height

@export_category("Lockpicking")
@export_range(1, 4, 1) var lockpick_level: int = 1

var active_cursor_shake: float = 0.0
var cursor_shake_timer: float = 0.0
@onready var original_cursor_pos: Vector2 = cross_hair.position

var in_interaction: bool = false
var interactible: Object = null

func _ready() -> void:
	
	$Head/Eyes/PlayerUI/OptionsMenu/TabContainer/Options/ScrollContainer/Buttons/HeadBob.button_pressed = global.head_bob_on
	
	# capture the mouse
	if captured_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	# setting the player size
	body_mesh.mesh.height = player_stand_heigh
	head.position.y = head_stand_height
	original_head_y = head_stand_height
	crouch_check.position.y = player_stand_heigh/2

func _input(event) -> void:
	if event is InputEventMouseMotion and captured_mouse:
		var mouse_y: float = deg_to_rad(event.relative.y*mouse_sensitivity)
		var mouse_x: float = deg_to_rad(-event.relative.x*mouse_sensitivity)
		
		# here I use the method rotate_y because these method adds a side
		# effect where it automaticly clamps the rotation angle to -180 to 180
		# wich for the y rotation is ok
		rotate_y(mouse_x) 
		
		# here I dont use the method rotate_x because it would clamp the angles 
		# and that creates bugs and big amount of problems and I clamp it
		# my self to the max and min I want 
		head.rotation.x += mouse_y
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	if Input.is_action_just_pressed("ui_cancel"):
		if captured_mouse:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			captured_mouse = false
			$Head/Eyes/PlayerUI/PauseMenu.set_visible(true)
			stamina_bar.set_visible(false)
			cross_hair.set_visible(false)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			captured_mouse = true
			$Head/Eyes/PlayerUI/PauseMenu.set_visible(false)
			$Head/Eyes/PlayerUI/OptionsMenu.set_visible(false)
			stamina_bar.set_visible(true)
			cross_hair.set_visible(true)
			

func _process(delta):
	tutorial_camera.global_transform = main_camera.global_transform
	tutorial_camera.fov = main_camera.fov
	
	apply_cursor_shake(delta)
	
	for key in key_billboards:
		key_billboards[key].position = Vector3.ZERO
		key_billboards[key].set_visible(false)
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_interactions()
	$Head/Eyes/PlayerUI/InventoryInfo.text = "ITEMS: %s/%s" % [inventory_size, number_of_items]
		

func _physics_process(delta: float) -> void:
	
	if captured_mouse:
		var direction: Vector3 = Vector3.ZERO
		
		apply_crouch(delta)
		
		direction = apply_movement(direction)
		
		direction = direction.normalized()
		direction = apply_speed(direction, delta)
		
		if head_bob_on:
			apply_head_bob(direction, delta)
		
		direction = apply_gravity(direction, delta)
		
		final_direction = final_direction.lerp(direction, acceleration*delta)
		velocity = final_direction
		move_and_slide()
		

func apply_crouch(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		body_collision.shape.height = lerp(body_collision.shape.height, player_crouch_heigh, delta*go_to_chrouch_speed)
		body_mesh.mesh.height = lerp(body_mesh.mesh.height, player_crouch_heigh, delta*go_to_chrouch_speed)
		
		head.position.y = lerp(head.position.y, head_crouch_height, delta*go_to_chrouch_speed)
		original_head_y = lerp(original_head_y, head_crouch_height, delta*go_to_chrouch_speed)
		
		crouch_check.position.y = lerp(crouch_check.position.y, player_crouch_heigh/2, delta*go_to_chrouch_speed)
		
		is_crouching = true
	elif not crouch_check.is_colliding() or not is_crouching:
		body_collision.shape.height = lerp(body_collision.shape.height, player_stand_heigh, delta*go_to_chrouch_speed)
		body_mesh.mesh.height = lerp(body_mesh.mesh.height, player_stand_heigh, delta*go_to_chrouch_speed)
		
		head.position.y = lerp(head.position.y, head_stand_height, delta*go_to_chrouch_speed)
		original_head_y = lerp(original_head_y, head_stand_height, delta*go_to_chrouch_speed)
		
		crouch_check.position.y = lerp(crouch_check.position.y, player_stand_heigh/2, delta*go_to_chrouch_speed)
		
		is_crouching = false

func apply_movement(direction: Vector3) -> Vector3:
	
	if Input.is_action_pressed("forward"):
		direction += transform.basis.z
	if Input.is_action_pressed("backward"):
		direction += -transform.basis.z
	if Input.is_action_pressed("left"):
		direction += transform.basis.x
	if Input.is_action_pressed("right"):
		direction += -transform.basis.x
		
	
	return direction

func apply_gravity(direction: Vector3, delat: float = 1.0) -> Vector3:
	
	if not is_on_floor():
		vertical_speed -= gravity*delat
	else:
		jumped = false
		vertical_speed = 0.0
		direction.y = 0
		if Input.is_action_pressed("jump") and not jumped:
			vertical_speed = abs(jump_strength)
			jumped = true
			
	if is_on_ceiling():
		vertical_speed = -10
		
		
	vertical_speed = clamp(vertical_speed, -60, abs(jump_strength))
	direction.y += vertical_speed
	
	return direction

func apply_speed(direction: Vector3, delta: float = 1.0) -> Vector3:
	
	if stamina_bar.value < 1:
		reached_soft_limit = true
	
	if stamina_bar.value > stamina_soft_limit:
		reached_soft_limit = false
		
	if stamina_bar.value < stamina_soft_limit:
		stamina_bar_blink_index += delta
		stamina_bar.modulate = Color(
			cos(stamina_bar_blink_index*stamina_bar_blink_speed)/2+0.5,
			cos(stamina_bar_blink_index*stamina_bar_blink_speed)/2+0.5,
			cos(stamina_bar_blink_index*stamina_bar_blink_speed)/2+0.5,
			1
		)
	elif stamina_bar.value > 99.9:
		stamina_bar.modulate = stamina_bar.modulate.lerp(
			Color(0, 0, 0, 0), delta*stamina_bar_color_lerp_speed
		)
	else:
		stamina_bar.modulate = stamina_bar.modulate.lerp(
			Color(1, 1, 1, 1), delta*stamina_bar_color_lerp_speed
		)
	
	if direction.length():
		if Input.is_action_pressed("crouch") or is_crouching:
			current_speed = crouch_speed
			head_bob_speed = head_bob_crouch_speed
		elif Input.is_action_pressed("sprint") and stamina_bar.value > 1 and not reached_soft_limit:
			current_speed = runnig_speed
			head_bob_speed = head_bob_running_speed
			stamina_bar.value -= (stamina_delition+stamina_regeneration)*delta
		else:
			current_speed = walk_speed
			head_bob_speed = head_bob_walk_speed
	else:
		current_speed = 0.0
		head_bob_speed = 0.0
		
	stamina_bar.value += stamina_regeneration*delta
			
	return direction*current_speed
	
func apply_head_bob(direction: Vector3, delta: float) -> void:
	if direction.length() and is_on_floor():
		head_bob_timmer += delta
		head.position.y = sin(head_bob_timmer*head_bob_speed)/head_bob_ammount+original_head_y

func apply_interactions() -> void:

	var raycasted_object: Object = interaction_ray.get_collider()
	cross_hair.scale = Vector2(0.05, 0.05)
	if in_interaction:
		cross_hair.scale = Vector2(0.1, 0.1)
		
	if raycasted_object == null:
		if interactible == null:
			return
		
		if interactible.interacter == null:
			interactible = null
			in_interaction = false
		return
	
	if interaction_ray.get_collider().has_method("start_interaction"):
		if not in_interaction:
			if interactible == null:
				cross_hair.scale = Vector2(0.1, 0.1)
				interactible = raycasted_object
			in_interaction = interactible.start_interaction(self)
			if not in_interaction:
				interactible = null
				return
				
	if interactible == null:
		return
	if interactible.interacter == null:
		interactible = null
		in_interaction = false

func apply_cursor_shake(delta: float) -> void:
	if active_cursor_shake > 0:
		active_cursor_shake -= delta*10
		cursor_shake_timer += delta
		cross_hair.position.x = sin(cursor_shake_timer*50.0)*6
	else:
		cross_hair.position = original_cursor_pos


# pause menu button signals
func _on_resume_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	captured_mouse = true
	$Head/Eyes/PlayerUI/PauseMenu.set_visible(false)
	$Head/Eyes/PlayerUI/OptionsMenu.set_visible(false)
	stamina_bar.set_visible(true)
	cross_hair.set_visible(true)


func _on_exit_game_pressed():
	get_tree().quit()


func _on_options_pressed():
	$Head/Eyes/PlayerUI/PauseMenu.set_visible(false)
	$Head/Eyes/PlayerUI/OptionsMenu.set_visible(true)


func _on_close_pressed():
	$Head/Eyes/PlayerUI/PauseMenu.set_visible(true)
	$Head/Eyes/PlayerUI/OptionsMenu.set_visible(false)


func _on_head_bob_toggled(toggled_on):
	head_bob_on = toggled_on
