extends Control

var in_gui = false
var attack_button = false
var hold_button = false

func _on_attack_button_pressed():
	get_tree().call_group("unit", "attack")

func _on_hold_button_pressed():
	get_tree().call_group("unit", "hold")


func _on_area_2d_mouse_entered():
	in_gui = true


func _on_area_2d_mouse_exited():
	in_gui = false
