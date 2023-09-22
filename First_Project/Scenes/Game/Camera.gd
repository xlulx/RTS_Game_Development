extends Node2D

#Farenin oyun dünyasındaki yerini tutan değişkenler
#Mouse'un ekran üzerindeki pozisyonunu tutan değişken
var mouse_position = Vector2.ZERO
#Mouse'un oyun dünyası üzerindeki pozisyonunu tutan değişken
var global_mouse_position = Vector2.ZERO
#Tek seferlik sol tık değişkeni
var is_left_pressed = false
#Mouse'un gui üzerinde olup olmadığını tutan değişken
var is_mouse_on_gui = false

#In-game_Menu node'unu tutan değişken
var Gui

func _ready():
	#In-game_Menu node'unu Gui değişkenine atama
	Gui = get_node("/root/Game/Gui/In-game_Menu")

func _process(delta):
	#Farenin yeri ile bilgi alma
	#Mouse'un ekran üzerindeki pozisyonunu alma
	mouse_position = get_local_mouse_position()
	#Mouse'un oyun dünyası üzerindeki pozisyonunu alma
	global_mouse_position = get_global_mouse_position()
	#Mouse'un gui üzerinde olup olmadığını kontrol etme
	is_mouse_on_gui = Gui.is_mouse_on_gui
	
	#Unit'leri seçmeyi sağlayan fonksiyon
	UnitSelection()
	
	#Tüm kamera Hareketini sağlayan fonksiyon
	CameraMovement(delta)
	
	#Action attack_move = A tuşu
	#Attack tuşuna basıldığında çalışacak fonksiyon
	if Input.is_action_pressed("attack_move"):
		red_click = true
	
	#Action right_click = mouse sağ tık
	#Sağ tık basıldığında çalışacak fonksiyon
	if Input.is_action_just_pressed("right_click"):
		#Click animasyonu çağıran fonksiyon
		SummonClickAnimation()


#Seçili unitlerin Tüm bilgisini tutan array
var selected = []
#Seçili unitlerin zayif bir referansını tutan array
var weakref_selected = []
#Farenin sürüklenip sürüklenmediğini tutan değişken
var dragging = false
#Farenin sürüklenmeye başladığı noktanın ekrandaki vektörü
var drag_start = Vector2.ZERO
#Farenin sürüklenmeye başladığı noktanın dünyadaki vektörü
var global_drag_start = Vector2.ZERO
#Farenin dünya üzerinde kaymaya başladığı ve kaymayı bitirdiği noktalar arasında kalan dikdörtgen
var select_rectangle = RectangleShape2D.new()
#Çizilen seçim dikdörtgenini hareket eden kameraya göre düzelten vektör
var relative_rect = Vector2.ZERO
#SelectDraw node'u tutan değişken
@onready var select_draw = $SelectDraw

#Unit'leri seçmeyi sağlayan fonksiyon
func UnitSelection() :
	#Sol tık basılı tutulduğu ve 10px sürüklendiği sürece çalışacak fonksiyon
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and 10 < drag_start.distance_to(mouse_position):
		#Sol tık basıldığı anda çalışacak anlık fonksiyon
		if Input.is_action_just_pressed("left_click") :
			is_left_pressed = true
			#Sürüklenmenin ekran üzerindeki başlangıcını alma
			#Ekran üzerinde
			drag_start = mouse_position
			#Dünya üzerinde
			global_drag_start = global_mouse_position
			#Cameranın konumu çekme
			relative_rect = position
			#Daha önceden seçilen Unitlerin deselect edilmesi
			if !is_mouse_on_gui:
				for unit in weakref_selected:
					if unit.get_ref():
						unit.get_ref().deselect(null,null)
				selected = []
				dragging = true
		#Seçim alanının çizimi
		select_draw.update_status(drag_start + (relative_rect - position), mouse_position , dragging)
	#Çizimin bitimi ve birimleri seçme
	elif Input.is_action_just_released("left_click") and 10 < drag_start.distance_to(mouse_position) and is_left_pressed:
		#Sürüklemenin bitişi ve ekrana çizilen karenin silinmesi
		dragging = false
		select_draw.update_status(drag_start + (relative_rect - position), mouse_position, dragging)
		#Farenin sürüklenmesinin bittiği noktanın dünyadaki vektörü
		var global_drag_end = global_mouse_position
		#Dünya üzerinde bulunan dikdörtgenin oluşturulması
		select_rectangle.extents = abs((global_drag_end - global_drag_start) / 2)
		#2 boyutlu uzay oluşturulması
		var space = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.collision_mask = 2
		#2 boyutlu uzayın dünya üzerindeki dikdörtgenin şeklini alması ve onun yerine götürülmesi
		query.set_shape(select_rectangle)
		query.transform = Transform2D(0, ((global_drag_end + global_drag_start)/2))
		#2 boyutlu uzay ile kesişen birimlerin seçilmesi
		selected = space.intersect_shape(query, 128)
		#Seçilen Unitlerin select edilmesi ve zayıf bir referansının alınması
		for unit in selected:
			if unit.collider.is_in_group("unit"):
				if unit.collider.unit_Owner == 0 :
					unit.collider.select()
					weakref_selected.append(weakref(unit.collider))


#Kamera Hareket vektörünü tutan değişken
var camera_movement = Vector2.ZERO
#Kameranın hızını tutan değişken
var camera_speed = 360
#Ekranın ne kadar kenarındayken kameranın hareket edeceğini tutan değişken
var screen_edge_threshold = 10

#Tüm kamera Hareketini sağlayan fonksiyon
func CameraMovement(delta) :
	#Vektörü sıfırlama
	camera_movement = Vector2.ZERO
	#Mouse'un pozisyonuna göre kamera'nın gideceği yönü belirleme
	#Sol yönlü kontrol
	if mouse_position.x < screen_edge_threshold:
		camera_movement.x = -1
	#Sağ yönlü kontrol
	elif mouse_position.x > get_viewport().size.x - screen_edge_threshold:
		camera_movement.x = 1
	#Yukarı yönlü kontrol
	if mouse_position.y < screen_edge_threshold:
		camera_movement.y = -1
	#Aşağı yönlü kontrol
	elif mouse_position.y > get_viewport().size.y - screen_edge_threshold:
		camera_movement.y = 1
	#Kontrolü sağlanan yönde normalize edilerek hız ve delta ile çarpılmış hız
	camera_movement = camera_movement.normalized() * camera_speed * delta
	#Kamerayı ilerletme
	translate(camera_movement)


#click_animation sahnesini içinde tutan değişken
var Click_Animation = preload("res://Assets/click_animation.tscn")
#Click animasyonun kırmızı olup olmadığını tutan değişken
var red_click = false

#Click animasyonu çağıran fonksiyon
func SummonClickAnimation() :
	if selected and !is_mouse_on_gui :
		var click = Click_Animation.instantiate()
		add_sibling(click)
