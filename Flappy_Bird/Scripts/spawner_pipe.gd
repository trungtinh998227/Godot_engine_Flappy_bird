extends Node2D

const PIPE_WIDTH = 26
const OFFSET_X = 65
const OFFSET_Y = 55
const GROUND_HEIGHT = 56
const AMOUNT_TO_FILL_VIEW = 3
const scn_pipe = preload("res://Scene/pipe.tscn")

func _ready():
	var bird = utils.get_main_node().get_node("bird")
	if bird:
		bird.connect("state_changed", self, "_on_bird_state_changed",[],CONNECT_ONESHOT)
	pass 

func _on_bird_state_changed(bird):
	if bird.get_state() == bird.STATE_FLAPPING:
		start()
	pass

func start():
	go_init_pos()
	for i in range(AMOUNT_TO_FILL_VIEW):
		spawn_pipe()
		go_next_pos()
	pass

func go_init_pos():
	randomize()
	var init_pos = Vector2()
	init_pos.x = get_viewport_rect().size.x + PIPE_WIDTH/2
	init_pos.y = rand_range(0 + OFFSET_Y, get_viewport_rect().size.y - GROUND_HEIGHT - OFFSET_Y)
	
	var camera = utils.get_main_node().get_node("camera")
	if camera:
		init_pos.x += camera.get_total_pos().x
	
	set_position(init_pos)
	pass


func spawn_pipe():
	var new_pipe = scn_pipe.instance()
	new_pipe.set_position(get_position())
	new_pipe.connect("destroyed", self,"spawn_pipe")
	new_pipe.connect("destroyed", self,"go_next_pos")
	get_node("container").add_child(new_pipe)
	pass

func go_next_pos():
	randomize()
	var next_pos = get_position()
	next_pos.x += PIPE_WIDTH/2 + OFFSET_X + PIPE_WIDTH/2
	next_pos.y = rand_range(0 + OFFSET_Y, get_viewport_rect().size.y - GROUND_HEIGHT - OFFSET_Y)
	set_position(next_pos)
	pass