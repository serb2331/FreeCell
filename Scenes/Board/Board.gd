extends Control

# --------------------------------- VARIABLES ----------------------------------------

onready var EmptyCardSprite = preload("res://Assets/empty_card.png")
onready var FoundationSpriteSheet: SpriteFrames = preload("res://Assets/foundation.tres")

onready var MainMenuScene: PackedScene = preload("res://Scenes/MainMenu/MainMenu.tscn")

onready var ShuffleSound: AudioStreamPlayer = $ShuffleStreamPlayer
onready var CardSound: AudioStreamPlayer = $CardStreamPlayer
onready var WrongSound: AudioStreamPlayer = $WrongStreamPlayer

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
var is_dealing: bool = false
var selected_card: Utils.Card = null # selected card

# --------------------------------- _ready() ----------------------------------------

func _ready():
	$SFXToggleButton.pressed = !Utils.sfx_toggle
	for i in range(4):
		var foundation = get_node("Foundation" + String(i + 1))
		foundation.texture_normal = FoundationSpriteSheet.get_frame("default", i)
	# create all possible card object positions
	create_positions()
	# create the 52 cards and place behind card deck sprite
	create_cards()

# -------------------------------- GAMEPLAY FUNCTIONS -------------------------------------------------

#turn find_proper_movement() into 3 funcs:
# - move_card_ids
# - arrange_card_children()
# - move_card_position

func move_card_id(card, to_coord):
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
		# if we move from foundation
		if card.coord.x == -2:
			found_id[card.coord.y].pop_back()

			card.coord = to_coord

			fc_id[card.coord.y] = card.id
		
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
		# if we move from foundation
		if card.coord.x == -2:
			found_id[card.coord.y].pop_back()

			card.coord = to_coord

			casc_id[card.coord.x][card.coord.y] = card.id

func move_card_pos(card, to_coord):
	match to_coord.x:
		-1.0:
			card.pos = fc_pos[card.coord.y]
		-2.0:
			card.pos = found_pos[card.coord.y]
		_:
			card.pos = casc_pos[to_coord.x][to_coord.y]

# called when manual move or auto move, not undo
func move_single_card(card, to_coord):
	
	# hold move in undo_moves
	var undo := Utils.UndoMove.new([card], card.coord, to_coord)
	undo_moves.push_back(undo)
	
	# find and make the move
#	yield(find_proper_movement(card, to_coord), "completed")
	
	if (Utils.sfx_toggle):
		CardSound.play()
	move_card_id(card, to_coord)
	arrange_card_children()
	move_card_pos(card, to_coord)
	yield(get_tree().create_timer(0.07), "timeout")
	
	_on_movement()

func move_stack(start_pos: Vector2, stack_size: int, end_pos: Vector2):
	
	var undo_card_array: Array = []
	
	for index in range(start_pos.y - stack_size + 1, start_pos.y + 1):
		undo_card_array.push_back(cards[casc_id[start_pos.x][index]])
	
	var undo := Utils.UndoMove.new(undo_card_array, start_pos, end_pos)
	undo_moves.push_back(undo)
	
	var cards_to_be_moved: Array = []
	
	for index in range(start_pos.y - stack_size + 1, start_pos.y + 1):
		cards_to_be_moved.append(cards[casc_id[start_pos.x][index]])
	
	for index in range(stack_size):
		move_card_id(cards_to_be_moved[index], end_pos + Vector2( 0, index + 1))
	
	for index in range(stack_size):
		if (Utils.sfx_toggle):
			CardSound.play()
		move_card_pos(cards_to_be_moved[index], end_pos + Vector2( 0, index + 1 ))
		yield(get_tree().create_timer(0.07), "timeout")
	
	_on_movement()

func get_maximum_moveable_stack_size() -> int:
	
	var empty_cascades: int = 0
	var empty_fcs: int = 0
	
	for index in range(8):
		if (casc_id[index][0] == null):
			empty_cascades += 1
	
	for index in range(4):
		if (fc_id[index] == null):
			empty_fcs += 1
	
	return (empty_fcs + 1) * int(pow(2, empty_cascades))

func select_card(card):
	selected_card = card
	selected_card.change_shader()

func deselect_card():
	if selected_card != null:
		selected_card.change_shader()
		selected_card = null

