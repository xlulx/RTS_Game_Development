extends AnimatedSprite2D

#Camera node'unu tutan değişken
var Camera

func _ready():
	#Camera node'unu Camera değişkenine atar
	Camera = get_node("/root/Game/Camera")
	#Mouse'un dünyadaki pozisyonunu alır
	position = Camera.global_mouse_position
	
	#Animasyonun kırmızı olup olmaması gerektiğini kontrol eder
	if Camera.red_click :
		Camera.red_click = false
		#Animasyon görselini kırmızı hale getirir
		modulate = Color(1,0,0)
	#Animasyonu görünür yapar
	visible = true

#Animasyon bittiğinde animasyon sahnesinin silinmesini sağlar
func _on_animation_finished():
	queue_free()
