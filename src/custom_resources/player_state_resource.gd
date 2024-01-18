class_name PlayerStateRes
extends Resource

var money: int = 0
var score: int = 0

@export_range(3, 7, 1) var inventory_size: int = 5
@export_range(1, 4, 1) var lockpick_level: int = 1

var lost: bool = false
var won: bool = false
