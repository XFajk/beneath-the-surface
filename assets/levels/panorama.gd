extends Camera3D

@export var rotation_speed: float = 5.0

func _physics_process(delta):
	rotate_y(deg_to_rad(rotation_speed)*delta)
