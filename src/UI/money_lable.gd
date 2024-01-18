extends Label

var player_state: PlayerStateRes = preload("res://assets/resources/player_state.res")

func _process(_delta):
	text = "MONEY: %s" % player_state.money
