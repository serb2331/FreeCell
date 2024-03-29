extends Node

onready var CARDS_SPRITESHEET = load("res://Assets/cards_spriteframes.tres")

onready var INVERTCOLOR_SHADER = load("res://Shaders/InvertColorMaterial.tres")

var sfx_toggle: bool = true
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
	
	# position on screen change this when moving to make animoation of movement
	var pos = Vector2.ZERO

	signal card_press
	
	# Constructor
	func _init(id):
		self.id = id
		self.color = id / 13
		self.number = id % 13
		
		# set texture for the button for the specific frame in the spritesheet
		texture_button.texture_normal = Utils.CARDS_SPRITESHEET.get_frame("big", id)
		
		texture_button.connect("button_down", self, "_on_TButton_pressed")
	
	func _process(delta):
		# lerp so it doesnt move directly to pos
		rect_position = lerp(rect_position, pos, 0.12 * delta * 80)
	
	
	func _on_TButton_pressed():
		emit_signal("card_press", id)
	
	func change_shader():
		if texture_button.get_material() == Utils.INVERTCOLOR_SHADER:
			texture_button.set_material(null)
		else:
			texture_button.set_material(Utils.INVERTCOLOR_SHADER)

#--------------------------- UNDO MOVE CLASS --------------------------------------------

class UndoMove:
	# card array, +-card stack, from coord, to coord
	
	#from bottom up
	var card_array: Array
	
	var from_coord: Vector2
	var to_coord: Vector2
	
	
	func _init(given_card_array: Array, given_from_coord: Vector2, given_to_coord: Vector2):
		self.card_array = given_card_array
		self.from_coord = given_from_coord
		self.to_coord = given_to_coord
