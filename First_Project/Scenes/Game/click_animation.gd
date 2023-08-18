extends AnimatedSprite2D

var game

func _ready():
	game = get_node("/root/Game/Camera")
	position = game.global_mouse_position
	if game.red_click :
		game.red_click = false
		modulate = Color(1,0,0)
	visible = true

func _on_animation_finished():
	queue_free()
