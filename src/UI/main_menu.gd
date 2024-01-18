extends Control

@export var settings: SettingRes
var player_state: PlayerStateRes = preload("res://assets/resources/player_state.res")

@onready var score: int = 0
var complete_score: float = 0.0

func _ready():
	$Options/Options/ScrollContainer/Buttons/SensitivitySlider.value = settings.sensitivity

func _process(delta):
	
	$Options/Options/ScrollContainer/Buttons/SensitivitySlider/Value.text = "%s" % settings.sensitivity
	
	if player_state.won:
		complete_score = lerp(complete_score, player_state.score as float, delta*5)
		score = round(complete_score)
		$SuccessMenu/Score.text = "SCORE: %s" % score
		$Options.set_visible(false)
		$MainMenu.set_visible(false)
		$SuccessMenu.set_visible(true)
		$FailMenu.set_visible(false)
	elif player_state.lost:
		$Options.set_visible(false)
		$MainMenu.set_visible(false)
		$SuccessMenu.set_visible(false)
		$FailMenu.set_visible(true)
	else:
		complete_score = 0
		score = 0
		player_state.score = 0

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
	settings.head_bob_on = toggled_on


func _on_sucess_close_pressed():
	$SuccessMenu.set_visible(false)
	$Options.set_visible(false)
	$MainMenu.set_visible(true)
	$FailMenu.set_visible(false)
	player_state.won = false


func _on_fail_close_pressed():
	$SuccessMenu.set_visible(false)
	$Options.set_visible(false)
	$MainMenu.set_visible(true)
	$FailMenu.set_visible(false)
	player_state.lost = false


func _on_sensitivity_slider_value_changed(value):
	settings.sensitivity = value