# only check for only min + 1 value cards
func check_for_auto_move():
	# get minimum number in foundation
	var min_found_num = 100000
	for i in range(4):
		if found_id[i].size() > 0:
			if found_id[i][found_id[i].size() - 1] % 13 < min_found_num:
				min_found_num = found_id[i][found_id[i].size() - 1] % 13
		else:
			min_found_num = -1
	# card to be checked for auto movement
	# will be the top cards in each cascade and free cell
	var card_check
	for i in range(8):
		if casc_id[i][0] != null:
			for j in range(casc_id[i].size()):
					if  casc_id[i][j] != null && casc_id[i][j + 1] == null:
						card_check = cards[casc_id[i][j]]
						break
			
			# foundation top card number of respective color
			var found_top_card_num
			if found_id[card_check.color].size() == 0:
				found_top_card_num = -1
			else:
				found_top_card_num = found_id[card_check.color][found_id[card_check.color].size() - 1] % 13
			if ((card_check.number == found_top_card_num + 1 && found_top_card_num == min_found_num) ||
				 card_check.number == found_top_card_num + 1 && found_top_card_num == min_found_num + 1):
				deselect_card()
				move_single_card(card_check, Vector2(-2, card_check.color))
				return
			
	for i in range(4):
		if fc_id[i] != null:
			card_check = cards[fc_id[i]]
			
			# foundation top card number of respective color
			var found_top_card_num
			if found_id[card_check.color].size() == 0:
				found_top_card_num = -1
			else:
				found_top_card_num = found_id[card_check.color][found_id[card_check.color].size() - 1] % 13
			if ((card_check.number == found_top_card_num + 1 && found_top_card_num == min_found_num) ||
				 card_check.number == found_top_card_num + 1 && found_top_card_num == min_found_num + 1):
				deselect_card()
				move_single_card(card_check, Vector2(-2, card_check.color))
				return

# (CALLS FOR CARD PRESSES IN FREECELL AND FOUNDATION TOPS)
func _on_Card_press(card_id: int):
	# print("card ", cards[card_id].coord)
	# the pressed card
	var pressed_card = cards[card_id]
	
	# this checks if game has started, we dont want to select cards before dealing the set
	if game_started:
		# the card we consider:
		var card: Utils.Card
		# if the pressed card is in a cascade
		if pressed_card.coord.x >= 0:
			# we calculate and consider the top card in the cascade
			# we do this by going through all ids in the cascade of the pressed card
			# and finding which id is followed by null
			for i in range(casc_id[pressed_card.coord.x].size()):
				if  casc_id[pressed_card.coord.x][i] != null && casc_id[pressed_card.coord.x][i + 1] == null:
					card = cards[casc_id[pressed_card.coord.x][i]]
		# if the pressed card is in a free cell or a foundation
		else:
			card = pressed_card
		
		# if card is in foundation
		if card.coord.x == -2:
			# if we have a selected card
			if selected_card != null:
				if selected_card.color == card.color && selected_card.number == card.number + 1:
					move_single_card(selected_card, Vector2(-2, card.color))
				deselect_card()
		
		
		# if card is in free cell
		elif card.coord.x == -1:
			if selected_card == null:
				select_card(card)
			else:
				deselect_card()
				select_card(card)
		
		
		# if card is in cascade
		else:
			if selected_card == null:
				select_card(card)
			else: # if we have a selected card
				# ...and its the same as the one pressed...
				if selected_card == card:
					# ...add to first available free cell
					for i in range(4):
						if fc_id[i] == null:
							move_single_card(selected_card, Vector2(-1, i))
							break
					deselect_card()
				
				else:
					if (selected_card.coord.x == -1):
						if (card.color % 2 != selected_card.color % 2 && card.number == selected_card.number + 1):
							move_single_card(selected_card, Vector2(card.coord.x, card.coord.y + 1))
							deselect_card()
						else:
							if (Utils.sfx_toggle):
								WrongSound.play()
							deselect_card()
							select_card(card)
					
					else:
						
						# there are 2 types of stacks, K-B and K-R
						# if card number % 2 + color number % 2  -> even => card is part of a K-R stack
						# ---------------||--------------------  -> odd  => card is part of a K-B stack
						
						if (((card.color % 2 + card.number % 2) % 2 == (selected_card.color % 2 + selected_card.number % 2) % 2)
							&& selected_card.number < card.number):
							
							#find apropriate card start of the movable card stack
							
							var needed_stack_size: int = card.number - selected_card.number
							if (selected_card.coord.y - needed_stack_size >= -1 && get_maximum_moveable_stack_size() >= needed_stack_size):
								var stack_is_complete: bool = true
								
								for index in range(selected_card.coord.y - 1, selected_card.coord.y - needed_stack_size, -1):
									# cards[casc_id[selected_card.coord.x][index]]
									if !((cards[casc_id[selected_card.coord.x][index]].color % 2 != cards[casc_id[selected_card.coord.x][index + 1]].color % 2)
									   && cards[casc_id[selected_card.coord.x][index]].number == cards[casc_id[selected_card.coord.x][index + 1]].number + 1):
										stack_is_complete = false
								
								if(stack_is_complete):
									#start the movement
									move_stack(selected_card.coord, needed_stack_size, card.coord)
									deselect_card()
								else:
									if (Utils.sfx_toggle):
										WrongSound.play()
									deselect_card()
									select_card(card)
							else:
								if (Utils.sfx_toggle):
									WrongSound.play()
								deselect_card()
								select_card(card)
							
						else:
							if (Utils.sfx_toggle):
								WrongSound.play()
							deselect_card()
							select_card(card)

