extends Node
class_name StateMachine

#Burası stateler için bir class'dır
#State = durum

#Unitlerin var olduğu durumu tutar
var state = null
#Unitlerin önceki durumunu tutar
var prev_state = null
#Unitlere özel eklenecek durumları tutar
var states = {}
#Kodun bağlı olduğu Unit'i çeker
@onready var parent = get_parent()

func _physics_process(_delta):
	#Unit'in duruma sahip olup olmadığını kontrol eder
	if state != null:
		#Unit'in sahip olduğu durumu gerçekleştirir
		_state_logic(_delta)
		#Geçiş boş olarak atanır
		var transition = _get_transition(_delta)
		#Eğer ki geçiş için bir durum sağlanırsa o durum a geçer
		if transition != null :
			set_state(transition)

#Unit'in sahip olduğu durumu gerçekleştirir
func _state_logic(_delta):
	pass

#Belirli durumlar karşısında state değişimi sağlar
func _get_transition(_delta):
	pass

#Durum değiştirir
func set_state(_new_state):
	prev_state = state
	state = _new_state
	
	#Durum'dan çıkılırken uygulanacak komutları uygular
	if prev_state != null :
		exit_state(prev_state, _new_state)
	#Duruma girerken uygulanacak komutları uygular
	if _new_state != null:
		_enter_state(_new_state, prev_state)

#Durum'dan çıkılırken uygulanacak komutları uygular
func exit_state(_prev_state, _new_state):
	pass
#Duruma girerken uygulanacak komutları uygular
func _enter_state(_new_state, _prev_state):
	pass

#Durumlara yeni durum ekler
func add_state(_state_name) :
	states[_state_name] = states.size()
