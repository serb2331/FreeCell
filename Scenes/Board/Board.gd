extends Control



func _ready():
	pass

func _on_StartButton_pressed():
	# on start empty the board and create a new set
	Utils.empty_board()
	Utils.create_set()
	# create card objects -> card_obj array
	# give them the position, ids and texture to correspond
	for i in range(52):
		# card pos -> (i % 8, i / 8)
		var card = Utils.Card.new(Utils.cascade_id[i % 8][i / 8])
		card.texture_button.set_position(Utils.casc_positions[i % 8][i / 8])
		get_node("Cards").add_child(card)
		card.add_child(card.texture_button)
		card.add_to_group("Cascade" + String(i % 8))
	pass 
