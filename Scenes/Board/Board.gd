extends Control

# --------------------------------- VARIABLES ----------------------------------------

# holds card objects
var cards: Array = []

# cascade Array of Arrays for memorizing card order for each cascade(column)
var casc_id: Array = [ [], [], [], [], [], [], [], [] ]
# foundations Array of Arrays to hold solved cards (starts empty)
var found_id: Array = [ [], [], [], [] ]
# free_cells Array of 4 empty cells that will hold the temporary cards (starts empty) 
var fc_id: Array = [null, null, null, null]

var casc_pos = [ [], [], [], [], [], [], [], [] ]
var found_pos = [Vector2(295, 20), Vector2(335, 20), Vector2(375, 20), Vector2(415, 20)]
var fc_pos = [Vector2(60, 20), Vector2(100, 20), Vector2(140, 20), Vector2(180, 20)]

var game_started: bool = false # if game is started
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
	pass

# -------------------------------- GAMEPLAY FUNCTIONS -------------------------------------------------

func move_card_to_coordinate(card, to_coord):
	# print("movement_call to coordinate ", to_coord)
	# if we move card to free cell
	if to_coord.x == -1:
		# if we move card from free cell
		if card.coord.x == -1:
			fc_id[card.coord.y] = null

			card.coord = to_coord

			fc_id[card.coord.y] = card.id
		# if we move card from cascade
		if card.coord.x >= 0:
			casc_id[card.coord.x][card.coord.y] = null

			card.coord = to_coord

			fc_id[card.coord.y] = card.id
		
		# move card texture
		card.pos = fc_pos[card.coord.y]
	# if we move card to foundation
	if to_coord.x == -2:
		# if we move card from free cell
		if card.coord.x == -1:
			fc_id[card.coord.y] = null

			card.coord = to_coord

			found_id[card.coord.y].append(card.id)
		# if we move card from cascade
		if card.coord.x >= 0:
			casc_id[card.coord.x][card.coord.y] = null

			card.coord = to_coord

			found_id[card.coord.y].append(card.id)
		
		# move card texture
		card.pos = found_pos[card.coord.y]
	# if we move card to cascade
	if to_coord.x >= 0 && to_coord.y <=17:
		# if we move card from free cell
		if card.coord.x == -1:
			fc_id[card.coord.y] = null

			card.coord = to_coord

			casc_id[card.coord.x][card.coord.y] = card.id
		# if we move card from cascade
		if card.coord.x >= 0:
			casc_id[card.coord.x][card.coord.y] = null

			card.coord = to_coord

			casc_id[card.coord.x][card.coord.y] = card.id
		
		# move card texture
		card.pos = casc_pos[card.coord.x][card.coord.y]
	arrange_card_children()
	pass

func select_card(card):
	selected_card = card
	selected_card.change_shader()
	pass

func deselect_card():
	selected_card.change_shader()
	selected_card = null
	pass

func _on_Card_press(card_id: int):
	# print("card ", cards[card_id].coord)
	# the pressed card
	var pressed_card = cards[card_id]
	
	# this checks if game has started, we dont want to select cards before dealing the set
	# and that the card isn't in a foundation
	if game_started && pressed_card.coord.x != -2:
		# the card we consider:
		var card: Utils.Card
		# if the pressed card is in a cascade
		if pressed_card.coord.x >= 0:
			# if the card pressed is a free cell card
			if pressed_card.coord.x == -1:
				card = pressed_card # the card is the pressed card
			# if it isnt
			else:
				# then card is in cascade and we calculate and consider the top card
				# we do this by going through all ids in the cascade of the pressed card
				# and finding which id is followed by null
				for i in range(casc_id[pressed_card.coord.x].size()):
					if  casc_id[pressed_card.coord.x][i] != null && casc_id[pressed_card.coord.x][i + 1] == null:
						card = cards[casc_id[pressed_card.coord.x][i]]
						break
		# if the pressed card is in a free cell
		else:
			card = pressed_card
		
		# if we dont have a selected card...
		if selected_card == null:
			# ...select the pressed card
			select_card(card)
		# if we have a selected card...
		else:
			# ...and its the same as the one pressed...
			if selected_card == card:
				# ...deselect it
				# CHANGE TO ADD TO FIRST AVAILABLE FREE CELL
				deselect_card()
			# ...and it differs from the selected one
			else:
				# ...check for compatibility for movement and move accordingly
				# this doesnt allow movement of a card on top of a free cell card
				if !(card.coord.x == -1):
					move_card_to_coordinate(selected_card, Vector2(card.coord.x, card.coord.y + 1))
				deselect_card()
	pass

# this function is called when pressing an EMPTRY FREECELL
# if free cell is pressed but it has a card stored, it will call _on_Card_press
# freecell holds which free cell has been pressed
func _on_FreeCell_press(freecell):
	# print("freecell ", freecell)
	# only if game started
	if game_started:
		# if we have a selected card...
		if selected_card != null:
			# ...and the free cell is empty...
			if fc_id[freecell] == null:
				# ...move the selected card to free cell position
				move_card_to_coordinate(selected_card, Vector2(-1, freecell))
				
				# and deselect card
				deselect_card()
			else:
				pass
		#\/ THIS CODE IS USELESS SINCE THIS CALLS ONLY FOR EMPTY FREECELLS
