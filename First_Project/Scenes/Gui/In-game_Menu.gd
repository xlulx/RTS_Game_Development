extends Control

#Mouse'un gui içinde olup olmadığını kontrol eden değişken
var is_mouse_on_gui = false
#Camera node'unu tutan değişken
var Camera
#ItemList node'unu tutan değişken
@onready var list = $Units_Panel/ItemList

#Formasyon butonu değişkenleri
@onready var Formations_box = $Alt_Command_Panel/Formations_Box
@onready var Formations_panel = $Area2D/Formation_Panel

func _ready():
	#Camera node'unu Camera değişkenine atar
	Camera = get_node("/root/Game/Camera")
	#Gui'ı kapatır
	close_Gui()
	
#attack butonu
func _on_attack_button_pressed():
	#Unit'lerde bulunan attack fonksiyonunu çalıştırır
	get_tree().call_group("unit", "attack")

#hold butonu
func _on_hold_button_pressed():
	#Unit'lerde bulunan hold fonksiyonunu çalıştırır
	get_tree().call_group("unit", "hold")
	
func _on_formation_button_pressed():
	#Formasyon kutusuna basıldığında kapatma ve açma işlemini gerçekleştirir
	if Formations_box.visible :
		Formations_box.visible = false
		Formations_panel.visible = false
	else :
		Formations_box.visible = true
		Formations_panel.visible = true

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
	#sağ tık algılama
	if _mouse_button_index == 2 :
		if index != null :
		#seçili listeni tarayarama
			remove_unit(index)

#birimleri listelerden silmek için kullanılan fonksiyon
func remove_unit(removedUnit) :
	if removedUnit != null :
		#birimlerin tamamını silme
		if removedUnit == -1 :
			list.clear()
		#belirli bir birimi silme
		else :
			var minus = [false, 0]
			#listedeki silinen birimin tespiti
			for unit in Camera.weakref_selected :
				if unit[1] == removedUnit :
					minus[1] = removedUnit
					minus[0] = true
				elif minus[0] :
					Camera.weakref_selected[unit[1]][1] -= 1
					list.set_item_text(Camera.weakref_selected[unit[1]][1] + 1 , ("Unit "+str(Camera.weakref_selected[unit[1]][1])))
			list.set_item_text(list.get_item_count() - 1 , ("Unit "+str(list.get_item_count() - 2 )))
			#Sağ tık ile iteme basıldığı takdirde Unit'lerde deselect fonksiyonunu çalıştırır.
			get_tree().call_group("unit", "deselect", removedUnit)
			#Unitleri listelerden temizler
			Camera.weakref_selected.pop_at(removedUnit)
			list.remove_item(removedUnit)
			
			minus[0] = false
		if list.get_item_count() == 0 :
			close_Gui()

#Gui'ı tamamiyle kapatır
func close_Gui():
	Camera.selected = []
	#Gui'ı kapatır
	visible = false
	
	#Formasyon kutusu görünürlüğü
	Formations_box.visible = false
	Formations_panel.visible = false
