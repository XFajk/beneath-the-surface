extends Node3D

@export var small_item_count: int = 5
@export var medium_item_count: int = 5
@export var large_item_count: int = 2

var small_positions: Array
var medium_positions: Array
var large_positions: Array

var small_items: Array = [preload("res://assets/Phone.tscn"), preload("res://assets/Ring.tscn"), 
	preload("res://assets/Wallet.tscn"), preload("res://assets/Money_Pile.tscn")]

var medium_items: Array = [preload("res://assets/Laptop.tscn"), preload("res://assets/Console.tscn")]

var large_items: Array = [preload("res://assets/Vase.tscn"), preload("res://assets/Console.tscn")]

@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var music_timer: Timer = $AudioStreamPlayer/Music_Timer
@onready var time = $Player/Head/Eyes/PlayerUI/TimerContainer.time

func _ready():
	randomize()
	
	music.volume_db = -80
	
	var tree = get_tree()
	
	small_positions = tree.get_nodes_in_group("Small_Pos")
	medium_positions = tree.get_nodes_in_group("Medium_Pos")
	large_positions = tree.get_nodes_in_group("Large_Pos")
	
	for i in range(small_item_count):
		var item = small_items[randi() % small_items.size()].instantiate()
		var pos_node: Node3D = small_positions[randi() % small_positions.size()]
		small_positions.erase(pos_node)
		
		var pos: Vector3 = pos_node.global_position
		add_child(item)
		item.global_position = pos
		item.rotation.y = randf_range(-180, 180)
	
	for i in range(medium_item_count):
		var item = medium_items[randi() % medium_items.size()].instantiate()
		var pos_node: Node3D = medium_positions[randi() % medium_positions.size()]
		medium_positions.erase(pos_node)
		
		var pos: Vector3 = pos_node.global_position
		add_child(item)
		item.global_position = pos
		item.rotation.y = randf_range(-180, 180)
		
	for i in range(large_item_count):
		var item = large_items[randi() % large_items.size()].instantiate()
		var pos_node: Node3D = large_positions[randi() % large_positions.size()]
		large_positions.erase(pos_node)
		
		var pos: Vector3 = pos_node.global_position
		add_child(item)
		item.global_position = pos
		item.rotation.y = randf_range(-180, 180)
		
	if time < 93:
		music.play(93 - time)
	else:
		music_timer.start(time - 93)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if music.volume_db < -2:
		music.volume_db += 32 * delta

func _on_music_timer_timeout():
	music.play()
