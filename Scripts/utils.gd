extends Node

#CARD NOTATION:
#	- cascade = column in the board
#	- cell = empty space for a card to occupy
#	- foundation = pile of the solved cards

onready var DECK_SPRITESHEET = load("res://Assets/card_deck.tres")

# cascade Array of Arrays for memorizing card order for each cascade(column)
var cascades: Array = [ [], [], [], [], [], [], [], [] ]

# foundations Array of Arrays to hold solved cards
var foundations: Array = [ [], [], [], [] ]

# free_cells Array of 4 empty cells that will hold the temporary cards 
var free_cells: Array = [52, 52, 52, 52]

class Card:
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

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		empty_board()
		add_to_cascades(create_set())
	pass

#Cards: from 0 -> 51
#4 sets - hearts (♥)
#	   - diamonds (♦)
#	   - spades (♠)
#	   - clubs (♣)
#	each 13 --> 52 cards in total

#- num / 13 => card colour
#- num % 13 => card number

func create_set() -> Array:
	# using randomize() to randomize the seed of the 
	# internal random number generator
	randomize()
	
	var card_id := []
	
	# creating the Array that will hold nums from 0 to 51
	for i in range(52):
		card_id.append(i)
	
	# randomizing the number array by picking random position and swapping between them
	for i in range(52):
		var poz: int = randi() % 52
		# aux for swapping
		var aux
		aux = card_id[i]
		card_id[i] = card_id[poz]
		card_id[poz] = aux
	
	# YOU HAPPY NOW IOSUA?
	return card_id
	pass

# add randomzied nums to cascades Array
func add_to_cascades(ids: Array):
	for i in range(52):
		var casc = i % 8
		cascades[casc].append(ids[i])
	print(cascades)
	pass

func empty_board():
	cascades.clear()
	cascades.append_array([ [], [], [], [], [], [], [], [] ])
	
	foundations.clear()
	foundations.append_array([ [], [], [], [] ])
	
	free_cells.clear()
	free_cells.append_array([ 52, 52, 52, 52])
	pass
