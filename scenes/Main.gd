extends Node2D

@onready var hand = $Hand
@onready var play_area = $PlayArea

var card_scene = preload("res://scenes/Card.tscn")

func _ready():
	setup_ui()
	create_starting_hand()

func setup_ui():
	# Get the actual viewport size
	var screen_size = get_viewport().get_visible_rect().size
	print("Actual screen size: ", screen_size)
	
	# Setup play area (top half of screen)
	play_area.size = Vector2(screen_size.x - 100, screen_size.y * 0.6)
	play_area.position = Vector2(50, 50)
	play_area.add_to_group("play_area")
	
	# Add visual background to play area
	var play_bg = ColorRect.new()
	play_bg.color = Color(0.3, 0.3, 0.3, 0.5)
	play_bg.size = play_area.size
	play_area.add_child(play_bg)
	
	# Setup hand (bottom of screen)
	hand.size = Vector2(screen_size.x - 100, 150)
	hand.position = Vector2(50, screen_size.y - 200)  # 200 pixels from bottom
	
	print("Hand positioned at: ", hand.position)
	print("Play area positioned at: ", play_area.position)
	
	# Add visual background to hand
	var hand_bg = ColorRect.new()
	hand_bg.color = Color(0.2, 0.2, 0.2, 0.7)
	hand_bg.size = hand.size
	hand.add_child(hand_bg)

func create_starting_hand():
	var card_names = ["Fire Spell", "Water Spell", "Earth Spell", "Air Spell", "Lightning"]
	var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.CYAN, Color.YELLOW]
	
	# Calculate centering - FIXED VERSION
	var card_width = 150
	var card_spacing = 20
	var total_width = (card_names.size() * card_width) + ((card_names.size() - 1) * card_spacing)
	var start_x = (hand.size.x - total_width) / 2
	
	print("Hand width: ", hand.size.x)
	print("Total cards width needed: ", total_width)
	print("Starting X position: ", start_x)
	
	for i in range(card_names.size()):
		var card = card_scene.instantiate()
		hand.add_child(card)
		card.set_card_data(card_names[i], colors[i])
		card.position = Vector2(start_x + (i * (card_width + card_spacing)), 25)
		print("Card ", i, " position: ", card.position)

func _input(event):
	if event.is_action_pressed("ui_accept"): # Space key
		reset_game()

func reset_game():
	# Clear play area (keep background)
	for child in play_area.get_children():
		if child is Card:
			child.queue_free()
	
	# Clear hand (keep background)
	for child in hand.get_children():
		if child is Card:
			child.queue_free()
	
	# Wait a frame then recreate hand
	await get_tree().process_frame
	create_starting_hand()
