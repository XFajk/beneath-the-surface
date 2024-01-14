extends Control


func _on_start_pressed():
	get_tree().change_scene_to_file("res://assets/levels/house_0_level.tscn")


func _on_options_pressed():
	$Options.set_visible(true)
	$MainMenu.set_visible(false)


func _on_exit_game_pressed():
	get_tree().quit()


func _on_close_pressed():
	$Options.set_visible(false)
	$MainMenu.set_visible(true)


func _on_head_bob_toggled(toggled_on):
	global.head_bob_on = toggled_on
