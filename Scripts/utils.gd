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
	var id     # (from 0 to 51)
	var color  # (from 0 to 3)
	var number # (from 0 to 12)
	
	# texture_button property for the card texture as well as clicking capabilities
	var texture_button: TextureButton = TextureButton.new()
	
	# if card is in cascade -> coordinate = Vector2 from (0,0) to (17,17) or whatever
	# if card is in freecell -> coordinate = Vector2 from (-1, 0) to (-1, 3)
	# if card is in foundation -> coordinate = Vector2 from (-2, 0) to (-2, 3)
	var coord = Vector2.ZERO
	
	# position on screen
	var pos = Vector2.ZERO

	signal card_press
	
	# Constructor
	func _init(id):
		self.id = id
		self.color = id / 13
		self.number = id % 13
		
		# set texture for the button for the specific frame in the spritesheet
		texture_button.texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", id)
		
		texture_button.connect("button_down", self, "_on_TButton_pressed")
		pass
	
	func _process(delta):
		# lerp so it doesnt move directly to pos
		self.rect_position = lerp(self.rect_position, self.pos, 0.12 * delta * 50) 
		pass
	
	func _on_TButton_pressed():
		
		emit_signal("card_press", id)
		pass
	
	func change_shader():
		if texture_button.get_material() == Utils.INVERTCOLOR_SHADER:
			texture_button.set_material(Utils.EMPTY_SHADER)
		else:
			texture_button.set_material(Utils.INVERTCOLOR_SHADER)
		pass
 
# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	pass

func _process(delta):
	
	pass