# (ONLY WHEN PRESSING THE EMPTY FREECELL, CARDS IN FREECELL CALL CARD_PRESS) 
# freecell holds which free cell has been pressed
func _on_FreeCell_press(freecell):
	# only if game started
	if game_started:
		# if we have a selected card...
		if selected_card != null:
			# ...and the free cell is empty...
			if fc_id[freecell] == null:
				# ...move the selected card to free cell position
				move_single_card(selected_card, Vector2(-1, freecell))
				
				# and deselect card
				deselect_card()
			else:
				deselect_card()
		# if we dont have a selected card...
		else:
			# ...and the free cell isn't empty...
			if fc_id[freecell] != null:
				# ...select the card in the free cell
				select_card(cards[fc_id[freecell]])

# (ONLY WHEN PRESSING THE EMPTY FOUNDATION, CARDS IN FOUNDATION CALL CARD_PRESS) 
# foundation holds which foundation was pressed
func _on_Foundation_press(foundation):
	# Foundation colors are in order:
	# -> hearts (♥) -> 0
	# -> clubs (♣) -> 1
	# -> diamonds (♦) -> 2
	# -> spades (♠) -> 3
	
	# check if we have selected card and can be moved to foundation
	#  -> move card to foundation
	if selected_card != null:
		if selected_card.color == foundation && selected_card.number == 0:
			move_single_card(selected_card, Vector2(-2, foundation))
		else:
			if (Utils.sfx_toggle):
				WrongSound.play()
	deselect_card()

# this function is called only when pressing the bottom most position of cascade
# ONLY WHEN CASCADE IS COMPLETELY EMPTY
func _on_CascadeBottom_press(cascade):
	if selected_card != null:
		
		if (selected_card.coord.x == -1):
			move_single_card(selected_card, Vector2(cascade, 0))
		
		elif (selected_card.coord.x >= 0):
			var possible_stack_size: int = min(get_maximum_moveable_stack_size() / 2, selected_card.coord.y)
			print(possible_stack_size, " ", selected_card.coord, Vector2(cascade, 0))
			var stack_stop_size: int = -1
			for index in range(1, possible_stack_size):
				
				if (stack_stop_size != -1):
					break
				
				elif !((cards[casc_id[selected_card.coord.x][selected_card.coord.y - index]].color % 2 != cards[casc_id[selected_card.coord.x][selected_card.coord.y - index + 1]].color % 2)
				   && cards[casc_id[selected_card.coord.x][selected_card.coord.y - index]].number == cards[casc_id[selected_card.coord.x][selected_card.coord.y - index + 1]].number + 1):
					stack_stop_size = index
			
			if (stack_stop_size == -1):
				stack_stop_size = possible_stack_size
			
			move_stack(selected_card.coord, stack_stop_size, Vector2(cascade, -1))
		
	deselect_card()

# when player presses background of board
# and has selected card, deselect it
func _on_Background_press():
	deselect_card()

