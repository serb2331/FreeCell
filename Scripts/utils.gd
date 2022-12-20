extends Node

onready var DECK_SPRITESHEET = load("res://Assets/card_deck_bordered.tres")

onready var INVERTCOLOR_SHADER = load("res://Shaders/InvertColorMaterial.tres")
onready var EMPTY_SHADER = load("res://Shaders/EmptyMaterial.tres")
# --------------------------- CARD CLASS ---------------------------------------------------------------------------

#CARD NOTATION:
#	- cascade = column in the board
#	- cell = empty space for a card to occupy
#	- foundation = pile of the solved cards

class Card extends Control:
	var id          # (from 0 to 51)
	var card_color  # (from 0 to 3)
	var card_number # (from 0 to 12)
	
	# texture_button property for the card texture as well as clicking capabilities
	var texture_button: TextureButton = TextureButton.new()
	
	# cascade coordonates
	# if card is in cascade -> coordinate = Vector2 from (0,0) to (17,17) or whatever
	# if card is in freecell -> coordinate = Vector2 from (0, -1) to (3, -1)
	# if card is in foundation -> coordinate = Vector2 from (0, -2) to (3, -2)
	var casc_coord = Vector2.ZERO
	
	# position on screen
	var pos = Vector2.ZERO
	
	# if is the top card in cascade or is in fc
	var selectable: bool = false
	
	signal card_press
	
	# Constructor
	func _init(id):
		self.id = id
		self.card_color = id / 13
		self.card_number = id % 13
		
		# set texture for the button for the specific frame in the spritesheet
		texture_button.texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", id)
		
		texture_button.connect("button_down", self, "_on_TButton_pressed")
		pass
	
	func _process(delta):
		# lerp so it doesnt move directly to pos
		self.rect_position = lerp(self.rect_position, self.pos, 0.12 * delta * 50) 
		# this was to check selectable cards
#		if selectable:
#			texture_button.texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", 53)
#		else:
#			texture_button.texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", id)
		pass
	
	func _on_TButton_pressed():
		
		emit_signal("card_press", id)
		pass
	
	func change_shader():
		if texture_button.get_material() == Utils.INVERTCOLOR_SHADER:
			texture_button.set_material(Utils.EMPTY_SHADER)
		else:
			texture_button.set_material(Utils.INVERTCOLOR_SHADER)

# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	pass

func _process(delta):
	
	pass
