extends Control

# --------------------------------- VARIABLES ----------------------------------------

# holds card objects
var cards: Array = []

# cascade Array of Arrays for memorizing card order for each cascade(column)
var casc_id: Array = [ [], [], [], [], [], [], [], [] ]
# foundations Array of Arrays to hold solved cards (starts empty)
var found_id: Array = [ [], [], [], [] ]
# free_cells Array of 4 empty cells that will hold the temporary cards (starts empty) 
var fc_id: Array = [52, 52, 52, 52]

var casc_pos = [ [], [], [], [], [], [], [], [] ]
var found_pos = [Vector2(295, 20), Vector2(335, 20), Vector2(375, 20), Vector2(415, 20)]
var fc_pos = [Vector2(60, 20), Vector2(100, 20), Vector2(140, 20), Vector2(180, 20)]

var game_started: bool = false # if game is started
var selected_card_id: int = -1 # holds the selected card's id
var selected_card: Utils.Card = null # selected card

# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	set_process(false)
	# create all possible card object positions
	create_positions()
	# create the 52 cards and place behind card deck sprite
	create_cards()
	pass

func _process(delta):
	check_selectable_cards()
	arrange_card_children()
	pass

# -------------------------------- GAMEPLAY FUNCTIONS -------------------------------------------------

func check_selectable_cards():
	for i in cards:
		if i.coord.x == -1 || casc_id[i.coord.x][casc_id[i.coord.x].size() - 1] == i.id:
			i.selectable = true
		
	for i in range(8):
		var casc_size = casc_id[i].size()
		for j in range(casc_size):
			var card = cards[casc_id[i][j]]
			if j == casc_size - 1:
				card.selectable = true
			else:
				card.selectable = false
	pass

func _on_Card_press(card_id: int):
	# this checks if game has started, we dont want to select cards before dealing the game
	if game_started:
		# the pressed card
		var pressed_card = cards[card_id]
		# the card we consider:
		var card: Utils.Card
		# if the card pressed is the top one in the cascade (if its selectable)
		if pressed_card.selectable:
			card = pressed_card # the card is the pressed card
		# if it isn't the top card in cascade
		else:
			# take the top card and consider that
			card = cards[casc_id[pressed_card.coord.x][casc_id[pressed_card.coord.x].size() - 1]]
		# if we dont have a selected card, select the pressed card
		if selected_card_id == -1:
			card.change_shader()
			selected_card_id = card.id
			selected_card = card
		# if we have a selected card...
		else:
			# ...and its the same as the one pressed, delesect it
			if selected_card_id == card.id:
				selected_card.change_shader()
				selected_card_id = -1
			# ...and it differs from the selected one, check for compatibility for movement
			# and move accordingly
			else:
#				if moveable -> move
#				else -> deselect
				selected_card.change_shader()
				selected_card = card
				selected_card_id = card.id
				selected_card.change_shader()
	pass

# -------------------------------- GAME STATE FUNCTIONS ----------------------------------------------

func arrange_card_children():
	for i in range(18):
		for j in range(8):
			if i < casc_id[j].size():
				var card = cards[casc_id[j][i]]
				$Cards.move_child(card, $Cards.get_child_count() - 1)
	pass

func _on_StartButton_pressed():
	game_started = false
	# on start clear the board of all ids + move all cards back to start
	clear_board()
	# randomize a new set of ids
	randomize_set()
	# give randomized ids to cards and move 
	give_cards_rand_pos()
	# wait for cards to go to their positions
	yield(get_tree().create_timer(1.5), "timeout")
	set_process(true)
	game_started = true
	pass 

# ------------------------- RANDOMLY GENERATED SET ------------------------------------------------------------

#Cards: from 0 -> 51
#4 sets - hearts (♥) -> 0
#	    - clubs (♣) -> 1
#	    - diamonds (♦) -> 2
#	    - spades (♠) -> 3
#	each 13 --> 52 cards in total

#- num / 13 => card colour
#- num % 13 => card number

func randomize_set():
	# using randomize() to randomize the seed of the 
	# internal random number generator
	randomize()
	
	var card_id := []
	
	# creating the Array that will hold nums from 0 to 51
	for i in range(52):
		card_id.append(i)
	
	# randomizing the number array by picking random position
	# and swapping between them
	for i in range(52):
		var poz: int = randi() % 52
		# aux for swapping
		var aux
		aux = card_id[i]
		card_id[i] = card_id[poz]
		card_id[poz] = aux
	
	# YOU HAPPY NOW IOSUA?
	
	# adding the randomized array to the cascade_id array
	for i in range(52):
		var casc = i % 8
		casc_id[casc].append(card_id[i])
	pass

# -------------------------------- BOARD FUCTIONS ----------------------------------------------------------------

# for cardpos2D positions:
# - separately have positios for the free_cells, foundations and cascades
# 
# - top_left_pos var
# - gap_x var for the gap between the cascades
# - gap_y var for the gap between the cards in the cascades

# card sprite dimensions = (33, 45)

var card_start_pos = Vector2(240, 20)
var top_left_casc_pos: Vector2 = Vector2(100, 100)
var gap_x = 37
var gap_y = 14

func create_positions():
	for i in range(8):
		for j in range(18):
			var pos: Vector2 = Vector2.ZERO
			pos.x = top_left_casc_pos.x + i * gap_x
			pos.y = top_left_casc_pos.y + j * gap_y
			casc_pos[i].append(pos)
	pass

func create_cards():
	# create card objects
	for i in range(52):
		var card = Utils.Card.new(i)
		# give them the normal start pos (behing deck sprite)
		card.pos = card_start_pos
		card.rect_position = card_start_pos
		# add to cards Array
		cards.append(card)
		# add in scene tree so its visible
		$Cards.add_child(card)
		card.add_child(card.texture_button)
		# connect the card_press signal (specific to the card class) 
		card.connect("card_press", self, "_on_Card_press")
	pass

func give_cards_start_pos():
	# give cards positions (c1 -> (0,0), c2 -> (1,0) ...)
	for i in cards:
		# change cascade coordonate 
		i.coord = Vector2(i.id % 8, i.id / 8)
		
		# change pos
		i.pos = casc_pos[i.id % 8][i.id / 8]
	pass

func give_cards_rand_pos():
	# 1 -take every id in casc_id,
	# 2 -look for card with that id in cards
	# 3 -give that card the pos from casc_pos and respective coordinate
	for i in range(52):
		#1
		var id = casc_id[i % 8][i / 8]
		#2
		var card = cards[id]
		#3
		card.pos = casc_pos[i % 8][i / 8]
		card.coord = Vector2(i % 8, i / 8)
	
	pass

func clear_board():
	casc_id.clear()
	casc_id.append_array([ [], [], [], [], [], [], [], [] ])

	found_id.clear()
	found_id.append_array([ [], [], [], [] ])
	
	fc_id.clear()
	fc_id.append_array([ 52, 52, 52, 52])
	
	if selected_card_id != -1:
		selected_card.change_shader()
		selected_card_id = -1
		selected_card = null
#	for i in cards:
#		i.pos = card_start_pos
	pass
