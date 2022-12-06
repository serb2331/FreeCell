extends TextureButton

var card_num = 14

func _ready():
	texture_normal = Utils.DECK_SPRITESHEET.get_frame("default", card_num)
	pass

func _process(delta):
	pass
