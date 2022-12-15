extends Control

var cards: Array = []

# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	# create postitions for all possible card objects
	clear_board()
	create_positions()
	# create card objects and give them the corresponding positions with a blank sprite
	# this is so we dont create 52 objects every game reset
	
	create_cards()

func _process(delta):
	pass

# -------------------------------- GAME START/ RESTART FUCNTIONS ----------------------------------------------

func _on_StartButton_pressed():
	# on start empty the board and create a new randomized set
	clear_board()
	create_cards()
	create_set()
	pass 

func create_cards():
	for i in range(52):
		var card = Utils.Card.new(i)
		card.rect_position = casc_pos[i % 8][i / 8]
		cards.append(card)
		$Cards.add_child(card)
		card.add_child(card.texture_button)
	pass

func clear_board():
	casc_id.clear()
	casc_id.append_array([ [], [], [], [], [], [], [], [] ])

	found_id.clear()
	found_id.append_array([ [], [], [], [] ])
	
	fc_id.clear()
	fc_id.append_array([ 52, 52, 52, 52])
	
	for i in cards:
		i.queue_free()
	cards.clear()
	
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
var found_pos = []
var fc_pos = []

var top_left_pos: Vector2 = Vector2(100, 100)
var gap_x = 37
var gap_y = 14

func create_positions():
	for i in range(8):
		for j in range(18):
			var pos: Vector2 = Vector2.ZERO
			pos.x = top_left_pos.x + i * gap_x
			pos.y = top_left_pos.y + j * gap_y
			casc_pos[i].append(pos)
	pass
