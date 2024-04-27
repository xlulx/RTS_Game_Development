extends StateMachine

#Komutlar
enum Commands {
	NONE,
	MOVE,
	ATTACK_MOVE,
	HOLD
}
var command = Commands.NONE

#Üst komutlar
enum CommandMods {
	NONE,
	ATTACK_MOVE
}
var command_mod

#nodes
var Camera
var Gui

func _ready():
	#Camera node'unu Camera değişkenine atar
	Camera = get_node("/root/Game/Camera")
	Gui = get_node("/root/Game/Gui/In-game_Menu")
	
	#Durumların eklenmesi
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	call_deferred("set_state", states.idle)

func _input(_event):
	#Unit ölü veya seçilmemiş değilse girdi alır
	if parent.selected and state != states.dying:
		#attack_move aksiyonu kontrol edilir
		if Input.is_action_just_pressed("attack_move"):
			#Üst komut "CommandMods.ATTACK_MOVE" ile değiştirilir
			command_mod = CommandMods.ATTACK_MOVE
		#hold aksiyonu kontrol edilir
		if Input.is_action_just_pressed("hold"):
			#Komut "Commands.HOLD" ile değiştirilir
			command = Commands.HOLD
			set_state(states.idle)
		#right_click aksiyonu ve is_mouse_on_gui kontrol edilir
		if Input.is_action_just_released("right_click") and !Camera.is_mouse_on_gui:
			#Komut boşa alınır
			command = Commands.NONE
			#Hareket hedefi dünya üzerindeki mouse pozisyonua ayarlanır
			parent.movement_target = formation()
			set_state(states.moving)
			#Üst komut kontrol edilir
			match command_mod:
				#Üst komut boş ise
				CommandMods.NONE:
					#Komut "MOVE" ile değiştirilir
					command = Commands.MOVE
				#Üst komut "ATTACK_MOVE" ise
				CommandMods.ATTACK_MOVE:
					#Komut "ATTACK_MOVE" ile değiştirilir
					command = Commands.ATTACK_MOVE
					command_mod = null

#Unit'in sahip olduğu durumu gerçekleştirir
func _state_logic(_delta):
	
	#Durum kontrol edilir
	match state :
		#Durum "idle" ise
		states.idle :
			pass
		#Durum "moving" ise
		states.moving :
			#Unit'in kaplaması hareket yönüne baktırılır
			skin_rotate_to(parent.movement_target)
			#Unit hareket hedefine doğru harekete başlatılır
			parent.move_to_target(_delta, parent.movement_target)
		#Durum "engaging" ise
		states.engaging :
			#Unit'in saldırı hedefi olup olmadığı kontrol edilir
			if parent.attack_target.get_ref():
				#Unit'in kaplaması saldırı yönüne baktırılır
				skin_rotate_to(parent.attack_target.get_ref().position)
				#Unit saldırı hedefine doğru harekete başlatılır
				parent.move_to_target(_delta, parent.attack_target.get_ref().position)
			else :
				set_state(states.idle)
		#Durum "attacking" ise
		states.attacking :
			#Unit'in kaplaması saldırı yönüne baktırılır
			if parent.attack_target.get_ref() != null :
				skin_rotate_to(parent.attack_target.get_ref().position)
		#Durum "dying" ise
		states.dying :
			pass
			
#Duruma girerken uygulanacak komutları uygular
func _enter_state(_new_state, _old_state):
	#Durum kontrol edilir
	match state :
		#Durum "idle" ise
		states.idle :
			pass
		#Durum "moving" ise
		states.moving :
			pass
		#Durum "engaging" ise
		states.engaging :
			pass
		#Durum "attacking" ise
		states.attacking :
			pass
		#Durum "dying" ise
		states.dying :
			Gui.remove_unit(parent.unit_Mark)
			#Unit'i siler
			parent.queue_free()

#Durum'dan çıkılırken uygulanacak komutları uygular
func _exit_state(old_state, new_state):
	#Önceki durum kontrol edilir
	match old_state:
		#Önceki durum "attacking" ise
		states.attacking:
			#Yeni durum "idle" ise
			if new_state == states.idle:
				#saldırı hedefi yoktur
				parent.attack_target = null
		#Önceki durum "moving" ise
		states.moving:
			#Yeni durum "moving" değil ise ve komut "ATTACK_MOVE" değil ise
			if new_state != states.moving and command != Commands.ATTACK_MOVE:
				#Hareket hedefi Unit'in konumudur
				parent.movement_target = parent.position

