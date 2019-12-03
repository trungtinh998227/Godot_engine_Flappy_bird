extends TextureButton


func _ready():
	connect("pressed",self, "_on_pressed")
	grab_focus()
	pass

func _on_pressed():
	var bird = utils.get_main_node().get_node("bird")
	if bird:
		bird.set_state(bird.STATE_FLAPPING)
	hide()
	pass