#		# if we dont have a selected card...
#		else:
#			# ...and the free cell isn't empty...
#			if fc_id[freecell] != null:
#				# ...select the card in the free cell
#				select_card(cards[fc_id[freecell]])
#			else:
#				pass
	pass

func _on_Foundation_press(foundation):
	# print("foundation ", foundation)
	# Foundation colors are in order:
	# -> hearts (♥) -> 0
	# -> clubs (♣) -> 1
	# -> diamonds (♦) -> 2
	# -> spades (♠) -> 3
	
	# check if we have selected card and can be moved to foundation
	#  -> move card to foundation
	if selected_card != null:
		move_card_to_coordinate(selected_card, Vector2(-2, foundation))
		deselect_card()
	pass # Replace with function body.

# this function is called only when pressing the bottom most position of cascade
# ONLY WHEN CASCADE IS COMPLETELY EMPTY
func _on_CascadeBottom_press(cascade):
	print(cascade)
	if selected_card != null:
		move_card_to_coordinate(selected_card, Vector2(cascade, 0))
		deselect_card()
	pass # Replace with function body.

# -------------------------------- GAME STATE FUNCTIONS -----------------------------------------

# this function arranges the card chuldren in the scene tree because of an issue
# regarding the layering of TextureButtons
# the TextureButton that is last in the children of $Cards will have hover priority
func arrange_card_children():
	# make cascade cards be layered so that the top cards in each cascade
	# are the last children of $Cards
	# (will be behing Foundation* and after FreeCell*)
	# cards that are in free cells and foundation will be between them in scene tree
	# so they dont need special cases (THEORETICALLY)
	for i in range(18):
		for j in range(8):
			if casc_id[j][i] != null:
				var card = cards[casc_id[j][i]]
				$Cards.move_child(card, $Cards.get_child_count() - 5)
	for i in range(8):
		var cascade_bottom = get_node("Cards/CascadeBottom" + String(i + 1))
		if casc_id[i][0] != null:
			cascade_bottom.disabled = true
		else:
			cascade_bottom.disabled = false
	pass

func _on_StartButton_pressed():
	$Cards/CascadeBottom1.hide()
	$Cards/CascadeBottom2.hide()
	$Cards/CascadeBottom3.hide()
	$Cards/CascadeBottom4.hide()
	$Cards/CascadeBottom5.hide()
	$Cards/CascadeBottom6.hide()
	$Cards/CascadeBottom7.hide()
	$Cards/CascadeBottom8.hide()
	game_started = false
	# on start clear the board of all ids
	clear_board_of_ids()
	#  + move all cards back to start
	give_cards_start_pos()
	# randomize a new set of ids
	randomize_set()
	# give randomized ids to cards and move 
	give_cards_rand_pos()
	arrange_card_children()
	# wait for cards to go to their positions
	yield(get_tree().create_timer(1.0), "timeout")
	$Cards/CascadeBottom1.show()
	$Cards/CascadeBottom2.show()
	$Cards/CascadeBottom3.show()
	$Cards/CascadeBottom4.show()
	$Cards/CascadeBottom5.show()
	$Cards/CascadeBottom6.show()
	$Cards/CascadeBottom7.show()
	$Cards/CascadeBottom8.show()
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
		casc_id[i % 8][i / 8] = card_id[i]
	pass

# -------------------------------- BOARD FUnCTIONS ----------------------------------------------------------------

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
		$Cards.move_child(card, 12)
		card.add_child(card.texture_button)
		card.mouse_filter = MOUSE_FILTER_STOP 
		# connect the card_press signal (specific to the card class) 
		card.connect("card_press", self, "_on_Card_press")
	pass

func give_cards_start_pos():
	for i in cards:
		# give start coordinate (doesnt affect anything cause will be changed immediately after)
		i.coord = Vector2(-3, -3)
		
		# change pos to be behind the CardDeck Sprite
		i.pos = card_start_pos
	pass

func give_cards_rand_pos():
	# 1 - take every id in casc_id,
	# 2 - look for card with that id in cards
	# 3 - give that card the pos from casc_pos and respective coordinate
	for i in range(52):
		#1
		var id = casc_id[i % 8][i / 8]
		#2
		var card = cards[id]
		#3
		card.pos = casc_pos[i % 8][i / 8]
		card.coord = Vector2(i % 8, i / 8)
	pass

func clear_board_of_ids():
	casc_id.clear()
	casc_id.append_array([ [], [], [], [], [], [], [], [] ])
	for i in range(8):
		for j in range(19):
			casc_id[i].append(null)
	
	found_id.clear()
	found_id.append_array([ [], [], [], [] ])
	
	fc_id.clear()
	fc_id.append_array([null, null, null, null])
	
	if selected_card != null:
		selected_card.change_shader()
		selected_card = null
	pass
