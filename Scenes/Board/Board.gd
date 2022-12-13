extends Control

# --------------------------------- _ready() and _process(delta) ----------------------------------------

func _ready():
	# create card objects and give them the corresponding positions with a blank sprite
	# this is so we dont create 52 objects every game reset
	for i in range(8):
		for j in range(14):
			var card = Utils.Card.new(52)
			card.texture_button.set_position(Utils.casc_positions[i][j])
			$Cards.add_child(card)
			card.add_child(card.texture_button)
			# add the card object to a cascade group that contains all cards in that cascade
			card.add_to_group("Cascade" + String(i % 8 + 1))
	pass

func _process(delta):
	pass

# -------------------------------- GAME START/ RESTART FUCNTIONS ----------------------------------------------

func _on_StartButton_pressed():
	# on start empty the board and create a new randomized set
	empty_board()
	Utils.create_set()
	# give card objects respective ids
	for i in range(52):
		# card pos -> (i % 8, i / 8)
		var card = get_tree().get_nodes_in_group("Cascade" + String(i % 8 + 1))[i / 8 + 1]
		card.change_id(Utils.casc_id[i % 8][i / 8])
		pass
	pass 

func empty_board():
	Utils.casc_id.clear()
	Utils.casc_id.append_array([ [], [], [], [], [], [], [], [] ])
	
	for i in range(8):
		for j in range(14):
			get_tree().get_nodes_in_group("Cascade" + String(i % 8 + 1))[j + 1].change_id(52)
	
	Utils.found_id.clear()
	Utils.found_id.append_array([ [], [], [], [] ])
	
	Utils.fc_id.clear()
	Utils.fc_id.append_array([ 52, 52, 52, 52])
	
	pass
