extends Control

var in_gui = false
var attack_button = false
var hold_button = false
var Camera
@onready var list = $Units_Panel/ItemList

func _ready():
	Camera = get_node("/root/Game/Camera")

func _on_attack_button_pressed():
	get_tree().call_group("unit", "attack")

func _on_hold_button_pressed():
	get_tree().call_group("unit", "hold")

func _on_area_2d_mouse_entered():
	in_gui = true

func _on_area_2d_mouse_exited():
	in_gui = false

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	if _mouse_button_index == 2 :
		get_tree().call_group("unit", "deselect", index , Camera.selected[index].collider)
