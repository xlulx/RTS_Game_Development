extends CharacterBody2D
class_name unit

#Sahiplik değişkeni
#unit'in ait olduğu sahibi belirtir. sahip 0 = oyuncu
@export var unit_Owner = 0
#unit'in işaretinin tutulduğu değişken
var unit_Mark

#Hareket değişkenleri
var selected = false
var movement_target = Vector2.ZERO
var speed = 120
var target_max = 10
var move_threshold = 2
var new_velocity = Vector2.ZERO

#Saldırı değişkenleri
var attack_target = null
var attack_range = 45
var damage = 3
var possible_targets = []

#Childs
@onready var state_machine = $UnitSM
@onready var skin = $Skin
@onready var attack_timer = $attackTimer
@onready var nav = $NavigationAgent2D
@onready var health_Bar = $HealthBar
var enemy_skin = load("res://Assets/Enemy.png")

#Nodes
var Camera

#başlama fonksiyonu
func _ready():
	Camera = get_node("/root/Game/Camera")
	
	health_Bar.value = 20
	health_Bar.max_value = health_Bar.value
	
	movement_target = position
	if unit_Owner == 1 :
		skin.texture = enemy_skin

#Hareket etme kodu
func move_to_target(_delta, tar):
	nav.target_position = tar
	velocity = Vector2.ZERO
	new_velocity = position.direction_to(nav.get_next_path_position()) * speed
	velocity = velocity.move_toward(new_velocity, 120)
	move_and_slide()

#Unit seçildiğinde başlayacak fonksiyon
func select():
	selected = true
	$Selected.visible = true

#unit terk ediğildiğinde çalışacak fonksiyon
func deselect(index):
	if selected:
		if index == unit_Mark :
			unit_Mark = null
			selected = false
			$Selected.visible = false
			state_machine.command_mod = null
			Camera.red_click = false
		if index == -1 :
			unit_Mark = null
			selected = false
			$Selected.visible = false
			state_machine.command_mod = null
			Camera.red_click = false
		if unit_Mark != null :
			if index < unit_Mark :
				unit_Mark -= 1

#Görüş alanına girip çıkanları listeye ekleme çıkarma
func _on_vision_range_body_entered(body):
	if body.is_in_group("unit"):
		if body.unit_Owner != unit_Owner :
			possible_targets.append(body)
func _on_vision_range_body_exited(body):
	if possible_targets.has(body) :
		possible_targets.erase(body)

#uzaklık belirleme
func compare_distance(target_a, target_b) :
	if position.distance_to(target_a.position) < position.distance_to(target_b.position) :
		return true
	else :
		return false

#en yakın düşmanı belirleme
func closest_target() -> unit :
	if possible_targets.size() > 0 :
		possible_targets.sort_custom(compare_distance)
		return possible_targets[0]
	else :
		return null

func closest_target_within_range() -> unit :
	if closest_target():
		if closest_target().position.distance_to(position) < attack_range:
			return closest_target()
		else:
			return null
	else:
		return null

func target_within_range() -> bool:
	if attack_target.get_ref().position.distance_to(position) < attack_range:
		return true
	else :
		return false

#unit hasar aldığında çalışacak fonksiyon
func take_damage(amount) -> bool :
	health_Bar.value -= amount
	if health_Bar.value  <= 0 :
		state_machine.died()
		return false
	else :
		return true

func get_state():
	return state_machine.state

#unit e saldırı çağrısı yapılması için fonksiyon
func attack():
	if selected:
		state_machine.command_mod = state_machine.CommandMods.ATTACK_MOVE
		Camera.red_click = true

#unit e durma çağrısı yapılması için fonksiyon
func hold():
	if selected:
		state_machine.command = state_machine.Commands.HOLD
		state_machine.set_state(state_machine.states.idle)
