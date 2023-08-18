extends Node
class_name StateMachine

var state = null
var prev_state = null
var states = {}

@onready var parent = get_parent()

func _physics_process(_delta):
	if state != null:
		_state_logic(_delta)
		var transition = _get_transition(_delta)
		if transition != null :
			set_state(transition)

func _state_logic(_delta):
	pass

func _get_transition(_delta):
	pass
	
func set_state(_new_state):
	prev_state = state
	state = _new_state
	
	if prev_state != null :
		exit_state(prev_state, _new_state)
	if _new_state != null:
		_enter_state(_new_state, prev_state)
		
func exit_state(_prev_state, _new_state):
	pass

func _enter_state(_new_state, _prev_state):
	pass

func add_state(_state_name) :
	states[_state_name] = states.size()
