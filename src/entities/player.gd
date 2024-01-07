extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var body_collision: CollisionShape3D = $Body
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var foot: CollisionShape3D = $Foot
@onready var crouch_check: RayCast3D = $CrouchCheckRay

@export var captured_mouse: bool = true
@export var mouse_sensitivity: float = 0.05

@export var walk_speed: float = 2
@export var runnig_speed: float = 5
@export var crouch_speed: float = 1
@export var acceleration: float = 1
var current_speed: float = 0.0
var final_direction: Vector3 = Vector3.ZERO

@export var gravity: float = 30.0
@export var vertical_speed = 0.0

@export var jump_strength: float = 8.5
var jumped: bool = false

@export var go_to_chrouch_speed: float = 4.0

@export var player_stand_heigh: float = 1.9
@export var foot_stand_height: float = 0.9
@export var head_stand_height: float = 0.5

@export var player_crouch_heigh: float = 0.3
@export var foot_crouch_height: float = 0.1
@export var head_crouch_height: float = -0.5


var head_bob_timmer: float = 0.0
@export var head_bob_walk_speed: float = 10.0
@export var head_bob_running_speed: float = 15.0
@export var head_bob_crouch_speed: float = 7.0
var head_bob_speed: float = 0.0
@export var head_bob_ammount: float = 10.0 # 1=big bob, 1000 small bob
var original_head_y: float = head_stand_height

var x: float = 0.0


func _ready() -> void:
	# capture the mouse
	if captured_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	# setting the player size
	body_collision.shape.height = player_stand_heigh
	foot.shape.height = foot_stand_height
	body_mesh.mesh.height = player_stand_heigh
	head.position.y = head_stand_height
	original_head_y = head_stand_height
	crouch_check.position.y = player_stand_heigh/2


func _input(event) -> void:
	if event is InputEventMouseMotion and captured_mouse:
		rotate_y(deg_to_rad(-event.relative.x*mouse_sensitivity))
		head.rotate_x(deg_to_rad(event.relative.y*mouse_sensitivity))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -80, 80)
		
	if Input.is_action_just_pressed("ui_cancel"):
		if captured_mouse:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			captured_mouse = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			captured_mouse = true


func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	
	apply_crouch(delta)
	
	direction = apply_movement(direction)
	
	direction = direction.normalized()
	direction = apply_speed(direction, delta)
	
	apply_head_bob(direction, delta)
	
	direction = apply_gravity(direction, delta)
	
	final_direction = final_direction.lerp(direction, acceleration*delta)
	velocity = final_direction
	move_and_slide()


func apply_crouch(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		body_collision.shape.height = lerp(body_collision.shape.height, player_crouch_heigh, delta*go_to_chrouch_speed)
		foot.shape.height = lerp(foot.shape.height, foot_crouch_height, delta*go_to_chrouch_speed)
		body_mesh.mesh.height = lerp(body_mesh.mesh.height, player_crouch_heigh, delta*go_to_chrouch_speed)
		head.position.y = lerp(head.position.y, head_crouch_height, delta*go_to_chrouch_speed)
		original_head_y = lerp(original_head_y, head_crouch_height, delta*go_to_chrouch_speed)
		crouch_check.position.y = lerp(crouch_check.position.y, player_crouch_heigh/2, delta*go_to_chrouch_speed)
	elif not crouch_check.is_colliding():
		body_collision.shape.height = lerp(body_collision.shape.height, player_stand_heigh, delta*go_to_chrouch_speed)
		foot.shape.height = lerp(foot.shape.height, foot_stand_height, delta*go_to_chrouch_speed)
		body_mesh.mesh.height = lerp(body_mesh.mesh.height, player_stand_heigh, delta*go_to_chrouch_speed)
		head.position.y = lerp(head.position.y, head_stand_height, delta*go_to_chrouch_speed)
		original_head_y = lerp(original_head_y, head_stand_height, delta*go_to_chrouch_speed)
		crouch_check.position.y = lerp(crouch_check.position.y, player_stand_heigh/2, delta*go_to_chrouch_speed)

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
		
		
	vertical_speed = clamp(vertical_speed, -60, abs(jump_strength))
	direction.y += vertical_speed
	
	return direction


func apply_speed(direction: Vector3, delta: float = 1.0) -> Vector3:
	
	if direction.length():
		current_speed = walk_speed
		head_bob_speed = head_bob_walk_speed
		if Input.is_action_pressed("sprint"):
			current_speed = runnig_speed
			head_bob_speed = head_bob_running_speed
		elif Input.is_action_pressed("crouch"):
			current_speed = crouch_speed
			head_bob_speed = head_bob_crouch_speed
	else:
		current_speed = 0.0
		head_bob_speed = 0.0
			
	return direction*current_speed
	
func apply_head_bob(direction: Vector3, delta: float) -> void:
	if direction.length() and is_on_floor():
		head_bob_timmer += delta
		head.position.y = sin(head_bob_timmer*head_bob_speed)/head_bob_ammount+original_head_y



