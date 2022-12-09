extends Node

onready var DECK_SPRITESHEET = load("res://Assets/card_deck.tres")

# cascade Array of Arrays for memorizing card order for each cascade(column)
var cascade_id: Array = [ [], [], [], [], [], [], [], [] ]

# foundations Array of Arrays to hold solved cards
var foundation_id: Array = [ [], [], [], [] ]

# free_cells Array of 4 empty cells that will hold the temporary cards 
var free_cell_id: Array = [52, 52, 52, 52]

# --------------------------- CARD CLASS ---------------------------------------------------------------------------

#CARD NOTATION:
#	- cascade = column in the board
#	- cell = empty space for a card to occupy
#	- foundation = pile of the solved cards

class Card extends Node:
	var id          # (from 0 to 51)
	var card_color  # (from 0 to 3)
	var card_number # (from 0 to 12)
	
	# texture_button property for the card texture as well as clicking capabilities
	var texture_button: TextureButton = TextureButton.new()
	
	# Constructor
	func _init(id):
		self.id = id
		self.card_color = id / 13
		self.card_number = id % 13
		
		# set texture for the button for the specific frame in the spritesheet
		texture_button.texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", id)
		pass

# ------------------------- RANDOMLY GENERATED SET ------------------------------------------------------------

#Cards: from 0 -> 51
#4 sets - hearts (♥)
#	   - diamonds (♦)
#	   - spades (♠)
#	   - clubs (♣)
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
		cascade_id[casc].append(card_id[i])
	pass

# -------------------------------- CREATING POSITIONS ----------------------------------------------------------------

# for cardpos2D positions:
# - separately have positios for the free_cells and foundations
# 
# - top_left_pos var
# - gap_x var for the gap between the cascades
# - gap_y var for the gap between the cards in the cascades

# card sprite dimensions = (33, 45)
var casc_positions = [ [], [], [], [], [], [], [], [] ]

var top_left_pos: Vector2 = Vector2(30, 30)
var gap_x = 37
var gap_y = 50

func create_positions():
	for i in range(8):
		for j in range(14):
			var pos: Vector2 = Vector2.ZERO
			pos.x = top_left_pos.x + i * gap_x
			pos.y = top_left_pos.y + j * gap_y
			casc_positions[i].append(pos)
	pass

# -------------------------------- GAME START/ RESTART FUCNTIONS ----------------------------------------------

func empty_board():
	cascade_id.clear()
	cascade_id.append_array([ [], [], [], [], [], [], [], [] ])
	
	foundation_id.clear()
	foundation_id.append_array([ [], [], [], [] ])
	
	free_cell_id.clear()
	free_cell_id.append_array([ 52, 52, 52, 52])
	pass

# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	create_positions()
	pass

func _process(delta):
	
	pass
