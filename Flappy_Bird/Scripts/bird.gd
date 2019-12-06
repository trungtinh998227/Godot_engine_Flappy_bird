# script: bird
extends RigidBody2D

onready var state = FlyingState.new(self)

const STATE_FLYING = 0
const STATE_FLAPPING = 1
const STATE_HIT = 2
const STATE_GROUNDED = 3
var speed = 50

signal state_changed

func _ready():
	set_process_input(true)
	
	connect("body_entered", self, "_on_body_entered")
	pass

func _on_body_entered(other_body):
	if state.has_method("on_body_enter"):
		state.on_body_enter(other_body)
	pass

func _integrate_forces(delta):
    state.update(delta)
    pass

func _input(event):
    state.input(event)
    pass

func set_state(new_state):
	state.exit()
	
	match new_state:
		STATE_FLYING: state = FlyingState.new(self)
		STATE_FLAPPING: state = FlappingState.new(self)
		STATE_HIT: state = HitState.new(self)
		STATE_GROUNDED: state = GroundedState.new(self)
	emit_signal("state_changed", self)
	pass

func get_state():
	if state is FlyingState:
		return STATE_FLYING
	elif state is FlappingState:
		return STATE_FLAPPING
	elif state is HitState:
		return STATE_HIT
	elif state is GroundedState:
		return STATE_GROUNDED
	pass

class FlappingState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.set_linear_velocity(Vector2(bird.speed,bird.get_linear_velocity().y))
		flap()
		pass
	
	func input(event):
		if event.is_action_pressed("flap"):
        	flap()
		pass
	
	func on_body_enter(other_body):
		if other_body.is_in_group(game.GROUP_PIPE):
			bird.set_state(bird.STATE_HIT)
		elif other_body.is_in_group(game.GROUP_GROUND):
			bird.set_state(bird.STATE_GROUNDED)
		pass
	
	func flap():
		bird.set_linear_velocity(Vector2(bird.get_linear_velocity().x, -150))
		bird.set_angular_velocity(-3)
		bird.get_node("anim").play("flap")
		pass
	
	func update(delta):
		if rad2deg(bird.get_rotation()) < - 30:
			bird.set_rotation(deg2rad(-30))
			bird.set_angular_velocity(0)
		if bird.get_linear_velocity().y > 0:
			bird.set_angular_velocity(1.5)
		pass
	
	func exit():
		pass
#----------------------------------------------------------------------------	
class FlyingState:
	var bird
	var prev_gravity_scale
	
	func _init(bird):
		self.bird = bird
		bird.get_node("anim").play("flying")
		bird.set_linear_velocity(Vector2(bird.speed,bird.get_linear_velocity().y))
		prev_gravity_scale = bird.get_gravity_scale()
		bird.set_gravity_scale(0)
		pass
	
	func input(event):
		pass
	
	func update(delta):
		pass
	
	func exit():
		bird.set_gravity_scale(prev_gravity_scale)
		bird.get_node("anim").stop()
		bird.get_node("anim_sprite").set_position(Vector2(0, 0))
		pass
#-----------------------------------------------------------------------------
class HitState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.set_linear_velocity(Vector2(0,0))
		bird.set_angular_velocity(2)
		
		var other_body = bird.get_colliding_bodies()[0]
		bird.add_collision_exception_with(other_body)
		pass
	
	func input(event):
		pass
	
	func update(delta):
		pass
	func on_body_enter(other_body):
		if other_body.is_in_group(game.GROUP_GROUND):
			bird.set_state(bird.STATE_GROUNDED)
		pass 
	func exit():
		pass
#------------------------------------------------------------------------------
class GroundedState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.set_linear_velocity(Vector2(0,0))
		bird.set_angular_velocity(0)
		pass
	
	func input(event):
		pass
	
	func update(delta):
		pass
	
	func exit():
		pass