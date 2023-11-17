extends Control

#Mouse'un gui içinde olup olmadığını kontrol eden değişken
var is_mouse_on_gui = false
#Camera node'unu tutan değişken
var Camera
#ItemList node'unu tutan değişken
@onready var list = $Units_Panel/ItemList

func _ready():
	#Camera node'unu Camera değişkenine atar
	Camera = get_node("/root/Game/Camera")
	
func _process(delta):
	if list.get_item_count() != 0 :
		visible = true
	else :
		Camera.selected = []
		visible = false
	
#attack butonu
func _on_attack_button_pressed():
	#Unit'lerde bulunan attack fonksiyonunu çalıştırır
	get_tree().call_group("unit", "attack")

#hold butonu
func _on_hold_button_pressed():
	#Unit'lerde bulunan hold fonksiyonunu çalıştırır
	get_tree().call_group("unit", "hold")

#area2d node'u için mouse girdi fonksiyonu
func _on_area_2d_mouse_entered():
	#Mouse'un alana girdiğini belirtir
	is_mouse_on_gui = true

#area2d node'u için mouse çıktı fonksiyonu
func _on_area_2d_mouse_exited():
	#Mouse'un alandan çıktığını belirtir
	is_mouse_on_gui = false

#ItemList üzerinde bir iteme tıklandığında indexi veren fonksiyon
func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	#Sağ tık ile iteme basıldığı takdirde Unit'lerde deselect fonksiyonunu çalıştırır.
	if _mouse_button_index == 2 :
		get_tree().call_group("unit", "deselect", index)
