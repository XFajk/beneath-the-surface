extends GPUParticles3D

func _ready():
	explosiveness = 1
	one_shot = true

func _on_finished():
	queue_free()
