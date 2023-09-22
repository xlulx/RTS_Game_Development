extends Node2D

#update_status fonksiyonuna gelen değişkenleri alan değişkenler
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var dragging = false

#Seçim karesini ekran üzerinde çizmek için fonksiyon
func _draw():
	#Sürüklenme devam ettiği sürece seçim karesini çizen fonksiyon
	if dragging:
		draw_rect(Rect2(drag_start, drag_end - drag_start) , Color(0,1,0) , false)

#Camera fonksiyonundan değişkenleri çağırıp seçim karesini çizen fonksiyon
func update_status(start, end, drag):
	drag_start = start
	drag_end = end
	dragging = drag
	queue_redraw()
