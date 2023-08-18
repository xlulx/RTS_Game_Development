extends Node2D

#Değişmez
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var dragging = false

#Seçim karesini çizmek için fonksiyon
func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, drag_end - drag_start) , Color(0,1,0) , false)
func update_status(start, end, drag):
	drag_start = start
	drag_end = end
	dragging = drag
	queue_redraw()
