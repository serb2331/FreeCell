extends TextureButton

func _ready():
	var card := Utils.Card.new(0)
	add_child(card.texture_button)
	pass

func _process(delta):
	pass
