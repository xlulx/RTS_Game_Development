extends Control

#oyunun durdurulup durdurulmadığını tutan değiş
var is_paused = false : set = set_is_paused

func _unhandled_input(event):
	#Action Pause = escape button
	#Pause butonuna basıldığında oyunu durdurur
	if event.is_action_pressed("Pause"):
		self.is_paused =!is_paused

#is_paused değişkeninin set fonksiyonu
func set_is_paused(value):
	#Oyunu durdurur
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

#Resume Game butonu
func _on_resume_game_pressed():
	#Oyunu devam ettirir
	self.is_paused = false

#Menu butonu
func _on_menu_pressed():
	#Oyunu devam ettirir ve kullanıcıyı menüye aktarır
	get_tree().paused = !is_paused
	get_tree().change_scene_to_file("res://Scenes/Gui/Main_Menu/menu.tscn")
