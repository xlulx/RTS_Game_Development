extends StateMachine

enum Commands {
	NONE,
	MOVE,
	ATTACK_MOVE,
	HOLD
}
var command = Commands.NONE

enum CommandMods {
	NONE,
	ATTACK_MOVE
}
var command_mod

#başlama fonksiyonu
func _ready():
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	call_deferred("set_state", states.idle)

#Girdi alma
func _input(_event):
	if parent.selected and state != states.dying:
		if Input.is_action_just_pressed("attack_move"):
			command_mod = CommandMods.ATTACK_MOVE
		if Input.is_action_just_pressed("hold"):
			command = Commands.HOLD
			set_state(states.idle)
		if Input.is_action_just_released("right_click"):
			command = Commands.NONE
			parent.movement_target = get_node("/root/Game/Camera").global_mouse_position
			set_state(states.moving)
			match command_mod:
				CommandMods.NONE:
					command = Commands.MOVE
				CommandMods.ATTACK_MOVE:
					command = Commands.ATTACK_MOVE
					command_mod = null

#Sürekli Çalışan Girdiler
func _state_logic(_delta):
	match state :
		states.idle :
			pass
		states.moving :
			parent.move_to_target(_delta, parent.movement_target)
			parent.skin.rotation = parent.position.angle_to_point(parent.movement_target)
		states.engaging :
			if parent.attack_target.get_ref():
				parent.move_to_target(_delta, parent.attack_target.get_ref().position)
				parent.skin.rotation = parent.position.angle_to_point(parent.attack_target.get_ref().position)
			else :
				set_state(states.idle)
		states.attacking :
			pass
		states.dying :
			pass
			
#State Giriş
func _enter_state(_new_state, _old_state):
	match state :
		states.idle :
			pass
		states.moving :
			pass
		states.engaging :
			pass
		states.attacking :
			pass
		states.dying :
			parent.queue_free()

func _exit_state(old_state, new_state):
	match old_state:
		states.attacking:
			if new_state == states.idle:
				parent.attack_target = null
		states.moving:
			if new_state != states.moving and command != Commands.ATTACK_MOVE:
				parent.movement_target = parent.position

#Belirli Durumlar karşısında state Değişimi
func _get_transition(_delta):
	match state :
		states.idle :
			match command:
				Commands.HOLD:
					if parent.closest_target_within_range() != null:
						parent.attack_target = weakref(parent.closest_target_within_range())
						set_state(states.attacking)
				Commands.ATTACK_MOVE:
					set_state(states.moving)
				Commands.NONE:
					if parent.closest_target() != null:
						parent.attack_target = weakref(parent.closest_target())
						set_state(states.engaging)
		states.moving :
			if (command == Commands.ATTACK_MOVE):
				if parent.closest_target() != null:
					parent.attack_target = weakref(parent.closest_target())
					set_state(states.engaging)
			if parent.position.distance_to(parent.movement_target) < parent.target_max:
				parent.movement_target = parent.position
				set_state(states.idle)
		states.engaging :
			if parent.closest_target_within_range() != null :
				parent.attack_target = weakref(parent.closest_target())
				parent.attack_timer.start()
				set_state(states.attacking)
		states.attacking :
			if !parent.attack_target.get_ref():
				set_state(states.idle)
				parent.attack_target = null
				parent.attack_timer.stop()
		states.dying :
			pass


func _on_attack_timer_timeout():
	match state :
		states.attacking :
			if parent.attack_target.get_ref():
				if parent.attack_target.get_ref().take_damage(parent.damage):
					if parent.target_within_range():
						pass
					else:
						set_state(states.engaging)
				else:
					set_state(states.idle)
			else:
				set_state(states.idle)
		states.dying :
			pass

#Ölüm
func died():
	set_state(states.dying)


