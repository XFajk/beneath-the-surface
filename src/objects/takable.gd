extends Node3D

@export var id: String = "----"
@export var tutorial_lable_pos: Vector3 = Vector3(0, 0.2, 0)
@export var enable_tutorial_label: bool = false

var interacter: Object = null
	
func start_interaction(new_interacter: Object) -> bool:
	if enable_tutorial_label:
		new_interacter.key_billboards.KEY_E.global_position = global_position+tutorial_lable_pos
		new_interacter.key_billboards.KEY_E.set_visible(true)

	if Input.is_action_just_pressed("take"):
		if new_interacter.inventory_container.get_children().size() <= new_interacter.inventory_size:
			var label: Label = Label.new()
			label.label_settings = new_interacter.inventory_label_setting
			label.text = id
			new_interacter.inventory_container.add_child(label)
			queue_free()
		else:
			new_interacter.active_cursor_shake = 5
	return false
	
func interact() -> void:
	pass

func end_interaction() -> void:
	interacter = null
