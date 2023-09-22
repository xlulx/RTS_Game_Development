extends Control

func _ready():
	#Mouse'ın pencerenin dışına çıkmasını engeller
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

#Oyna Butonu
func _on_play_pressed():
	#Sahneyi değiştirir
	get_tree().change_scene_to_file("res://Scenes/Game/Game.tscn")

#Çıkış Butonu
func _on_quit_pressed():
	#Oyunu tümüyle kapatır
	get_tree().quit()
