extends Node3D

@export var small_item_count: int = 5
@export var medium_item_count: int = 5
@export var large_item_count: int = 5

var small_positions: Array
var medium_positions: Array
var large_positions: Array

var small_items: Array = [preload("res://assets/Phone.tscn"), preload("res://assets/Console.tscn")]

func _ready():
	randomize()
	
	var tree = get_tree()
	
	small_positions = tree.get_nodes_in_group("Small_Pos")
	medium_positions = tree.get_nodes_in_group("Medium_Pos")
	large_positions = tree.get_nodes_in_group("Large_Pos")
	
	for i in range(small_item_count):
		var item = small_items[randi() % small_items.size()].instantiate()
		var pos_node: Node3D = small_positions[randi() % small_positions.size()]
		small_positions.erase(pos_node)
		
		var pos: Vector3 = pos_node.global_position
		print(pos_node.global_position)
		print(pos)
		add_child(item)
		item.global_position = pos
		print(item.global_position)
		print("------")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