func count_max_card_number_to_move():
	var count_empty_casc = 0
	var count_empty_fc = 0
	for i in range(8):
		if casc_id[i][0] == null:
			count_empty_casc += 1
	for i in range(4):
		if fc_id[i] == null:
			count_empty_fc += 1
	
	return pow(2.0, count_empty_casc) * (count_empty_fc + 1)

# this function:
#  -arranges the card children in the scene tree because of an issue
#   regarding the layering of TextureButtons
# (the TextureButton that is last in the children of $Cards will have hover and render prio)
#  -makes the CascadeButton texture btn enabled or disabled
#   based on if there are cards in the cascade
func _on_movement():
	
	
	arrange_card_children()
	
	check_game_finish()
	
	check_for_auto_move()

# -------------------------------- GAME STATE FUNCTIONS -----------------------------------------

func check_game_finish():
	if found_id[0].size() == 13 && found_id[1].size() == 13 && found_id[2].size() == 13 && found_id[3].size() == 13:
		yield(get_tree().create_timer(0.5), "timeout")
		game_started = false
		$KingSprite.show()
		$QueenSprite.show()


func arrange_card_children():
	# make cascade cards be layered so that the top cards in each cascade
	# are the last children of $Cards
	# (will be behind Foundation* and after FreeCell*)
	# cards that are in free cells and foundation will be between them in scene tree
	# so they dont need special cases (THEORETICALLY)
	for i in range(18):
		for j in range(8):
			if casc_id[j][i] != null:
				var card = cards[casc_id[j][i]]
				$Cards.move_child(card, $Cards.get_child_count() - 1)
			else:
				break
	# we also need to sort foundation cards so that the top card appears
	# and not another card in the foundation
	for i in range(4):
		for j in range(found_id[i].size()):
			var foundation_card = cards[found_id[i][j]]
			$Cards.move_child(foundation_card, j)
 
func _on_Deal_pressed():
	print(is_dealing)
	if (!is_dealing):
		move_child($CardDeck, get_child_count())
		$KingSprite.hide()
		$QueenSprite.hide()
		game_started = false
		is_dealing = true
		# on start clear the board of all ids
		clear_board()
		# randomize a new set of ids
		randomize_set()
		
		# give randomized ids to cards and move 
		give_cards_randomized_ids()
		give_cards_positions(casc_id)
		
		if (Utils.sfx_toggle):
			ShuffleSound.play()
		
#		yield(give_cards_positions(), "completed")
		
		arrange_card_children()
		# wait for cards to go to their positions
		yield(get_tree().create_timer(0.75), "timeout")
		move_child($CardDeck, 1)
		game_started = true

func _on_Restart_pressed():
	if rand_card_id.size() != 0 && !is_dealing:
		move_child($CardDeck, get_child_count())
		game_started = false
		is_dealing = true
		$KingSprite.hide()
		$QueenSprite.hide()
		# on start clear the board of all ids
		clear_board()
		# give randomized ids to cards and move 
		
		# give randomized ids to cards and move 
		give_cards_randomized_ids()
		give_cards_positions(casc_id)
		
	#	yield(give_cards_randomized_pos(), "completed")
		
		if (Utils.sfx_toggle):
			ShuffleSound.play()
		arrange_card_children()
		# wait for cards to go to their positions
		yield(get_tree().create_timer(0.75), "timeout")
		move_child($CardDeck, 1)
		game_started = true

# have undo_moves array to hold last moves done
# it will hold moves like this (card, [from coord])
var undo_moves: Array

func _on_Undo_pressed():
	if undo_moves.size() != 0 && game_started:
		deselect_card()
		var undo_move: Utils.UndoMove = undo_moves.back()
		undo_moves.pop_back()
