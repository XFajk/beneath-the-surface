extends Control

@onready var aspect_drop_down: OptionButton = $Options/Options/ScrollContainer/Buttons/AspectDropDown

@onready var score: int = 0
var complete_score: float = 0.0

func _ready():
	$Options/Options/ScrollContainer/Buttons/SensitivitySlider.value = global.sensitivity
	
	aspect_drop_down.selected = global.aspect
	match aspect_drop_down.selected:
		0: # 4:3
			get_tree().root.content_scale_size = Vector2i(1152, 864)
			get_window().size = Vector2i(1152, 864)
		1: # 16:9
			get_tree().root.content_scale_size = Vector2i(1152, 648)
			get_window().size = Vector2i(1152, 648)
		2: # 16:10
			get_tree().root.content_scale_size = Vector2i(1152, 720)
			get_window().size = Vector2i(1152, 720)

func _process(delta):
	
	$Options/Options/ScrollContainer/Buttons/SensitivitySlider/Value.text = "%s" % global.sensitivity
	
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


func _on_sensitivity_slider_value_changed(value):
	global.sensitivity = value


func _on_aspect_drop_down_item_selected(index):
	global.aspect = index
	match index:
		0: # 4:3
			get_tree().root.content_scale_size = Vector2i(1152, 864)
			get_window().size = Vector2i(1152, 864)
		1: # 16:9
			get_tree().root.content_scale_size = Vector2i(1152, 648)
			get_window().size = Vector2i(1152, 648)
		2: # 16:10
			get_tree().root.content_scale_size = Vector2i(1152, 720)
			get_window().size = Vector2i(1152, 720)
