extends Node

#CARD NOTATION:
#	- cascade = column in the board
#	- cell = empty space for a card to occupy
#	- foundation = pile of the solved cards

onready var DECK_SPRITESHEET = load("res://Assets/card_deck.tres")

# cascade dict for memorizing card order for each cascade(column)
var cascades: Dictionary = {
	"casc1" : [],
	"casc2" : [],
	"casc3" : [],
	"casc4" : [],
	"casc5" : [],
	"casc6" : [],
	"casc7" : [],
	"casc8" : []
}

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
		self.card_number = id % 13\
		
		# set texture for the button for the specific frame in the spritesheet
		texture_button.texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", id)
		pass

func _ready():
	
	pass
