extends Control

var player_state: PlayerStateRes = preload("res://assets/resources/player_state.res")

var mseconds: int = 0
var seconds: int = 0
var minutes: int = 0
@export var time: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time -= delta
	@warning_ignore("narrowing_conversion")
	mseconds = fmod(time, 1) * 100
	@warning_ignore("narrowing_conversion")
	seconds = fmod(time, 60)
	@warning_ignore("narrowing_conversion")
	minutes = fmod(time, 3600) / 60
	$Timer1.text = "%03d" %mseconds
	$Timer2.text = "%02d." %seconds
	$Timer3.text = "%02d." %minutes
	
	if time < 0.001:
		player_state.lost = true
