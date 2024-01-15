extends Control

@onready var score: int = 0
var complete_score: float = 0.0

func _process(delta):
	
	if global.won:
		complete_score = lerp(complete_score, global.score as float, delta*5)
		score = round(complete_score)
		$SuccessMenu/Score.text = "SCORE: %s" % score
		$Options.set_visible(false)
		$MainMenu.set_visible(false)
		$SuccessMenu.set_visible(true)
		$FailMenu.set_visible(false)
	elif global.lost:
		$Options.set_visible(false)
		$MainMenu.set_visible(false)
		$SuccessMenu.set_visible(false)
		$FailMenu.set_visible(true)
	else:
		complete_score = 0
		score = 0
		global.score = 0

func _on_start_pressed():
	get_tree().change_scene_to_file("res://assets/levels/house_0_level.tscn")


func _on_options_pressed():
	$Options.set_visible(true)
	$MainMenu.set_visible(false)


func _on_exit_game_pressed():
	get_tree().quit()


func _on_close_pressed():
	$SuccessMenu.set_visible(false)
	$FailMenu.set_visible(false)
	$Options.set_visible(false)
	$MainMenu.set_visible(true)


func _on_head_bob_toggled(toggled_on):
	global.head_bob_on = toggled_on


func _on_sucess_close_pressed():
	$SuccessMenu.set_visible(false)
	$Options.set_visible(false)
	$MainMenu.set_visible(true)
	$FailMenu.set_visible(false)
	global.won = false


func _on_fail_close_pressed():
	$SuccessMenu.set_visible(false)
	$Options.set_visible(false)
	$MainMenu.set_visible(true)
	$FailMenu.set_visible(false)
	global.lost = false
