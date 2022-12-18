extends TextureButton

var InvertColorShader = preload("res://Shaders/InvertColorMaterial.tres")

func _ready():
	
	pass

func _process(delta):
	pass


func _on_Cell_pressed():
	print("press")
	set_material(InvertColorShader)
	pass
