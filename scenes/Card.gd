extends Control
class_name Card

@onready var background = $Background
@onready var card_text = $CardText
@onready var area_2d = $Area2D

var card_name: String = "Card"
var is_dragging: bool = false
var drag_offset: Vector2
var original_parent: Node
var original_position: Vector2
var play_area: Control

func _ready():
	# Set up the card appearance
	custom_minimum_size = Vector2(100, 140)
	background.color = Color.WHITE
	background.size = custom_minimum_size
	card_text.text = card_name
	card_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_text.size = custom_minimum_size
	
	# Set up collision
	var collision_shape = $Area2D/CollisionShape2D
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = custom_minimum_size
	collision_shape.shape = rect_shape
	
	# Connect signals
	area_2d.input_event.connect(_on_input_event)
	play_area = get_tree().get_first_node_in_group("play_area")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	print("Input detected: ", event)  # Add this line
	if event is InputEventMouseButton:
		print("Mouse button event: ", event.button_index, " pressed: ", event.pressed)  # Add this line
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(event.global_position)
			else:
				stop_drag()

func start_drag(mouse_pos: Vector2):
	is_dragging = true
	original_parent = get_parent()
	original_position = position
	drag_offset = global_position - mouse_pos
	
	# Move to top layer for dragging
	var main = get_tree().current_scene
	reparent(main)
	z_index = 100

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func stop_drag():
	if not is_dragging:
		return
		
	is_dragging = false
	z_index = 0
	
	# Check if dropped on play area
	if play_area and is_over_play_area():
		drop_on_play_area()
	else:
		return_to_hand()

func is_over_play_area() -> bool:
	var play_area_rect = Rect2(play_area.global_position, play_area.size)
	return play_area_rect.has_point(global_position)

func drop_on_play_area():
	var current_global_pos = global_position
	reparent(play_area)
	global_position = current_global_pos
	print("Card played: " + card_name)

func return_to_hand():
	reparent(original_parent)
	position = original_position
	print("Card returned to hand: " + card_name)

func set_card_data(name: String, color: Color = Color.WHITE):
	card_name = name
	if card_text:
		card_text.text = card_name
	if background:
		background.color = color
