extends Control

var cards: Array = []

# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	set_process(false)
	# create all possible card object positions
	create_positions()
	# create the 52 cards and give them positions (c1 -> (0,0), c2 -> (1,0) ...)
	create_cards()
	pass

func _process(delta):
	check_selectable_cards()
	pass

# -------------------------------- GAMEPLAY FUNCTIONS -------------------------------------------------

func check_selectable_cards():
	for i in range(8):
		var casc_size = casc_id[i].size()
		for j in range(casc_size):
			var card = cards[casc_id[i][j]]
			if j == casc_size - 1:
				card.selectable = true
			else:
				card.selectable = false
	pass

func _on_Card_press(card_id: int, is_card_selectable: bool):
	print(card_id, is_card_selectable)
	
	pass

# -------------------------------- GAME START/ RESTART FUCNTIONS ----------------------------------------------

func _on_StartButton_pressed():
	# on start clear the board of all ids
	clear_board()
	# move all cards back to start positions
	give_cards_start_pos()
	# give randomized ids to cards and move 
	give_cards_rand_pos()
	# wait for cards to go to their positions
	yield(get_tree().create_timer(1.5), "timeout")
	set_process(true)
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
		i.casc_coord = Vector2(i.id % 8, i.id / 8)
		
		# change pos
		i.pos = casc_pos[i.id % 8][i.id / 8]
	pass

func give_cards_rand_pos():
	# randomize a new set of ids
	create_set()
	
	# 1 -take every id in casc_id,
	# 2 -look for card with that id in cards
	# 3 -give that card the pos from casc_pos
	for i in range(52):
		#1
		var id = casc_id[i % 8][i / 8]
		#2
		var card = cards[id]
		#3
		card.pos = casc_pos[i % 8][i / 8]
	
	pass

func clear_board():
	casc_id.clear()
	casc_id.append_array([ [], [], [], [], [], [], [], [] ])

	found_id.clear()
	found_id.append_array([ [], [], [], [] ])
	
	fc_id.clear()
	fc_id.append_array([ 52, 52, 52, 52])
	
	pass

# ------------------------- RANDOMLY GENERATED SET ------------------------------------------------------------

# cascade Array of Arrays for memorizing card order for each cascade(column)
var casc_id: Array = [ [], [], [], [], [], [], [], [] ]

# foundations Array of Arrays to hold solved cards (starts empty)
var found_id: Array = [ [], [], [], [] ]

# free_cells Array of 4 empty cells that will hold the temporary cards (starts empty) 
var fc_id: Array = [52, 52, 52, 52]

#Cards: from 0 -> 51
#4 sets - hearts (♥) -> 0
#	    - clubs (♣) -> 1
#	    - diamonds (♦) -> 2
#	    - spades (♠) -> 3
#	each 13 --> 52 cards in total

#- num / 13 => card colour
#- num % 13 => card number

func create_set():
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

# -------------------------------- CREATING POSITIONS ----------------------------------------------------------------

# for cardpos2D positions:
# - separately have positios for the free_cells, foundations and cascades
# 
# - top_left_pos var
# - gap_x var for the gap between the cascades
# - gap_y var for the gap between the cards in the cascades

# card sprite dimensions = (33, 45)
var casc_pos = [ [], [], [], [], [], [], [], [] ]
var found_pos = [Vector2(295, 20), Vector2(335, 20), Vector2(375, 20), Vector2(415, 20)]
var fc_pos = [Vector2(60, 20), Vector2(100, 20), Vector2(140, 20), Vector2(180, 20)]

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
