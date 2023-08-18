extends Node2D

#Seçim karesi
var dragging = false
var weakref_selected = []
var selected = []
var drag_start = Vector2.ZERO
var global_drag_start = Vector2.ZERO
var relative_rect = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()
@onready var select_draw = $SelectDraw

#Click animasyonu
var Click_Animation = preload("res://Assets/click_animation.tscn")
var red_click = false

#Farenin oyun dünyasındaki yerini tutan değişken
var global_mouse_position = Vector2.ZERO
var mouse_position = Vector2.ZERO
var is_mouse_on_gui = false

#Kamera Hareketi
var camera_speed = 320
var screen_edge_threshold = 10
var r_zoom = Vector2.ZERO
#var zoom_power = 0.015
#var zoom = Vector2(zoom_power,zoom_power)
#var min_zoom = 0.5
#var max_zoom = 2.0
#var zoom_speed = 0.01







#func _input(event):
	
	#Zoom hareketi
#	if event is InputEventMouseButton and event.button_index == 4 and $Camera2D.zoom.x < 1.5:
#		$Camera2D.zoom += zoom
#	if event is InputEventMouseButton and event.button_index == 5 and $Camera2D.zoom.x > 0.8:
#		$Camera2D.zoom -= zoom

func _process(delta):
	
	#Farenin yerini bulma
	mouse_position = get_local_mouse_position()
	global_mouse_position = get_global_mouse_position()
	
	#Attack tuşu
	if Input.is_action_pressed("attack_move"):
		red_click = true

	#Sol tık
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.is_action_just_pressed("left_click") :
			is_mouse_on_gui = get_node("/root/Game/Gui/In-game_Menu").in_gui
			if !is_mouse_on_gui:
				for unit in weakref_selected:
					if unit.get_ref():
						unit.get_ref().deselect()
				selected = []
				drag_start = mouse_position
				global_drag_start = global_mouse_position
				dragging = true
				relative_rect = position / r_zoom
		#Seçim alanının çizimi
		select_draw.update_status(drag_start + ((relative_rect - position/r_zoom)), mouse_position , dragging)
	#Çizimin bitimi ve birimleri seçme
	elif Input.is_action_just_released("left_click") and !is_mouse_on_gui :
		dragging = false
		select_draw.update_status(drag_start + ((relative_rect - position/r_zoom)), mouse_position, dragging)
		var global_drag_end = global_mouse_position
		select_rectangle.extents = abs((global_drag_end - global_drag_start) / 2)
		var space = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.set_shape(select_rectangle)
		query.transform = Transform2D(0, ((global_drag_end + global_drag_start)/2))
		selected = space.intersect_shape(query)
		for unit in selected:
			if unit.collider.is_in_group("unit"):
				if unit.collider.unit_Owner == 0 :
					unit.collider.select()
					weakref_selected.append(weakref(unit.collider))
	
	#Sağ tık
	if Input.is_action_just_pressed("right_click") and selected:
		var click = Click_Animation.instantiate()
		add_sibling(click)

	#Kamera Hareketi
	var camera_movement = Vector2.ZERO
	if mouse_position.x < screen_edge_threshold:
		camera_movement.x = -1
	elif mouse_position.x > get_viewport().size.x - screen_edge_threshold:
		camera_movement.x = 1
	if mouse_position.y < screen_edge_threshold:
		camera_movement.y = -1
	elif mouse_position.y > get_viewport().size.y - screen_edge_threshold:
		camera_movement.y = 1
	camera_movement = camera_movement.normalized() * camera_speed * delta
	translate(camera_movement)
	
	#Kamera zoom
	r_zoom = Vector2(1 / $Camera2D.zoom.x,1 / $Camera2D.zoom.y)
	scale = r_zoom