#		print(undo_move.card_array.size(), " ", undo_move.from_coord, " ", undo_move.to_coord)
		
		match undo_move.to_coord.x:
			(-1.0):
				if (Utils.sfx_toggle):
					CardSound.play()
				move_card_id(undo_move.card_array[0], undo_move.from_coord)
				arrange_card_children()
				move_card_pos(undo_move.card_array[0], undo_move.from_coord)
				yield(get_tree().create_timer(0.07), "timeout")
			(-2.0):
				if (Utils.sfx_toggle):
					CardSound.play()
				move_card_id(undo_move.card_array[0], undo_move.from_coord)
				arrange_card_children()
				move_card_pos(undo_move.card_array[0], undo_move.from_coord)
				yield(get_tree().create_timer(0.07), "timeout")
			_:
				if (undo_move.from_coord.x == -1):
					if (Utils.sfx_toggle):
						CardSound.play()
					move_card_id(undo_move.card_array[0], undo_move.from_coord)
					arrange_card_children()
					move_card_pos(undo_move.card_array[0], undo_move.from_coord)
					yield(get_tree().create_timer(0.07), "timeout")
				else:
					var cards_to_be_moved: Array = []
					
					for index in range(undo_move.to_coord.y + 1, undo_move.to_coord.y + undo_move.card_array.size() + 1):
						cards_to_be_moved.append(cards[casc_id[undo_move.to_coord.x][index]])
					
					for index in range(undo_move.card_array.size()):
						move_card_id(cards_to_be_moved[index], Vector2( undo_move.from_coord.x, undo_move.from_coord.y - undo_move.card_array.size() + index + 1 ) )
					
					for index in range(undo_move.card_array.size()):
						if (Utils.sfx_toggle):
							CardSound.play()
						move_card_pos(cards_to_be_moved[index], Vector2( undo_move.from_coord.x, undo_move.from_coord.y - undo_move.card_array.size() + index + 1 ) )
						yield(get_tree().create_timer(0.07), "timeout")
		
		arrange_card_children()

func _on_MenuButton_pressed():
	get_tree().change_scene_to(MainMenuScene)

func _on_SFXToggleButton_toggled(button_pressed):
	Utils.sfx_toggle = !button_pressed

# ------------------------- RANDOMLY GENERATED SET ------------------------------------------------------------

var rand_card_id := []

#Cards: from 0 -> 51
#4 sets - hearts (♥) -> 0
#	    - clubs (♣) -> 1
#	    - diamonds (♦) -> 2
#	    - spades (♠) -> 3
#	each 13 --> 52 cards in total

#- num / 13 => card colour
#- num % 13 => card number (Ace - 0, King - 12)

func randomize_set():
	# using randomize() to randomize the seed of the 
	# internal random number generator
	randomize()
	
	# creating the Array that will hold nums from 0 to 51
	for i in range(52):
		rand_card_id.append(i)
	
	# randomizing the number array by picking random position
	# and swapping between them
	for i in range(52):
		var poz: int = randi() % 52
		# aux for swapping
		var aux
		aux = rand_card_id[i]
		rand_card_id[i] = rand_card_id[poz]
		rand_card_id[poz] = aux

# -------------------------------- BOARD FUNCTIONS ----------------------------------------------------------------

# for cardpos2D positions:
# - separately have positios for the free_cells, foundations and cascades
# 
# - top_left_pos var
# - gap_x var for the gap between the cascades
# - gap_y var for the gap between the cards in the cascades

# card sprite dimensions = (33, 45)

const card_start_pos = Vector2(240, 19)
const top_left_casc_pos: Vector2 = Vector2(100, 75)
const gap_x = 37
const gap_y = 14

func create_positions():
	for i in range(8):
		for j in range(18):
			var pos: Vector2 = Vector2.ZERO
			pos.x = top_left_casc_pos.x + i * gap_x
			pos.y = top_left_casc_pos.y + j * gap_y
			casc_pos[i].append(pos)

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

func give_cards_randomized_ids():
	# adding the randomized array to the cascade_id array
	for i in range(52):
		casc_id[i % 8][i / 8] = rand_card_id[i]

func give_cards_positions(casc_id: Array):
	for i in range(52):
		#1
		var id = casc_id[i % 8][i / 8]
		#2
		var card = cards[id]
		#3
		yield(get_tree().create_timer(0.005), "timeout")
		card.pos = casc_pos[i % 8][i / 8]
		card.coord = Vector2(i % 8, i / 8)
	is_dealing = false


func clear_board():
	casc_id.clear()
	casc_id.append_array([ [], [], [], [], [], [], [], [] ])
	for i in range(8):
		for j in range(19):
			casc_id[i].append(null)
	
	found_id.clear()
	found_id.append_array([ [], [], [], [] ])
	
	fc_id.clear()
	fc_id.append_array([null, null, null, null])
	
	undo_moves.clear()
	
	if selected_card != null:
		selected_card.change_shader()
		selected_card = null