#Belirli durumlar karşısında state değişimi sağlar
func _get_transition(_delta):
	#Durum kontrol edilir
	match state :
		#Durum "idle" ise
		states.idle :
			#Komut kontrol edilir
			match command:
				#Komut "HOLD" ise
				Commands.HOLD:
					parent.movement_target = parent.position
					#Unit'in menzilinde hedef var ise
					if parent.closest_target_within_range() != null:
						#Saldırı hedefi en yakın hedef olarak ayarlanır
						parent.attack_target = weakref(parent.closest_target_within_range())
						set_state(states.attacking)
				#Komut "ATTACK_MOVE" ise
				Commands.ATTACK_MOVE:
					set_state(states.moving)
				#Komut boş ise
				Commands.NONE:
					#En yakın hedef boş değil ise
					if parent.closest_target() != null:
						#Saldırı hedefi en yakın hedef olarak ayarlanır
						parent.attack_target = weakref(parent.closest_target())
						set_state(states.engaging)
		#Durum "moving" ise
		states.moving :
			#Komut "ATTACK_MOVE" ise
			if (command == Commands.ATTACK_MOVE):
				#En yakın hedef boş değil ise
				if parent.closest_target() != null:
					#Saldırı hedefi en yakın hedef olarak ayarlanır
					parent.attack_target = weakref(parent.closest_target())
					set_state(states.engaging)
			#Eğer ki Unit "target_max" limitine vardı ise
			if parent.position.distance_to(parent.movement_target) < parent.target_max:
				#Hareket hedefi Unit'in konumudur
				parent.movement_target = parent.position
				set_state(states.idle)
		#Durum "engaging" ise
		states.engaging :
			#Unit'in menzilinde hedef var ise
			if parent.closest_target_within_range() != null :
				#Saldırı hedefi en yakın hedef olarak ayarlanır
				parent.attack_target = weakref(parent.closest_target())
				#Saldırı hızı sayacı başlar
				parent.attack_timer.start()
				set_state(states.attacking)
		#Durum "attacking" ise
		states.attacking :
			#Saldırı hedefi yok ise
			if !parent.attack_target.get_ref():
				set_state(states.idle)
				#Saldırı hedefi boşa alınır
				parent.attack_target = null
				#Saldırı hızı sayacı durur
				parent.attack_timer.stop()
		#Durum "dying" ise
		states.dying :
			pass

#Saldırı hızı sayacı
func _on_attack_timer_timeout():
	#Durum kontrol edilir
	match state :
		#Durum "attacking" ise
		states.attacking :
			#Saldırı hedefi var ise
			if parent.attack_target.get_ref():
				#Saldırı hedefi hasar alır ve alabiliyor mu dşye kontrol edilir
				if parent.attack_target.get_ref().take_damage(parent.damage):
					#Hedefin menzil içinde olup olmadığı kontrol edilir
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

#Unit'in kaplaması hareket yönüne baktırılır
func skin_rotate_to(look_target):
	parent.skin.rotation = parent.position.angle_to_point(look_target)

var mouse_Position = Vector2.ZERO
var formation_captains_position = Vector2.ZERO
var new_tar_vector = Vector2.ZERO
#birimler arasındaki uzaklık
var distance_Between_Units = 60

#Birimlerin verilen formasyonu almasını sağlayan fonksyon
func formation(Shape = "square"):
	mouse_Position = Camera.global_mouse_position
	#Dikdörtgen fonksiyonu
	if Shape == "square" :
		#eğer ilk birim ise değişiklik olmaz
		if Camera.weakref_selected[0][1] == parent.unit_Mark :
			return mouse_Position
		#ilk birimin formasyon kaptanı seçilmesi
		formation_captains_position = Camera.weakref_selected[0][0].get_ref().position
		#birazcık komplike gözüken kare formasyon formülü
		new_tar_vector = ((formation_captains_position.distance_to(mouse_Position)*formation_captains_position.direction_to(mouse_Position))
					+ (parent.position.distance_to(formation_captains_position)*parent.position.direction_to(formation_captains_position))
					+ (Vector2((formation_captains_position.direction_to(mouse_Position).y * -1), formation_captains_position.direction_to(mouse_Position).x)) 
					* distance_Between_Units * (parent.unit_Mark % 4)
					- formation_captains_position.direction_to(mouse_Position) 
					* distance_Between_Units * (int(parent.unit_Mark / 4)))
		return (parent.position + new_tar_vector)
