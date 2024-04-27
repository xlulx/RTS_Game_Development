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
var no_drag

#Node'ları tutan değişkenler
var Gui
var Items
var Buildings_Map
var Navigation

func _ready():
	#Node değişkenlerinin çekilmesi
	Gui = get_node("/root/Game/Gui/In-game_Menu")
	Items = get_node("/root/Game/Gui/In-game_Menu/Units_Panel/ItemList")
	Buildings_Map = get_node("/root/Game/Navigasyon/Buildings")
	Navigation = get_node("/root/Game/Navigasyon")
	
func _process(delta):
	#Farenin yeri ile bilgi alma
	#Mouse'un ekran üzerindeki pozisyonunu alma
	mouse_position = get_local_mouse_position()
	#Mouse'un oyun dünyası üzerindeki pozisyonunu alma
	global_mouse_position = get_global_mouse_position()
	#Mouse'un gui üzerinde olup olmadığını kontrol etme
	is_mouse_on_gui = Gui.is_mouse_on_gui
	
	#Bina yapılıp yapılmadığını kontrol eden fonksiyon
	if what_to_building :
		build(what_to_building)
	
	#Mouse gui üzerinde ise dünya ile etkileşimi kesen fonksiyon
	if Input.is_action_just_pressed("left_click") and !is_mouse_on_gui :
		Gui.remove_unit(-1)
		no_drag = true
		
	#Unit'leri seçmeyi sağlayan fonksiyon
	if no_drag :
		UnitSelection()
	
	#Mouse gui üzerinde ise dünya ile etkileşimi kesen fonksiyon 2
	if Input.is_action_just_released("left_click") :
		no_drag = false
	
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

#Unit'leri seçmeyi sağlayan fonksiyon
func UnitSelection() :
	
	#Sol tık basıldığı anda çalışacak anlık fonksiyon
	if Input.is_action_just_pressed("left_click") :
		is_left_pressed = true
		#Ekran üzerinde
		drag_start = mouse_position
		#Dünya üzerinde
		global_drag_start = global_mouse_position
		#Cameranın konumu çekme
		relative_rect = position
		
		if weakref_selected :
			#Daha önceden seçilen Unitlerin deselect edilmesi
			EmptySelectedLists()
		
	#Seçim karesi ile birimlerin seçilmesi
	DrawingSelectRect()

			
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

#Seçili unitlerin Tüm bilgisini tutan array
var selected_Units = []
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
#sürükleme başlamadan önceki maksinim sürükleme
var max_drag = 20

#Seçim karesi ile birimlerin seçilmesi
func DrawingSelectRect() :
	#Sol tık basılı tutulduğu ve max_drag geçildiği anda çalışacak fonksiyon
	if  (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and max_drag < drag_start.distance_to(mouse_position)) or dragging:
		dragging = true
		#Seçim alanının çizimi
		select_draw.update_status(drag_start + (relative_rect - position), mouse_position , dragging)
	
	#Çizimin bitimi ve birimleri seçme
	if (Input.is_action_just_released("left_click") and is_left_pressed) and dragging:
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
		selected_Units = space.intersect_shape(query, 128)
		#Seçilen Unitlerin select edilmesi ve zayıf bir referansının alınması
		for weak_unit in selected_Units:
			if weak_unit.collider.is_in_group("unit"):
				if weak_unit.collider.unit_Owner == 0 :
					#referansların yanına drag_start a olan uzaklığın eklenmesi
					weakref_selected.append([weakref(weak_unit.collider)
					, global_drag_start.distance_to(weak_unit.collider.position), 0])
		
		#Seçilen birimlerin listellerde sıralanması, gui a bildirilmesi ve işaretlenmesi
		addingUnitMarkers()

#Seçilen birimlerin listellerde sıralanması, gui a bildirilmesi ve işaretlenmesi
func addingUnitMarkers() :
	#uzaklığa göre birimlerin sıralanması
	weakref_selected.sort()
	#sıralanan birimlerin 0 dan başlayarak işaretlenmesi
	var unit_Marker = 0
	for weak_unit in weakref_selected:
		#birimlerin işaretlenmesi
		weak_unit[0].get_ref().unit_Mark = unit_Marker
		#birimlere seçilme sinyali yollanması
		weak_unit[0].get_ref().select()
		#listedeki birimlerin işaretlenmesi
		weak_unit[1] = unit_Marker
		#gui'a birimlerin eklenmesi
		Items.add_item("Unit "+str(weak_unit[1]))
		unit_Marker += 1
	if selected_Units :
		Gui.visible = true

#Daha önceden seçilen Unitlerin deselect edilmesi
func EmptySelectedLists() :
	#Weakref listesinin boşaltılması
	for weak_unit in weakref_selected:
		if weak_unit[0].get_ref():
			weak_unit[0].get_ref().deselect(-1)
	
	#Tüm değişkenlerin boşaltılması
	selected_Units = []
	weakref_selected = []
	
#click_animation sahnesini içinde tutan değişken
var Click_Animation = preload("res://Assets/click_animation.tscn")
#Click animasyonun kırmızı olup olmadığını tutan değişken
var red_click = false

#Click animasyonu çağıran fonksiyon
func SummonClickAnimation() :
	if selected_Units and !is_mouse_on_gui :
		var click = Click_Animation.instantiate()
		add_sibling(click)

#Bina Değişkenleri
var last_grid  = Vector2i.ZERO
var this_grid  = Vector2i.ZERO
var what_to_building = []
var buildings = {
	"castle":[Vector2i(0,0),Vector2i(0,8)]
}

#Yapı yapılmasını sağlayan fonksiyon
func build(Building_Name) :
	#Var olan grid'in tilemap'taki koordinatını yerinin çekilmesi
	this_grid = Buildings_Map.local_to_map(global_mouse_position)
	#Grid'ten çıkışı kontrol eden kısım
	if last_grid != this_grid :
		Buildings_Map.erase_cell(0,last_grid)
	#Yapının çizgilerinin çekilmesi
	Buildings_Map.set_cell(0, this_grid,
								0,buildings[Building_Name][1],0)
	#Son grid'in tilemap'taki koordinatının çekilmesi
	last_grid = Buildings_Map.local_to_map(global_mouse_position)
	
	#Sol tıklandığınında binanın yerleştirilmesini sağlayan kısım
	if Input.is_action_just_pressed("left_click") :
		Buildings_Map.erase_cell(0,last_grid)
		Buildings_Map.set_cell(0, Buildings_Map.local_to_map(global_mouse_position),
									0,buildings[Building_Name][0],0)
		what_to_building = []
		last_grid = Vector2i.ZERO
	
	#Navigasyonun bina ile birlikte yeniden yapılandırılması
	Navigation.bake_navigation_polygon()
